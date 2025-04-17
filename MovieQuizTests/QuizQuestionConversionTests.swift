//
// QuizQuestionConversionTests.swift
//  MovieQuizTests
//
//  Created by Виктор  on 16.04.2025.
//

import XCTest
@testable import MovieQuiz

final class QuizQuestionConversionTests: XCTestCase {

    var presenter: MovieQuizPresenter!
    let mockView = MockMovieQuizView()

    override func setUp() {
        super.setUp()
        presenter = MovieQuizPresenter(view: mockView)
    }

    // Тест корректного преобразования вопроса
    func testConvertWithValidImage() throws {
        // 1. Given
        let testImage = UIImage(systemName: "film.fill")!
        let imageData = testImage.pngData()!
        let question = QuizQuestion(
            image: imageData,
            text: "Test Question",
            correctAnswer: true
        )
        presenter.currentQuestionIndex = 3 // Проверяем для 4-го вопроса

        // 2. When
        let result = presenter.convert(model: question)

        // 3. Then
        XCTAssertEqual(result.question, "Test Question")
        XCTAssertEqual(result.questionNumber, "4/10")

        // Проверяем что изображение не nil и содержит данные
        let resultImageData = result.image.pngData()!
        XCTAssertFalse(resultImageData.isEmpty)
    }

    // Тест с пустыми данными изображения
    func testConvertWithEmptyImageData() {
        // 1. Given
        let question = QuizQuestion(
            image: Data(),
            text: "Empty Image Question",
            correctAnswer: false
        )
        presenter.currentQuestionIndex = 0

        // 2. When
        let result = presenter.convert(model: question)

        // 3. Then
        XCTAssertEqual(result.question, "Empty Image Question")
        XCTAssertEqual(result.questionNumber, "1/10")
        XCTAssertEqual(result.image.size, CGSize(width: 1, height: 1))
    }

    // Тест с битыми данными изображения
    func testConvertWithInvalidImageData() {
        // 1. Given
        let invalidData = Data([0x00, 0x01, 0x02]) // Не валидные данные изображения
        let question = QuizQuestion(
            image: invalidData,
            text: "Invalid Image Question",
            correctAnswer: true
        )
        presenter.currentQuestionIndex = 9

        // 2. When
        let result = presenter.convert(model: question)

        // 3. Then
        XCTAssertEqual(result.question, "Invalid Image Question")
        XCTAssertEqual(result.questionNumber, "10/10")
        XCTAssertEqual(result.image.size, CGSize(width: 1, height: 1))
    }
}

// Mock для MovieQuizViewProtocol
final class MockMovieQuizView: MovieQuizViewProtocol {
    func showQuizStep(_ step: QuizStepViewModel) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func highlightImageBorder(isCorrect: Bool) {}
    func hideImageBorder() {}
    func showAlert(_ model: QuizResultsViewModel) {}
    func showNetworkError(_ message: String) {}
}
