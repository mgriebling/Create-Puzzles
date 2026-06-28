//
//  WordView.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct WordView: View {
	let words: [PlacedWord]
	var style: TextStyle = .columns
	var disappear: Bool = false   // disappear highlighted text
	
	@Environment(\.horizontalSizeClass) var size
	
	var body: some View {
		let fontSize: CGFloat = size == .compact ? 15 : 32
		if style == .columns {
			columnText(fontSize: fontSize)
			//.padding(.leading, size == .compact ? 35 : 75)
		} else {
			concatenatedText
				.font(.system(size: fontSize-3))
		}
	}
	
	private func columnText(fontSize: CGFloat) -> some View {
		let columns = Array(repeating: GridItem(.flexible(), alignment: .leading), count: size == .compact ? 3 : 5)
		return LazyVGrid(columns: columns, alignment: .trailing) {
			ForEach(words.indices, id: \.self) { index in
				let word = words[index]
				let textColor = word.highlighted ? Color(.gray) : .primary
				Text(word.word.capitalized)
					.foregroundColor(textColor)
					.font(.system(size: fontSize, weight: .bold))
					.strikethrough(word.highlighted)
			}
		}
	}
	
	// Reduces the array into a single concatenated Text view
	// From Goggle AI
	private var concatenatedText: Text {
		guard !words.isEmpty else { return Text("") }
		return words.enumerated().reduce(Text("")) { result, item in
			let (index, word) = item
			let textColor = word.highlighted ? Color(.gray) : .primary
			
			// 1. Create the styled word view
			let wordText = Text(word.word.capitalized)
				.foregroundColor(textColor)
				.strikethrough(word.highlighted)
			
			// 2. Add a comma and space if it is not the last item
			let separator = index < words.count - 1 ? Text(", ") : Text("")
			
			// 3. Concatenate to the running result
			return result + wordText + separator
		}
	}
	
	enum TextStyle {
		case columns, paragraph
	}
}

#Preview {
	let words: [PlacedWord] =
		SampleWordLists.all[1].words.enumerated().map { index, word in
			PlacedWord(word: word, id: index, highlighted: Bool.random())
		}
	WordView(words: words, style: .columns).padding(.bottom)
	WordView(words: words, style: .paragraph)
}


