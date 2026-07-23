//
//  Game.swift
//  Word Hunt
//
//  Created by Mike Griebling on 2022-11-09.
//

import SwiftUI

@Observable class Game {
	var board: GameBoard
	var timer: Timer
	
	// MARK: Convenience attributes
	var activeWord: String 		  { board.selectedWord }
	var words: [String] 		  { board.wordPlacements.map(\.word) }
	var placedWords: [PlacedWord] { board.wordPlacements }
	var size: Int		   		  { board.size }
	var name: String			  { board.words.name }
	var matched: Int 			  { placedWords.filter(\.highlighted).count }
	var isOver: Bool 		  	  { matched == words.count }
	var placedSet: Set<String> 	  { Set(placedWords.map({ $0.extended })) }
	
	// MARK: Initializer
	init(level: Difficulty, words: WordList) {
		self.board = GameBoard(size: level.size, words: words)
		self.timer = Timer()
	}
	
	init(size: Int, words: WordList) {
		let limitedSize = max(SettingsType.maxGridRange.lowerBound,
					   min(size, SettingsType.maxGridRange.upperBound))
		self.board = GameBoard(size: limitedSize, words: words)
		self.timer = Timer()
	}
	
	/// Copies a game
	init(game: Game) {
		self.board = game.board
		self.timer = game.timer
	}
	
	// MARK: Required for manual Codable compliance, warning issued otherwise
	required init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.board = try container.decode(GameBoard.self, forKey: .board)
		self.timer = try container.decode(Timer.self, forKey: .timer)
	}
	
	convenience init?(from file: URL) {
		if let rawData = try? Data(contentsOf: file) {
			let decoder = JSONDecoder()
			if let game = try? decoder.decode(Game.self, from: rawData) {
				print("Loaded game: \(game.name)")
				self.init(game: game)
			} else {
				// remove corrupted file
				try? FileManager.default.removeItem(at: file)
			}
		}
		return nil
	}
	
	var level: Int {
		// first calculate average difficulty of the words (5 is typical word length)
		let averageWordLength = 6.0
		let low = SettingsType.maxGridRange.lowerBound
		let high = SettingsType.maxGridRange.upperBound
		let wordsCount = Double(words.count)
		let wordScore = words.map({ Double($0.count) }).reduce(0, +) /
						(wordsCount * averageWordLength)
		let puzzleScore = Double(size - low) / Double(high - low)
		let numberOfWordsScore = wordsCount / Double(board.words.words.count)
		let total = wordScore + puzzleScore + numberOfWordsScore
		return min(10, Int((10.0 / 3.0) * total + 0.5))
	}

    func removeActiveWord() {
		if let index = words.firstIndex(of: activeWord.lowercased()) {
			board.highlightWord(index)
            board.clearWord()
        }
    }
	
	/// Saves the game to a file
	func save(to fileName: String) {
		let encoder = JSONEncoder()
		// encoder.dataEncodingStrategy = .deferredToData
		// encoder.outputFormatting = .prettyPrinted // Makes the JSON file human-readable
		
		do {
			// 5. Encode the class instance into raw Data
			let jsonData = try encoder.encode(self)
			
			// 6. Write the raw Data to disk
			try jsonData.write(to: url, options: .atomic)
		} catch {
			print("Failed to write JSON file: \(error.localizedDescription)")
		}
	}
	
	static var documentDirectory: URL? {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	}
	
	static var fileExt: String { "wordhunt" }
	
	var url: URL {
		Self.documentDirectory!.appendingPathComponent("\(name).\(Self.fileExt)")
	}
	
	static func save(games: [Game]) { games.forEach { $0.save(to: $0.name) } }
	
	static func loadGames() -> [Game] {
		guard let documentsURL = Self.documentDirectory else { return [] }
		let fileManager = FileManager.default
		do {
			let contents = try fileManager.contentsOfDirectory(at: documentsURL,
					includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
			
			// Filter for files with extension (case-insensitive)
			let gameURLs = contents.filter { $0.pathExtension.lowercased() == Self.fileExt }
			var games = [Game]()
			for url in gameURLs {
				if let game = Game(from: url) {
					games.append(game)
				}
			}
			return games
		} catch {
			print("Error reading directory: \(error)")
			return []
		}
	}
	
	func delete() { try? FileManager.default.removeItem(at: url) }
	
	func isWordMatch(start: CellIndex?, end: CellIndex?) -> Bool {
		guard !activeWord.isEmpty, let start, let end else { return false }
		let setElement1 = PlacedWord(word: activeWord, start: start).extended
		let setElement2 = PlacedWord(word: activeWord, start: end).extended
		if placedSet.contains(setElement1) || placedSet.contains(setElement2) {
			return true
		}
		return false
	}
	
	func placeWords(words: [String]) -> [PlacedWord] {
		words.map { PlacedWord(word: $0) }
	}
	
	func copy() -> Game { Game(game: self) }
    func clearWord() { board.clearWord() }
}

extension Game: Identifiable { }  // auto-generated

extension Game: Equatable {
	static public func == (lhs: Game, rhs: Game) -> Bool {
		lhs.id == rhs.id
	}
}

extension Game: Codable {

	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(board, forKey: .board)
		try container.encode(timer, forKey: .timer)
	}
	
	enum CodingKeys: String, CodingKey { case board, timer }
}

extension Game: Hashable {
	func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
	
