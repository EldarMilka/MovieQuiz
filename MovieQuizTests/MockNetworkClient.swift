//
//  MockNetworkClient.swift
//  MovieQuizTests
//
//  Created by Виктор  on 16.04.2025.
//


import XCTest
@testable import MovieQuiz

class MockNetworkClient: NetworkClientProtocol {
    var result: Result<Data, Error>?

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if let result = result {
            handler(result)
        }
    }
}
