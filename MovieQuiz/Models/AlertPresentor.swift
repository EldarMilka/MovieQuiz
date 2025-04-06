//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Эльдар on 04.04.2025.
//

import Foundation

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
