//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Виктор  on 16.04.2025.
//

import XCTest
@testable import MovieQuiz

class MovieQuizUITests: XCTestCase {

    func testYesButtonChangesQuestionNumber() {
        // Запускаем приложение
        let app = XCUIApplication()
        app.launch()

        // Ждем, пока загрузится counterLabel
        let questionNumberLabel = app.staticTexts["questionNumberLabel"]
        XCTAssertTrue(questionNumberLabel.waitForExistence(timeout: 5), "Метка с идентификатором 'questionNumberLabel' не найдена")

        // Сохраняем начальный номер вопроса
        let initialQuestionNumber = questionNumberLabel.label

        // Нажимаем на кнопку "Да"
        let yesButton = app.buttons["yesButton"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 2), "Кнопка 'Да' не найдена")
        yesButton.tap()

        // Ждем обновления UI
        sleep(2) // Временная пауза, лучше заменить на XCTestExpectation

        // Проверяем, что номер вопроса изменился
        let newQuestionNumber = questionNumberLabel.label
        XCTAssertNotEqual(initialQuestionNumber, newQuestionNumber, "Номер вопроса должен измениться после нажатия на кнопку 'Да'")
    }

    func testNoButtonChangesQuestionNumber() {
        // Запускаем приложение
        let app = XCUIApplication()
        app.launch()

        // Ждем, пока загрузится counterLabel
        let questionNumberLabel = app.staticTexts["questionNumberLabel"]
        XCTAssertTrue(questionNumberLabel.waitForExistence(timeout: 5), "Метка с идентификатором 'questionNumberLabel' не найдена")

        // Сохраняем начальный номер вопроса
        let initialQuestionNumber = questionNumberLabel.label

        // Нажимаем на кнопку "Нет"
        let noButton = app.buttons["noButton"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 2), "Кнопка 'Нет' не найдена")
        noButton.tap()

        // Ждем обновления UI
        sleep(2) // Временная пауза, лучше заменить на XCTestExpectation

        // Проверяем, что номер вопроса изменился
        let newQuestionNumber = questionNumberLabel.label
        XCTAssertNotEqual(initialQuestionNumber, newQuestionNumber, "Номер вопроса должен измениться после нажатия на кнопку 'Нет'")
    }

    func testAlertAppearsAtEndOfRound() {
        // Запускаем приложение
        let app = XCUIApplication()
        app.launch()

        // Ждем загрузки первого вопроса
        let questionNumberLabel = app.staticTexts["questionNumberLabel"]
        XCTAssertTrue(questionNumberLabel.waitForExistence(timeout: 2))

        // Симулируем ответы на все 10 вопросов
        for _ in 0..<10 {
            app.buttons["yesButton"].tap()
            sleep(1) // Пауза для обработки ответа
        }

        // Проверяем, что алерт появился
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: 2), "Алерт должен появиться после окончания раунда")

        // Проверяем текст заголовка и кнопки
        XCTAssertEqual(alert.label, "Раунд окончен!", "Заголовок алерта должен быть 'Раунд окончен!'")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз", "Текст кнопки должен быть 'Сыграть ещё раз'")
    }

    func testAlertDismissesAndResetsQuestionNumber() {
        // Запускаем приложение
        let app = XCUIApplication()
        app.launch()

        // Ждем загрузки первого вопроса
        let questionNumberLabel = app.staticTexts["questionNumberLabel"]
        XCTAssertTrue(questionNumberLabel.waitForExistence(timeout: 2))

        // Симулируем ответы на все 10 вопросов
        for _ in 0..<10 {
            app.buttons["yesButton"].tap()
            sleep(1) // Пауза для обработки
        }

        // Ждем появления алерта
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        // Нажимаем на кнопку алерта
        alert.buttons.firstMatch.tap()

        // Проверяем, что алерт исчез
        XCTAssertFalse(alert.exists, "Алерт должен исчезнуть после нажатия на кнопку")
        sleep(1)

        // Проверяем, что счётчик сбросился на "1/10"
        XCTAssertEqual(questionNumberLabel.label, "1/10", "Счётчик вопросов должен сброситься на '1/10'")
    }
}
