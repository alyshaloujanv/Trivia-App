//
//  ResultsView.swift
//  TriviaApp
//
//  Created by Ludlyne Alysha Janvier on 4/6/26.
//

import SwiftUI

struct ResultsView: View {

    let questions: [TriviaQuestion]
    let selectedAnswers: [Int: String]
    let score: Int

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {

            // MARK: Score banner
            Section {
                VStack(spacing: 8) {
                    Text(scoreEmoji)
                        .font(.system(size: 60))
                    Text("You scored \(score) out of \(questions.count)")
                        .font(.title2.bold())
                        .foregroundStyle(.purple)
                    Text(scoreLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowBackground(Color.purple.opacity(0.08))
            }

            // MARK: Question breakdown
            ForEach(questions.indices, id: \.self) { index in
                let question = questions[index]
                let userAnswer = selectedAnswers[index]
                let isCorrect = userAnswer == question.correctAnswer

                Section {
                    // Question
                    Text(question.question)
                        .font(.body.weight(.semibold))
                        .padding(.vertical, 4)
                        .listRowBackground(Color.purple.opacity(0.06))

                    // Correct answer row
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Correct: \(question.correctAnswer)")
                            .foregroundStyle(.green)
                        Spacer()
                    }
                    .listRowBackground(Color.green.opacity(0.1))

                    // User's answer row (only show if they answered and were wrong)
                    if let userAnswer = userAnswer, !isCorrect {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                            Text("Your answer: \(userAnswer)")
                                .foregroundStyle(.red)
                            Spacer()
                        }
                        .listRowBackground(Color.red.opacity(0.1))
                    }

                    // Skipped row
                    if userAnswer == nil {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.orange)
                            Text("Skipped")
                                .foregroundStyle(.orange)
                            Spacer()
                        }
                        .listRowBackground(Color.orange.opacity(0.1))
                    }

                } header: {
                    HStack {
                        Text("Question \(index + 1)")
                            .foregroundStyle(.purple)
                            .font(.subheadline.bold())
                        Spacer()
                        Text(isCorrect ? "Correct ✓" : "Incorrect ✗")
                            .font(.caption.bold())
                            .foregroundStyle(isCorrect ? .green : .red)
                    }
                }
            }

            // MARK: Play Again button
            Section {
                Button(action: {
                    // Pop back to OptionsView
                    dismiss()
                    dismiss()
                }) {
                    Text("Play Again")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.purple)
    }

    // MARK: - Helpers

    var scoreEmoji: String {
        let pct = questions.count > 0 ? Double(score) / Double(questions.count) : 0
        switch pct {
        case 0.9...1.0: return "🏆"
        case 0.7..<0.9: return "🎉"
        case 0.5..<0.7: return "👍"
        default:        return "📚"
        }
    }

    var scoreLabel: String {
        let pct = questions.count > 0 ? Int(Double(score) / Double(questions.count) * 100) : 0
        return "\(pct)% — \(scoreFeedback(pct))"
    }

    func scoreFeedback(_ pct: Int) -> String {
        switch pct {
        case 90...100: return "Outstanding!"
        case 70..<90:  return "Great job!"
        case 50..<70:  return "Not bad!"
        default:       return "Keep practicing!"
        }
    }
}

#Preview {
    NavigationStack {
        ResultsView(
            questions: [
                TriviaQuestion(
                    category: "Science",
                    type: "multiple",
                    difficulty: "easy",
                    question: "What is the chemical symbol for water?",
                    correctAnswer: "H2O",
                    incorrectAnswers: ["CO2", "NaCl", "O2"]
                ),
                TriviaQuestion(
                    category: "History",
                    type: "boolean",
                    difficulty: "easy",
                    question: "The Great Wall of China is visible from space.",
                    correctAnswer: "False",
                    incorrectAnswers: ["True"]
                )
            ],
            selectedAnswers: [0: "CO2", 1: "False"],
            score: 1
        )
    }
}
