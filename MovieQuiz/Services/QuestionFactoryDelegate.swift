//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Эльдар on 04.04.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    
}

