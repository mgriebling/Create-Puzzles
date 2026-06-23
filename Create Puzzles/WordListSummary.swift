//
//  WordListSummary.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct WordListSummary: View {
	let wordList: Words
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(wordList.name).font(.title)
			Text("Author: \(wordList.author)")
			// Text("Created: \(wordList.date, format: )")
			Text("\(wordList.words.count) words (\(wordList.language.description))")
			Text(wordList.words.map({ $0.capitalized }).joined(separator: ", "))
				.font(.caption)
		}
		.padding(.horizontal)
	}
}

#Preview {
	@Previewable @State var wordList = Words(language: .english, author: "Michael Griebling", date: Date(), words: Game.words)
    WordListSummary(wordList: wordList)
}
