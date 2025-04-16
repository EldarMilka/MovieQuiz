import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private enum Constants {
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 8
        static let resultDateFormat = "dd.MM.yy HH:mm"
    }
    
    // MARK: - Outlets
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
   override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(viewController: self)
        
        imageView.layer.cornerRadius = Constants.cornerRadius
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
  
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            showNetworkError(message: "Вопрос не загружен")
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showQuizStep(quiz: viewModel)
        }
    }
    
    func didFailToLoadImage(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: "Не удалось загрузить изображение: \(error.localizedDescription)")
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(givenAnswer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(givenAnswer: false)
    }
    
    // MARK: - Logic
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.showAlert(with: model)
    }
  
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func showQuizStep(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func handleAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let bestGame = statisticService.bestGame
            let totalPlays = statisticService.gamesCount
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            
            // Форматирование даты с использованием DateFormatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let bestGameDate = dateFormatter.string(from: bestGame.date)
            
            let resultText = """
                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                    Количество сыгранных квизов: \(totalPlays)
                    Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGameDate))
                    Средняя точность: \(accuracy)%
                    """
            
            let viewModel = QuizResultsViewModel(
                title: "Раунд окончен!",
                text: resultText,
                buttonText: "Сыграть ещё раз"
            )
            showAlert(quizResult: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
   //изменил  showAlert
    private func showAlert(quizResult result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }

        alertPresenter?.showAlert(with: alertModel)
    }
}
