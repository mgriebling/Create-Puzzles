//
//  GameCreationView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 19.07.2026.
//

import SwiftUI

struct GameCreationView: View {
	@Binding var games: [Game]
	let wordLists: [WordList]
	
	@State private var numberOfGames = 1
	@State private var wordListOption = 1
	@State private var size = 0
	@State private var sizes = [Int]()
	@State private var minSize = Int(SettingsType.maxGridRange.lowerBound)
	@State private var maxSize = Int(SettingsType.maxGridRange.upperBound)
	@State private var sizeToAdd: Int?
	@State private var level = 0
	@State private var wordList: WordList?
	@State private var wordListsToUse = [WordList]()
	
    var body: some View {
		NavigationStack {
			Form {
				Section("Number of Games") {
					Picker("Number of Games:", selection: $numberOfGames) {
						ForEach(1...10, id:\.self) { index in
							Text("\(index)").tag(index)
						}
					}
					.pickerStyle(.segmented)
				}
				Section("Difficulty") {
					Picker("Difficulty:", selection: $level) {
						Text("Man")
							.fixedSize(horizontal: true, vertical: false)
							.tag(0)
						ForEach(3...10, id:\.self) { index in
							Text("\(index)").tag(index)
						}
					}
					.pickerStyle(.segmented)
				}
				if level == 0 {
					Section("Puzzle Size") {
						Picker("Choose size:", selection: $size) {
							Text("Random").tag(0)
							Text("Random in range").tag(-1)
							Text("Selected Sizes").tag(-2)
							ForEach(SettingsType.maxGridRange, id:\.self) { index in
								Text("\(index) x \(index)").tag(index)
							}
						}
						if size == -1 {
							Stepper("Min: \(minSize) x \(minSize)", value: $minSize, in: SettingsType.maxGridRange)
							Stepper("Max: \(maxSize) x \(maxSize)", value: $maxSize, in: SettingsType.maxGridRange)
						} else if size == -2 {
							Picker("Size:", selection: $sizeToAdd) {
								ForEach(SettingsType.maxGridRange, id:\.self) { index in
									Text("\(index) x \(index)").tag(index)
								}
							}
							.onChange(of: sizeToAdd) {
								if let size = sizeToAdd {
									sizes.append(size)
								}
							}
							List(sizes, id: \.self) { size in
								Text("\(size) x \(size)")
							}
						}
					}
					Section("Word List to Use") {
						Picker("Word List to Use:", selection: $wordListOption) {
							Text("Random").tag(1)
							Text("Selected").tag(2)
						}
						.pickerStyle(.segmented)
						if wordListOption == 2 {
							Picker("Choose:", selection: $wordList) {
								ForEach(wordLists) { list in
									Text("\(list.name)").tag(list)
								}
							}
							.onChange(of: wordList) {
								if let words = wordList {
									wordListsToUse.append(words)
								}
							}
							
							List(wordListsToUse, id: \.self) { list in
								Text(list.name)
							}
						}
					}
				}
			}
			.toolbar {
				EditToolbar(onDone: createGames)
			}
			.navigationTitle(Text("Game Generator"))
			.navigationBarTitleDisplayMode(.inline)
		}
    }
	
	private func createGames() {
		if level > 0 {
			switch level {
				case 3: size = 5
				case 4: size = 6
				case 5: size = 9
				case 6: size = 11
				case 7: size = 12
				case 8: size = 15
				case 9: size = 18
				case 10: size = 20
				default: size = 4
			}
			sizes = Array(repeating: size, count: numberOfGames)
			wordListOption = 1
		}
		if size == 0 || size == -1 {
			for _ in 0..<numberOfGames {
				sizes.append(Int.random(in: minSize...maxSize))
			}
		}
		while sizes.count < numberOfGames {
			sizes.append(contentsOf: sizes)
		}
		if wordListOption == 1 {
			for _ in 0..<numberOfGames {
				wordListsToUse.append(wordLists.randomElement()!)
			}
		}
		while wordListsToUse.count < numberOfGames {
			wordListsToUse.append(contentsOf: wordListsToUse)
		}
		
		// generate games in the background
		Task.detached(priority: .background) {
			var numberOfGames = await self.numberOfGames
			var sizes = await self.sizes
			var wordListsToUse = await self.wordListsToUse
			while numberOfGames > 0 {
				print("Generating game...")
				let game = Game(board: GameBoard(size: sizes.removeFirst(), words: wordListsToUse.removeFirst()))
				await MainActor.run {
					print("Adding game \(game.name)")
					self.games.insert(game, at: 0)
				}
				numberOfGames -= 1
			}
		}
//
//		for game in games {
//			print(game.name, "Level: \(game.level) \(game.board.size) x \(game.board.size)")
//		}
	}
}

#Preview {
	@Previewable @State var games = [Game]()
	GameCreationView(games: $games, wordLists: SampleWordLists.all)
}
