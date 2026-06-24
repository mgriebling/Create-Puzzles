//
//  WordList.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct WordLists: View {
	// MARK: Data Shared with Me
	@Binding var selection: Words?
	
	@State private var wordLists: [Words] = []
	@State private var wordListToEdit: Words = .init()
	@State private var showWordListEditor: Bool = false
	@State private var originalWordList: Words? = nil
	
    var body: some View {
		List(selection: $selection) {
			ForEach(wordLists, id: \.self) { wordList in
				NavigationLink(value: wordList) {
					WordListSummary(wordList: wordList)
				}
				.contextMenu {
					editButton(for: wordList) // editing a word list
					deleteButton(for: wordList)
				}
				.swipeActions(edge: .leading) {
					editButton(for: wordList).tint(.accentColor)
				}
			}
			.onDelete { indexSet in
				indexSet.forEach { index in
					wordLists.remove(at: index)
				}
			}
			.onMove { offsets, destination in
				wordLists.move(fromOffsets: offsets, toOffset: destination)
			}
		}
		.navigationTitle("Word Lists")
		.onChange(of: wordLists) {
			if let selection, !wordLists.contains(selection) {
				self.selection = nil
			}
		}
		.listStyle(.plain)
		.toolbar {
			addButton
			#if !os(macos)
			EditButton()
			#endif
		}
		.onAppear {
			if wordLists.isEmpty {
				wordLists = Self.createSampleWordLists()
				selection = wordLists[Int.random(in: 0..<wordLists.count)]
			}
		}
    }
	
	func editButton(for wordList: Words) -> some View {
		Button("Edit", systemImage: "pencil") {
			originalWordList = wordList
			wordListToEdit = wordList
			showWordListEditor.toggle()
		}
	}
	
	func deleteButton(for wordList: Words) -> some View {
		Button("Delete", systemImage: "minus.circle", role: .destructive) {
			withAnimation {
				wordLists.removeAll { $0 == wordList }
			}
		}
	}
	
	var addButton: some View {
		Button("Add Word List", systemImage: "plus") {
			wordListToEdit = Words(name: "Untitled", words: ["word1", "word2", "word3"])
			showWordListEditor.toggle()
		}
		.sheet(isPresented: $showWordListEditor) {
			WordsEditor(words: $wordListToEdit) {
				if let list = originalWordList,
				   let index = wordLists.firstIndex(of: list) {
					// word list already exists
					wordLists[index] = wordListToEdit
					originalWordList = nil
				} else {
					// add new word list
					wordLists.insert(wordListToEdit, at: 0)
				}
			}
		}
	}
	
	static func createSampleWordLists() -> [Words] {
		var wordLists: [Words] = []
		wordLists.append(Words(name: "Numbers", words: ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]))
		wordLists.append(Words(name: "Colors", words: ["red", "blue", "green", "yellow", "orange", "purple", "pink", "brown", "black", "white"]))
		wordLists.append(Words(name: "Alphabet Codes", words: Game.words))
		wordLists.append(Words(name: "Animals", words: ["dog", "cat", "snake", "elephant", "kangaroo", "penguin", "octopus", "penguin", "koala", "penguin", "horse", "cow", "donkey"]))
		return wordLists
	}
}

#Preview {
	@Previewable @State var selection: Words?
	NavigationStack {
		WordLists(selection: $selection)
	}
}
