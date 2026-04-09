//
//  Triviamodel.swift
//  TriviaApp
//
//  Created by Ludlyne Alysha Janvier on 4/4/26.
//

import Foundation

// MARK: - API Response

struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

// MARK: - Trivia Question

struct TriviaQuestion: Codable, Identifiable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    // Decode HTML entities after JSON parsing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        category        = try container.decode(String.self, forKey: .category).htmlDecoded
        type            = try container.decode(String.self, forKey: .type)
        difficulty      = try container.decode(String.self, forKey: .difficulty)
        question        = try container.decode(String.self, forKey: .question).htmlDecoded
        correctAnswer   = try container.decode(String.self, forKey: .correctAnswer).htmlDecoded
        incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers).map { $0.htmlDecoded }
    }

    // Memberwise init used for previews
    init(category: String, type: String, difficulty: String, question: String, correctAnswer: String, incorrectAnswers: [String]) {
        self.category         = category
        self.type             = type
        self.difficulty       = difficulty
        self.question         = question
        self.correctAnswer    = correctAnswer
        self.incorrectAnswers = incorrectAnswers
    }
}

// MARK: - HTML Entity Decoding

extension String {
    var htmlDecoded: String {
        // Replace the most common HTML entities manually — no NSAttributedString needed
        var result = self
        let entities: [(String, String)] = [
            ("&amp;",   "&"),
            ("&quot;",  "\""),
            ("&#039;",  "'"),
            ("&apos;",  "'"),
            ("&lt;",    "<"),
            ("&gt;",    ">"),
            ("&nbsp;",  " "),
            ("&ldquo;", "\u{201C}"),
            ("&rdquo;", "\u{201D}"),
            ("&lsquo;", "\u{2018}"),
            ("&rsquo;", "\u{2019}"),
            ("&mdash;", "\u{2014}"),
            ("&ndash;", "\u{2013}"),
        ]
        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }
        return result
    }
}
