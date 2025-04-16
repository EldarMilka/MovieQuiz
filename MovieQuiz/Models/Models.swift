//
//  Models.swift
//  MovieQuiz
//
//  Created by Эльдар on 08.04.2025.
//

import Foundation

struct Actor: Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}

struct Movie: Codable {
    let id: String
    let rank: Int
    let title: String
    let fullTitle: String
    let year: Int
    let image: String
    let crew: String
    let imDbRating: Double
    let imDbRatingCount: String

    enum CodingKeys: String, CodingKey {
        case id, rank, title, fullTitle, year, image, crew
        case imDbRating = "imDbRating"
        case imDbRatingCount = "imDbRatingCount"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        rank = Int(try container.decode(String.self, forKey: .rank)) ?? 0
        title = try container.decode(String.self, forKey: .title)
        fullTitle = try container.decode(String.self, forKey: .fullTitle)
        year = Int(try container.decode(String.self, forKey: .year)) ?? 0
        image = try container.decode(String.self, forKey: .image)
        crew = try container.decode(String.self, forKey: .crew)
        imDbRating = Double(try container.decode(String.self, forKey: .imDbRating)) ?? 0.0
        imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
    }
}

struct Top: Decodable {
    let items: [Movie]
}
