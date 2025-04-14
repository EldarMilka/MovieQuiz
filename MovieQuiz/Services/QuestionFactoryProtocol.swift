//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Эльдар on 03.04.2025.
//

import Foundation

protocol QuestionFactoryProtocol {
    func setup(delegate: QuestionFactoryDelegate)
    func loadData()
    func requestNextQuestion()
}
