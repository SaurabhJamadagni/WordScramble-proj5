//
//  ContentView.swift
//  WordScramble
//
//  Created by Saurabh Jamadagni on 26/07/22.
//

// Personal TODO list:
// 1. Make changes so that the keyboard is not dismissed when return is pressed every time. Very annoying if I have to add consecutive words.
    // Add a done button that dismissed the keyboard.

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addWord)
            .onAppear(perform: startGame)   // loads this function when the view is loaded
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .toolbar {
                Button(role: .destructive) {
                    restartGame()
                } label: {
                    Text("Restart")
                    Image(systemName: "gobackward")
                }
            }
        }
    }
    
    func addWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Not again! Think.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Not possible", message: "Thinking too outside the box eh?")
            return
        }
        
        guard isLegit(word: answer) else {
            wordError(title: "Spelling error", message: "Reread that, will you luv?")   // Have been watching The Boys a lot lately haha
            return
        }
        
        guard !isRootWord(word: answer) else {
            wordError(title: "Used the root word!", message: "You can do better mate.")
            return
        }
        
        guard isAppropriateLength(word: answer) else {
            wordError(title: "Word too short!", message: "Think big. Go large!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        // Check if the file is present
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Check if the file has contents
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        // We create a copy of the rootword
        var tempWord = rootWord
        
        // iterate over each letter in the passed word
        for letter in word {
            // Check if the letter is present in the root word
            if let pos = tempWord.firstIndex(of: letter) {
                // if yes remove the letter after using it from the root word so it isn't used again
                tempWord.remove(at: pos)
            } else {
                // if not return false word can not be used.
                return false
            }
        }
        
        // If you come out of the root, word is possible
        return true
    }
    
    func isLegit(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        // if NSNotFound, it means there is a legit word as no error was found
        // therefore we want it to be NSNotFound. This means the word is legit.
        return misspelledRange.location == NSNotFound
    }
    
    func isRootWord(word: String) -> Bool {
        return word == rootWord
    }
    
    func isAppropriateLength(word: String) -> Bool {
        return word.count >= 3
    }
    
    func wordError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    func restartGame() {
        newWord = ""
        usedWords.removeAll()
        startGame()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
