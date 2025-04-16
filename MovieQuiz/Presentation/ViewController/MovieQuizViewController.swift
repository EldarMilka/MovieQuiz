//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Виктор  on 16.04.2025.
//

import Foundation

import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewProtocol {

    // MARK: - Outlets
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    private var presenter: MovieQuizPresenterProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(view: self)
        presenter?.loadData()
    }

    // MARK: - Actions
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        presenter?.answerSelected(true)
    }

    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter?.answerSelected(false)
    }

    // MARK: - MovieQuizViewProtocol
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showQuizStep(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    // MARK: - MovieQuizViewProtocol
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func hideImageBorder() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    func showAlert(_ model: QuizResultsViewModel) {
        let alert = UIAlertController(title: model.title, message: model.text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            self?.presenter?.restartGame()
        })
        present(alert, animated: true)
    }

    func showNetworkError(_ message: String) {
        let alert = UIAlertController(title: "Что-то пошло не так(", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Попробовать снова", style: .default) { [weak self] _ in
            self?.presenter?.loadData()
        })
        present(alert, animated: true)
    }
}
