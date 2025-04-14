//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Эльдар on 04.04.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didFailToLoadImage(with error: Error)
}
