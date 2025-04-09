//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Эльдар on 04.04.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case correct
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
        case totalQuestions
    }
    
    
    private let storage: UserDefaults = .standard
    
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    

    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    private var totalQuestions: Int {
        get {
            storage.integer(forKey: Keys.totalQuestions.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestions.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let correct = correctAnswers
        let total = totalQuestions
        
        guard total > 0 else { return 0 }
        
        return (Double(correct) / Double(total)) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        totalQuestions += amount
        gamesCount += 1
        
        let newGame = GameResult(correct: count, total: amount, date: Date())
        
        if newGame.isBetter(than: bestGame) {
            bestGame = newGame
        }
        
        
    }
}

extension GameResult {
    func isBetter(than other: GameResult) -> Bool {
           return self.accuracy > other.accuracy
       }

       var accuracy: Double {
           guard total > 0 else { return 0 }
           return Double(correct) / Double(total)
       }
   }
