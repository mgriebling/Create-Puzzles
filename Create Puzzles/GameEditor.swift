//
//  GameEdiroe.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 24.06.2026.
//

import SwiftUI

struct GameEditor: View {
	@Binding var game: Game
	
	@State private var lgame = Game(board: GameBoard(size: 10)!)
	@State private var selectedWords: Words = .init()
	@State private var words = [Words]()
	@State private var wordList = [Word]()
	@State private var size = 10.0
	
	let range = 10.0...20.0
	
    var body: some View {
        Form {
			Section(header: Text("\(selectedWords.name) Game")) {
				Text("Rows/Columns = \(Int(size))")
				Slider(value: $size, in: range) {
					Text("Row/Columns:")
				} minimumValueLabel: {
					Text("\(Int(range.lowerBound))")
				} maximumValueLabel: {
					Text("\(Int(range.upperBound))")
				}
				Picker("Word List", selection: $selectedWords) {
					ForEach(words, id: \.self) { words in
						Text(words.name)
					}
				}
				.onChange(of: selectedWords) { oldValue, newValue in
					print("Selected: \(newValue.name)")
					withAnimation {
						wordList = []
						for (id, word) in selectedWords.words.enumerated() {
							wordList.append(Word(word: word, id: id))
						}
					}
				}
				WordView(words: wordList)
			}
			Section(header: Text("Game Board Layout")) {
				LetterGridView(game: game, fontSize: 12, cellSize: 20, noDrag: true)
			}
		}
		.onAppear {
			lgame = game
			size = Double(game.board.size)
			words = WordLists.createSampleWordLists()
			selectedWords = words.first!
		}
		.navigationTitle(Text("Game Editor"))
    }
}

#Preview {
	@Previewable @State var game = Game(board: GameBoard(size: 12, words: Game.words)!)
	NavigationStack {
		GameEditor(game: $game)
	}
}
