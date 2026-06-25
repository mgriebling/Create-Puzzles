//
//  WordsEditor.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 22.06.2026.
//

import SwiftUI

struct WordsEditor: View {
	@Binding var words: Words
	var onDone: (() -> Void)?
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	
	@State private var lwords: Words = Words()
	@State private var name: String = ""
	@State private var wordList = [Word]()
	@State private var selectedLanguage = Language.english
	@State private var editWordList: Bool = false
	
    var body: some View {
        NavigationStack {
			Form {
				Section("Word List Name") {
					TextField("Word List Name", text: $lwords.name)
						.autocorrectionDisabled(true)
				}
				Section("Author") {
					TextField("Author", text: $lwords.author)
						.autocorrectionDisabled(true)
				}
				Section {
					DatePicker("Date", selection: $lwords.date,
							   displayedComponents: [.date])
				}
				Section {
					Picker("Language", selection: $selectedLanguage) {
						ForEach(Language.allCases, id: \.self) {
							Text($0.description.capitalized)
						}
					}
					.onSubmit {
						lwords.language = selectedLanguage
						print("Chose: \(selectedLanguage.description)")
					}
				}
				Section(header: Text("Word List (\(lwords.words.count))"),
						footer: Text("**Tap to edit the word list**")) {
					WordView(words: wordList)
						.onTapGesture {
							editWordList.toggle()
						}
						.sheet(isPresented: $editWordList) {
							NavigationStack {
								StringList(title: lwords.name, strings: $lwords.words)
							}
						}
				}
				.onChange(of: lwords) { oldValue, newValue in
					wordList = lwords.words.enumerated().map { id, word in
						Word(word: word, id: id, direction: .right)
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") {
						done()
						onDone?()
					}
				}
			}
			.navigationTitle("Word List Editor")
			.onAppear {
				lwords = words
				selectedLanguage = words.language
				wordList = words.words.enumerated().map { id, word in
					Word(word: word, id: id, direction: .right)
				}
			}
		}
    }
	
	func done() {
		lwords.words = wordList.map(\.word)
		words = lwords
		dismiss()
	}
}

#Preview {
	@Previewable @State var words = Game.words
	WordsEditor(words: $words)
}
