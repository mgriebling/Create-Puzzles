//
//  WordView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct WordView: View {
	let words: [PlacedWord]
	var style: TextStyle = .columns
	
	static let width: CGFloat = 130
	
	@State var width = Self.width
	
	var body: some View {
		if style == .columns {
			columnText()
				.flexibleSystemFont(maximum: 15)
		} else {
			concatenatedText
				.flexibleSystemFont(maximum: 15)
		}
	}
	
	@ViewBuilder
	private func columnText() -> some View {
		let columns = [
			GridItem(.adaptive(minimum: width, maximum: .infinity), spacing: 0)
		]
		ScrollView {
			LazyVGrid(columns: columns, alignment: .leading) {
				ForEach(words.indices, id: \.self) { index in
					let word = words[index]
					let textColor = word.highlighted ? Color(.gray) : .primary
					Text(word.word.capitalized)
						.foregroundColor(textColor)
						.strikethrough(word.highlighted)
						.lineLimit(1)
				}
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
		SampleWordLists.all[10].words.enumerated().map { index, word in
			PlacedWord(word: word, highlighted: Bool.random())
		}
	WordView(words: words, style: .columns).padding(.bottom)
	WordView(words: words, style: .paragraph)
}


