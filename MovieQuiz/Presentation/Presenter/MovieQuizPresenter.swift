//
// MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Виктор  on 16.04.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter: MovieQuizPresenterProtocol {
    // MARK: - Properties
    weak var view: MovieQuizViewProtocol?
    var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticServiceProtocol
    private let questionsAmount = 10

    // MARK: - Init
    init(
        view: MovieQuizViewProtocol,
        statisticService: StatisticServiceProtocol = StatisticService()
    ) {
        self.view = view
        self.statisticService = statisticService
    }

    // MARK: - Public Methods
    func loadData() {
        view?.showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }

    func answerSelected(_ answer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = (answer == currentQuestion.correctAnswer)

        if isCorrect { correctAnswers += 1 }
        view?.highlightImageBorder(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.view?.hideImageBorder()
            self?.proceedToNextQuestionOrResults()
        }
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    // MARK: - Private Methods
    private func proceedToNextQuestionOrResults() {
        view?.hideImageBorder()

        if currentQuestionIndex == questionsAmount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func showFinalResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)

        let bestGame = statisticService.bestGame
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"

        let resultText = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """

        let alertModel = QuizResultsViewModel(
            title: "Раунд окончен!",
            text: resultText,
            buttonText: "Сыграть ещё раз"
        )
        view?.showAlert(alertModel)
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = makeImage(from: model.image)
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: formattedQuestionNumber()
        )
    }

    // MARK: - Private Helpers
    private func makeImage(from data: Data) -> UIImage {
        guard !data.isEmpty, let image = UIImage(data: data) else {
            return placeholderImage()
        }
        return image
    }

    private func placeholderImage() -> UIImage {
        let size = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func formattedQuestionNumber() -> String {
        return "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        view?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            view?.showNetworkError("Невозможно загрузить данные")
            return
        }

        currentQuestion = question
        let step = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.view?.showQuizStep(step)
        }
    }

    func didFailToLoadData(with error: Error) {
        view?.showNetworkError(error.localizedDescription)
    }

    func didFailToLoadImage(with error: Error) {
        view?.showNetworkError("Ошибка загрузки изображения: \(error.localizedDescription)")
    }
}
