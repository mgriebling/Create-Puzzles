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
	@State private var isLoading: Bool = false
	
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
				}
				.onChange(of: size) {
					withAnimation { updateGame() }
				}
				Picker("Word List", selection: $selectedWords) {
					ForEach(words, id: \.self) { words in
						Text(words.name)
					}
				}
				.onChange(of: selectedWords) {
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
					ZStack {
						LetterGridView(game: lgame)
						if isLoading {
							Color(.systemBackground).opacity(0.5)
								.ignoresSafeArea()
							ProgressView("Performing layout...")
								.padding(20)
								.background(Color(.systemBackground))
								.cornerRadius(10)
								.shadow(radius: 10)
								.offset(CGSize(width: 0, height: -100))
								.controlSize(.large)
						}
					}
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
		// guard Int(size) != lgame.board.size else { return }
		isLoading = true
		Task.detached {
			let updatedGame = await Game(board: GameBoard(size: Int(size), words: selectedWords))
			await MainActor.run {
				self.lgame = updatedGame
				isLoading = false
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
