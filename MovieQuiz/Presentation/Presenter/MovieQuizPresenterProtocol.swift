//
// MovieQuizPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Виктор  on 16.04.2025.
//

import Foundation

protocol MovieQuizPresenterProtocol {
    var view: MovieQuizViewProtocol? { get set }

    func loadData()
    func answerSelected(_ answer: Bool)
    func restartGame()
}
