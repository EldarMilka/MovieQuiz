//
//  MovieQuizViewProtocol.swift
//  MovieQuiz
//
//  Created by Виктор  on 16.04.2025.
//

import Foundation

protocol MovieQuizViewProtocol: AnyObject {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showQuizStep(_ step: QuizStepViewModel)
    func highlightImageBorder(isCorrect: Bool)
    func hideImageBorder()
    func showAlert(_ model: QuizResultsViewModel)
    func showNetworkError(_ message: String)
}
