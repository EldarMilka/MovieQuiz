//
// MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Виктор  on 16.04.2025.
//

import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {

    var sut: MoviesLoader!
    var mockNetworkClient: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        sut = MoviesLoader(networkClient: mockNetworkClient)
    }

    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        super.tearDown()
    }

    func testLoadMoviesSuccess() {
        // Arrange
        let expectedMovies = MostPopularMovies(
            errorMessage: "",
            items: [
                MostPopularMovie(
                    title: "The Shawshank Redemption",
                    rating: "9.2",
                    imageURL: URL(string: "https://example.com/image1.jpg")!
                ),
                MostPopularMovie(
                    title: "The Godfather",
                    rating: "9.1",
                    imageURL: URL(string: "https://example.com/image2.jpg")!
                )
            ]
        )

        let jsonData = try! JSONEncoder().encode(expectedMovies)
        mockNetworkClient.result = .success(jsonData)

        let expectation = XCTestExpectation(description: "Movies loaded successfully")
        var result: Result<MostPopularMovies, Error>?

        // Act
        sut.loadMovies { receivedResult in
            result = receivedResult
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1)
        switch result {
        case .success(let movies):
            XCTAssertEqual(movies.errorMessage, "", "errorMessage должен быть пустым")
            XCTAssertEqual(movies.items.count, 2, "Должно быть загружено 2 фильма")
            XCTAssertEqual(movies.items[0].title, "The Shawshank Redemption", "Название первого фильма должно совпадать")
            XCTAssertEqual(movies.items[1].rating, "9.1", "Рейтинг второго фильма должен совпадать")
        case .failure:
            XCTFail("Ожидался успех, но получена ошибка")
        case .none:
            XCTFail("Результат не получен")
        }
    }

    func testLoadMoviesFailure() {
        // Arrange
        let expectedError = NetworkClient.NetworkError.codeError
        mockNetworkClient.result = .failure(expectedError)

        let expectation = XCTestExpectation(description: "Movies loading failed")
        var result: Result<MostPopularMovies, Error>?

        // Act
        sut.loadMovies { receivedResult in
            result = receivedResult
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1)
        switch result {
        case .success:
            XCTFail("Ожидалась ошибка, но получен успех")
        case .failure(let error as NetworkClient.NetworkError):
            XCTAssertEqual(error, expectedError, "Ожидалась ошибка codeError")
        case .failure(let receivedError):
            XCTFail("Получена неожиданная ошибка: \(receivedError)")
        case .none:
            XCTFail("Результат не получен")
        }
    }

    func testLoadMoviesDecodingFailure() {
        // Arrange
        let invalidData = Data("Invalid JSON".utf8)
        mockNetworkClient.result = .success(invalidData)

        let expectation = XCTestExpectation(description: "Movies loading failed due to decoding error")
        var result: Result<MostPopularMovies, Error>?

        // Act
        sut.loadMovies { receivedResult in
            result = receivedResult
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1)
        switch result {
        case .success:
            XCTFail("Ожидалась ошибка декодирования, но получен успех")
        case .failure:
            XCTAssertTrue(true, "Ожидалась ошибка декодирования")
        case .none:
            XCTFail("Результат не получен")
        }
    }
}
