//
//  WordView.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct WordView: View {
	let words: [PlacedWord]
	
	@Environment(\.horizontalSizeClass) var size
	
	var body: some View {
		let fontSize: CGFloat = size == .compact ? 14 : 32
		let columns = Array(repeating: GridItem(.flexible(), alignment: .leading), count: size == .compact ? 4 : 5)
		LazyVGrid(columns: columns, alignment: .trailing) {
			ForEach(words.indices, id: \.self) { index in
				let word = words[index]
				let textColor = word.highlighted ? Color(.gray) : .primary
				Text(word.word.capitalized)
					.foregroundColor(textColor)
					.font(.system(size: fontSize, weight: .bold))
					.strikethrough(word.highlighted)
			}
		}
		.padding(.leading, size == .compact ? 25 : 75)
	}
}

#Preview {
	let words: [PlacedWord] =
		SampleWordLists.all[2].words.enumerated().map { index, word in
			PlacedWord(word: word, id: index)
		}
	WordView(words: words)
}


