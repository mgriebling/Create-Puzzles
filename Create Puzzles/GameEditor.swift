//
//  GameEdiroe.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 24.06.2026.
//

import SwiftUI

struct GameEditor: View {
	@Binding var game: Game
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	
	// MARK: Size Range (should be global somewhere else)
	static let range = 10.0...20.0
	
	@State private var lgame = Game(board: GameBoard(size: Int(range.lowerBound)))
	@State private var selectedWords: WordList = .init()
	@State private var words = [WordList]()
	@State private var wordList = [PlacedWord]()
	@State private var size = range.lowerBound
	@State private var actualSize: CGSize = .zero
	
    var body: some View {
        Form {
			Section(header: Text("\(selectedWords.name) Game")) {
				Text("\(Int(size)) Rows/Columns")
				Slider(value: $size, in: Self.range, step: 1) {
					Text("Row/Columns:")
				} minimumValueLabel: {
					Text("\(Int(Self.range.lowerBound))")
				} maximumValueLabel: {
					Text("\(Int(Self.range.upperBound))")
				} onEditingChanged: { changed in
					if changed || size == 10 { // Bug? Doesn't change at minimum
						withAnimation { updateGame() }
					}
				}

				Picker("Word List", selection: $selectedWords) {
					ForEach(words, id: \.self) { words in
						Text(words.name)
					}
				}
				.onChange(of: selectedWords) { _, newValue in
					withAnimation {
						wordList = []
						for (id, word) in selectedWords.words.enumerated() {
							wordList.append(PlacedWord(word: word, id: id))
						}
						updateGame()
					}
				}
				WordView(words: wordList)
			}
			Section(header:
				VStack(alignment: .leading, spacing: 0) {
					HStack {
						Text("Game Board Layout")
						Button("Layout Again") { withAnimation { updateGame() } }
					}
					let missing = lgame.board.missingWords
					if !missing.isEmpty {
						Text("Missing \(missing.count): \(missing.joined(separator: ", "))")
					}
				})
				{
					LetterGridView(game: lgame)
				}
		}
		.onAppear {
			lgame = game
			size = Double(game.board.size)
			if words.isEmpty {
				words = WordLists.createSampleWordLists()
			}
			if !words.contains(game.board.words) {
				words.insert(game.board.words, at: 0)
			}
			selectedWords = game.board.words
			updateGame()
		}
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") { dismiss() }
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Done") { done() }
			}
		}
		.navigationTitle(Text("Game Editor"))
		.navigationBarTitleDisplayMode(.inline)
    }
	
	func done() {
		game = lgame
		dismiss()
	}
	
	func updateGame() {
		Task.detached {
			let updatedGame = await Game(board: GameBoard(size: Int(size), words: selectedWords))
			await MainActor.run {
				self.lgame = updatedGame
			}
		}
		
	}
}

#Preview {
	@Previewable @State var game = Game(board: GameBoard(size: 12))
	NavigationStack {
		GameEditor(game: $game)
	}
}
