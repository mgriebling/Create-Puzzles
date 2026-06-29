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
	var columns: Int = -1
	
	@Environment(\.horizontalSizeClass) var size
	
	var body: some View {
		let fontSize: CGFloat = size == .compact ? 15 : 18
		if style == .columns {
			columnText(fontSize: fontSize)
		} else {
			concatenatedText
				.flexibleSystemFont(maximum: fontSize)
		}
	}
	
	private func columnText(fontSize: CGFloat) -> some View {
		let columnCount = columns != -1 ? columns : size == .compact ? 3 : 6
		let columns = Array(repeating: GridItem(.flexible(), alignment: .leading),
							count: columnCount)
		return LazyVGrid(columns: columns, alignment: .trailing) {
			ForEach(words.indices, id: \.self) { index in
				let word = words[index]
				let textColor = word.highlighted ? Color(.gray) : .primary
				Text(word.word.capitalized)
					.foregroundColor(textColor)
					.flexibleSystemFont(maximum: fontSize)
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
			let separator = index < words.count - 1 ?
				Text(", ").foregroundColor(textColor) : Text("")
			
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


