//
//  OptionsView.swift
//  TriviaApp
//
//  Created by Ludlyne Alysha Janvier on 4/4/26.
//

import SwiftUI

struct OptionsView: View {

    @State private var numberOfQuestions = 10
    @State private var selectedCategory = "Any"
    @State private var selectedDifficulty = "Any"
    @State private var selectedType = "Any"

    @State private var questions: [TriviaQuestion] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showQuiz = false

    let categories = [
        "Any", "General Knowledge", "Science & Nature", "History",
        "Sports", "Geography", "Entertainment: Film", "Entertainment: Music",
        "Entertainment: Books", "Entertainment: TV", "Science: Computers",
        "Science: Mathematics", "Animals", "Vehicles", "Mythology"
    ]

    let categoryIDs: [String: Int] = [
        "Any": 0, "General Knowledge": 9, "Entertainment: Books": 10,
        "Entertainment: Film": 11, "Entertainment: Music": 12,
        "Entertainment: TV": 14, "Science & Nature": 17,
        "Science: Computers": 18, "Science: Mathematics": 19,
        "Mythology": 20, "Sports": 21, "Geography": 22,
        "History": 23, "Animals": 27, "Vehicles": 28
    ]

    let difficulties = ["Any", "Easy", "Medium", "Hard"]
    let types = ["Any", "Multiple Choice", "True / False"]

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Number of Questions
                Section("Number of Questions") {
                    Stepper("\(numberOfQuestions) Questions", value: $numberOfQuestions, in: 5...20, step: 5)
                        .tint(.purple)
                }

                // MARK: Category
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .accentColor(.purple)
                }

                // MARK: Difficulty
                Section("Difficulty") {
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Text(difficulty)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: Question Type
                Section("Question Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: Start Button
                Section {
                    Button(action: fetchQuestions) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                Text("Loading...")
                                    .bold()
                                    .foregroundStyle(.white)
                            } else {
                                Text("Start Game")
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .background(Color.purple, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(isLoading)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Trivia Challenge")
            .tint(.purple)
            .alert("Oops!", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .navigationDestination(isPresented: $showQuiz) {
                QuizView(questions: questions)
            }
        }
    }

    // MARK: - Fetch Questions from Open Trivia DB

    func fetchQuestions() {
        isLoading = true

        var urlString = "https://opentdb.com/api.php?amount=\(numberOfQuestions)"

        if let catID = categoryIDs[selectedCategory], catID != 0 {
            urlString += "&category=\(catID)"
        }

        if selectedDifficulty != "Any" {
            urlString += "&difficulty=\(selectedDifficulty.lowercased())"
        }

        if selectedType == "Multiple Choice" {
            urlString += "&type=multiple"
        } else if selectedType == "True / False" {
            urlString += "&type=boolean"
        }

        guard let url = URL(string: urlString) else {
            isLoading = false
            errorMessage = "Invalid URL."
            showError = true
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received."
                    showError = true
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
                    if decoded.responseCode == 0 {
                        questions = decoded.results
                        showQuiz = true
                    } else {
                        errorMessage = "Not enough questions for these settings. Try different options."
                        showError = true
                    }
                } catch {
                    errorMessage = "Failed to parse questions."
                    showError = true
                }
            }
        }.resume()
    }
}

#Preview {
    OptionsView()
}
