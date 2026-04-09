//
//  Quizview.swift
//  TriviaApp
//
//  Created by Ludlyne Alysha Janvier on 4/4/26.
//

import SwiftUI
internal import Combine

struct QuizView: View {

    let questions: [TriviaQuestion]

    @State private var selectedAnswers: [Int: String] = [:]
    @State private var shuffledAnswers: [[String]] = []

    @State private var timeRemaining = 60
    @State private var timerRunning = true

    @State private var score = 0
    @State private var submitted = false
    @State private var showScoreAlert = false
    @State private var showResults = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        List {

            // MARK: Timer bar
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "clock.fill")
                        .foregroundStyle(timeRemaining <= 10 ? .red : .purple)
                    Text("Time remaining: \(timeRemaining)s")
                        .font(.headline)
                        .foregroundStyle(timeRemaining <= 10 ? .red : .purple)
                    Spacer()
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.purple.opacity(0.1))
            }

            // MARK: Questions
            ForEach(questions.indices, id: \.self) { index in
                Section {
                    Text(questions[index].question)
                        .font(.body.weight(.semibold))
                        .padding(.vertical, 4)
                        .listRowBackground(Color.purple.opacity(0.06))

                    if shuffledAnswers.indices.contains(index) {
                        ForEach(shuffledAnswers[index], id: \.self) { answer in
                            AnswerCell(
                                answer: answer,
                                isSelected: selectedAnswers[index] == answer,
                                isSubmitted: submitted,
                                isCorrect: answer == questions[index].correctAnswer
                            ) {
                                if !submitted {
                                    selectedAnswers[index] = answer
                                }
                            }
                        }
                    }
                } header: {
                    Text("Question \(index + 1) of \(questions.count)")
                        .foregroundStyle(.purple)
                        .font(.subheadline.bold())
                }
            }

            // MARK: Submit Button
            Section {
                Button(action: submitAnswers) {
                    Text("Submit")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(submitted)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Trivia")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.purple)
        .onAppear {
            setupAnswers()
        }
        .onReceive(timer) { _ in
            guard timerRunning && !submitted else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                submitAnswers()
            }
        }
        // Alert fires first, then navigates to ResultsView when dismissed
        .alert("Quiz Complete!", isPresented: $showScoreAlert) {
            Button("See Results") {
                showResults = true
            }
        } message: {
            Text("You got \(score) out of \(questions.count) correct!")
        }
        .navigationDestination(isPresented: $showResults) {
            ResultsView(
                questions: questions,
                selectedAnswers: selectedAnswers,
                score: score
            )
        }
    }

    // MARK: - Setup

    func setupAnswers() {
        shuffledAnswers = questions.map { question in
            (question.incorrectAnswers + [question.correctAnswer]).shuffled()
        }
    }

    // MARK: - Submit

    func submitAnswers() {
        timerRunning = false
        submitted = true
        score = calculateScore()
        showScoreAlert = true
    }

    func calculateScore() -> Int {
        var correct = 0
        for index in questions.indices {
            if selectedAnswers[index] == questions[index].correctAnswer {
                correct += 1
            }
        }
        return correct
    }
}

// MARK: - Answer Cell

struct AnswerCell: View {

    let answer: String
    let isSelected: Bool
    let isSubmitted: Bool
    let isCorrect: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(answer)
                    .foregroundStyle(.primary)
                Spacer()
                if isSubmitted {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if isSelected && !isCorrect {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.purple)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(rowBackground)
    }

    var rowBackground: Color {
        if isSubmitted {
            if isCorrect { return Color.green.opacity(0.15) }
            if isSelected && !isCorrect { return Color.red.opacity(0.15) }
        } else if isSelected {
            return Color.purple.opacity(0.15)
        }
        return Color(.systemBackground)
    }
}

#Preview {
    NavigationStack {
        QuizView(questions: [
            TriviaQuestion(
                category: "Science",
                type: "multiple",
                difficulty: "easy",
                question: "What is the chemical symbol for water?",
                correctAnswer: "H2O",
                incorrectAnswers: ["CO2", "NaCl", "O2"]
            )
        ])
    }
}
