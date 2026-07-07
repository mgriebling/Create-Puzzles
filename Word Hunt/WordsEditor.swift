//
//  WordsEditor.swift
//  Word Hunt
//
//  Created by Michael Griebling on 22.06.2026.
//

import SwiftUI

struct WordsEditor: View {
	@Binding var words: WordList?
	@Binding var selectedTab: Tabs
	var onDone: (() -> Void)?
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	
	@State private var lwords: WordList = WordList()
	@State private var name: String = ""
	@State private var wordList = [PlacedWord]()
	@State private var selectedLanguage = Language.english
	@State private var editWordList: Bool = false
	
	var body: some View {
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
			Section(header: Text("Word List (\(lwords.words.count))")) {
				// WordView(words: wordList, style: .paragraph)
				StringList(title: lwords.name, strings: $lwords.words)
					.frame(height: 300)
			}
			.onChange(of: lwords) { oldValue, newValue in
				wordList = lwords.words.map { PlacedWord(word: $0) }
				if onDone == nil {
					// update passed word list directly
					words = lwords
				}
			}
		}
		
//		.navigationTitle("Word List Editor")
//#if os(iOS)
//		.navigationBarTitleDisplayMode(.inline)
//#endif
		.toolbar {
			ToolbarItem(placement: .principal) {
				TabTitle(selectedTab: $selectedTab)
			}
			// EditToolbar { done() }
		}
		.onAppear {
			if let words {
				lwords = words
				selectedLanguage = lwords.language
				wordList = lwords.words.map { PlacedWord(word: $0) }
			}
		}
	}
	
//	func done() {
//		lwords.words = wordList.map(\.word)
//		words = lwords
//		onDone?()
//		dismiss()
//	}
}

#Preview {
	@Previewable @State var words = SampleWordLists.all.randomElement()
	NavigationStack {
		WordsEditor(words: $words, selectedTab: .constant(.wordLists))
	}
}
