//
//  WordList.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct WordLists: View {
	// MARK: Data Shared with Me
	@Binding var selection: WordList?
	
	@State private var wordLists = [WordList]()
	@State private var wordListToEdit = WordList()
	@State private var showWordListEditor: Bool = false
	@State private var originalWordList: WordList? = nil
	
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
				wordLists = SampleWordLists.all
				selection = wordLists[Int.random(in: 0..<wordLists.count)]
			}
		}
    }
	
	func editButton(for wordList: WordList) -> some View {
		Button("Edit", systemImage: "pencil") {
			originalWordList = wordList
			wordListToEdit = wordList
			showWordListEditor.toggle()
		}
	}
	
	func deleteButton(for wordList: WordList) -> some View {
		Button("Delete", systemImage: "minus.circle", role: .destructive) {
			withAnimation {
				wordLists.removeAll { $0 == wordList }
			}
		}
	}
	
	var addButton: some View {
		Button("Add Word List", systemImage: "plus") {
			wordListToEdit = WordList(name: "Untitled", words: ["word1", "word2", "word3"])
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
	

}

#Preview {
	@Previewable @State var selection: WordList?
	NavigationStack {
		WordLists(selection: $selection)
	}
}
