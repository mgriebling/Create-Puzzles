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
				DatePicker("Date", selection: $lwords.date)
				Section("Word List (Tap to Edit)") {
					WordView(words: wordList)
						.onTapGesture {
							print("Tapped")
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
			.listSectionSpacing(0)
			.navigationTitle("Word List Editor")
			.onAppear {
				lwords = words
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
	@Previewable @State var words = Words(words: Game.words)
	WordsEditor(words: $words)
}
