//
//  WordList.swift
//  Word Hunt
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct WordListView: View {
	// MARK: Data Shared with Me
	@Binding var selection: WordList?
	@Binding var wordLists: [WordList]
	
	@State private var wordListToEdit: WordList? = WordList()
	@State private var showWordListEditor: Bool = false
	@State private var listItem: WordList?
	// @State private var originalWordList: WordList? = nil
	
	var body: some View {
		List(selection: $listItem) {
			ForEach(wordLists, id: \.self) { wordList in
				NavigationLink(value: wordList) {
					WordListSummary(wordList: wordList)
				}
				//					.contextMenu {
				//						editButton(for: selection) // editing a word list
				//						deleteButton(for: selection)
				//					}
				//					.swipeActions(edge: .leading) {
				//						editButton(for: wordList).tint(.accentColor)
				//					}
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
		.onChange(of: listItem) { _, newValue in
			if let value = newValue {
				selection = value
			}
		}
		//			.onChange(of: selection) {
		//				if let selection, !wordLists.contains(selection) {
		//					self.selection = nil
		//				}
		//			}
		.listStyle(.plain)
		.toolbar {
			addButton
			//#if os(iOS)
			//				EditButton()
			//#endif
		}
		//			.onAppear {
		//				if wordLists.isEmpty {
		//					wordLists = SampleWordLists.all
		//					//selection = wordLists[Int.random(in: 0..<wordLists.count)]
		//				}
		//			}
	}
		
	func editButton(for wordList: WordList) -> some View {
		Button("Edit", systemImage: "pencil") {
			if let selection {
				//			originalWordList = wordList
				wordListToEdit = selection.copy()
				showWordListEditor.toggle()
			}
		}
	}
	
	func deleteButton(for wordList: WordList) -> some View {
		Button("Delete", systemImage: "minus.circle", role: .destructive) {
			withAnimation {
				wordLists.removeAll { $0 == wordList }
			}
		}
	}
	
	func uniqueName(for name: String) -> String {
		var number = 0
		while number < 100 {
			let name = name + (number > 0 ? " \(number)" : "")
			if !wordLists.contains(where: { $0.name == name }) {
				return name
			} else {
				// increment number and try again
				number += 1
			}
		}
		return ""
	}
	
	var addButton: some View {
		Button("Add Word List", systemImage: "plus") {
			let name = uniqueName(for: "Random")
			wordListToEdit = WordList(name: name, wordRange: 3...7, totalWords: 50)
			showWordListEditor = true
		}
		.sheet(isPresented: $showWordListEditor) {
			WordsEditor(words: $wordListToEdit) {
				if let index = wordLists.firstIndex(of: wordListToEdit!) {
					// word list already exists
					wordLists[index] = wordListToEdit!
				} else {
					// add new word list
					wordLists.insert(wordListToEdit!, at: 0)
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var selection = SampleWordLists.all.first
	@Previewable @State var words = SampleWordLists.all
	NavigationStack {
		WordListView(selection: $selection, wordLists: $words)
	}
}
