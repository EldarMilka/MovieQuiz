//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Виктор  on 16.04.2025.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {

    func testSafeSubscriptReturnsElementForValidIndex() {
        // Arrange
        let array = [1, 2, 3, 4, 5]

        // Act
        let element = array[safe: 2]

        // Assert
        XCTAssertEqual(element, 3, "Должен вернуть элемент по индексу 2")
    }

    func testSafeSubscriptReturnsNilForNegativeIndex() {
        // Arrange
        let array = [1, 2, 3, 4, 5]

        // Act
        let element = array[safe: -1]

        // Assert
        XCTAssertNil(element, "Должен вернуть nil для отрицательного индекса")
    }

    func testSafeSubscriptReturnsNilForOutOfBoundsIndex() {
        // Arrange
        let array = [1, 2, 3, 4, 5]

        // Act
        let element = array[safe: 5]

        // Assert
        XCTAssertNil(element, "Должен вернуть nil для индекса, превышающего размер массива")
    }

    func testSafeSubscriptReturnsNilForEmptyArray() {
        // Arrange
        let array: [Int] = []

        // Act
        let element = array[safe: 0]

        // Assert
        XCTAssertNil(element, "Должен вернуть nil для пустого массива")
    }
}
