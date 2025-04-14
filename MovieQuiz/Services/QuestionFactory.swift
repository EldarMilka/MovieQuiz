//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Эльдар on 01.04.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {

    private weak var delegate: QuestionFactoryDelegate?

    private var movies: [MostPopularMovie] = []

    private let moviesLoader: MoviesLoading
    private let ratingThreshold: Float = 7.0
    
    // MARK: - Init
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    // MARK: - Setup
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }

    // MARK: - Data Loading
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    // MARK: - Question Generation
    func requestNextQuestion() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self, !self.movies.isEmpty else {
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }

            let randomIndex = Int.random(in: 0..<self.movies.count)
            let movie = self.movies[randomIndex]

            self.loadImageData(from: movie.imageURL) { [weak self] imageData in
                let rating = Float(movie.rating) ?? 0
                let questionText = "Рейтинг этого фильма больше чем \(self?.ratingThreshold ?? 7)?"
                let correctAnswer = rating > (self?.ratingThreshold ?? 7)

                let question = QuizQuestion(
                    image: imageData,
                    text: questionText,
                    correctAnswer: correctAnswer
                )

                DispatchQueue.main.async {
                    self?.delegate?.didReceiveNextQuestion(question: question)
                }
            }
        }
    }

    // MARK: - Private Helpers
    private func loadImageData(from url: URL, completion: @escaping (Data) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.delegate?.didFailToLoadImage(with: error)
                }
                return
            }

            guard let data = data else {
                let error = NSError(domain: "ImageLoading", code: -1, userInfo: [NSLocalizedDescriptionKey: "No image data"])
                DispatchQueue.main.async {
                    self?.delegate?.didFailToLoadImage(with: error)
                }
                return
            }

            completion(data)
        }.resume()
    }
}
