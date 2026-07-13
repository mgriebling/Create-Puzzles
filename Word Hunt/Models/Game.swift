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
	init(board: GameBoard) {
		self.board = board
		self.timer = Timer()
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
				self.init(board: game.board)
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
		let wordsCount = Double(words.count)
		let wordScore = words.map({ Double($0.count) }).reduce(0, +) /
						(wordsCount * averageWordLength)
		let puzzleScore = Double(size) / SettingsType.maxGridRange.upperBound
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
	
	static var documentDirectory: URL? {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	}
	
	/// Saves the game to a file
	func save(to fileName: String) {
		// 2. Get the URL for the user's Documents directory
		guard let documentsDirectory = Self.documentDirectory else { return }
		
		// 3. Append the desired filename to the directory path
		let fileURL = documentsDirectory.appendingPathComponent("\(fileName).json")
		
		// 4. Initialize JSONEncoder and format the output
		let encoder = JSONEncoder()
		// encoder.outputFormatting = .prettyPrinted // Makes the JSON file human-readable
		
		do {
			// 5. Encode the class instance into raw Data
			let jsonData = try encoder.encode(self)
			
			// 6. Write the raw Data to disk
			try jsonData.write(to: fileURL, options: .atomic)
		} catch {
			print("Failed to write JSON file: \(error.localizedDescription)")
		}
	}
	
	static func save(games: [Game]) {
		games.forEach { game in
			game.save(to: game.name)
		}
	}
	
	static func loadGames() -> [Game] {
		guard let documentsURL = Self.documentDirectory else { return [] }
		let fileManager = FileManager.default
		do {
			let contents = try fileManager.contentsOfDirectory(at: documentsURL,
					includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
			
			// Filter for files with "json" extension (case-insensitive)
			let gameURLs = contents.filter { $0.pathExtension.lowercased() == "json" }
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
	
	func delete() {
		// 2. Get the URL for the user's Documents directory
		guard let documentsDirectory = Self.documentDirectory else { return }
		
		// 3. Append the desired filename to the directory path
		let fileURL = documentsDirectory.appendingPathComponent("\(self.name).json")
		
		try? FileManager.default.removeItem(at: fileURL)
	}
	
	func isWordMatch(start: CellIndex?) -> Bool {
		guard !activeWord.isEmpty, let start else { return false }
		let setElement = PlacedWord(word: activeWord, start: start).extended
		if placedSet.contains(setElement) {
//			board.highlightWord(index)
			return true
		}
		return false
	}
	
	func placeWords(words: [String]) -> [PlacedWord] {
		words.map { PlacedWord(word: $0) }
	}
	
	func copy() -> Game { Game(board: self.board) }
    func clearWord() { board.clearWord() }
//	func wordIsHighlighted(_ index: Int) -> Bool { board.ishighlighted(index) }
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
	
