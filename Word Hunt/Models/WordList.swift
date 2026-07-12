//
//  Words.swift
//  Word Hunt
//
//  Created by Michael Griebling on 22.06.2026.
//

import Foundation
import NaturalLanguage

struct CellIndex: Equatable, Codable, Hashable, CustomStringConvertible {

	let row: Int
	let col: Int
	
	var description: String { "(\(row),\(col))" }
	
	init() { self.init(row: 0, col: 0) }
	
	init(row: Int, col: Int) {
		self.row = row
		self.col = col
	}
}

struct PlacedWord: Codable, Identifiable, Hashable {
	let id: UUID
	let word: String
	let start: CellIndex
	let end: CellIndex
	let direction: Direction
	var highlighted: Bool
	
	init(word:String, start:CellIndex = CellIndex(), end:CellIndex = CellIndex(),
		 direction: Direction = .right, highlighted:Bool = false) {
		self.word = word.lowercased()
		self.start = start
		self.end = end
		self.highlighted = highlighted
		self.direction = direction
		self.id = UUID()
	}
	
	init(word:String, start:CellIndex = CellIndex(), direction:Direction, highlighted:Bool = false) {
		let len = max(0, word.count - 1)
		let end = CellIndex(row: start.row + (len * direction.deltaRow),
							col: start.col + (len * direction.deltaCol))
		self.init(word: word, start: start, end: end, direction: direction, highlighted: highlighted)
	}
}

public enum Direction: Int, Codable, CaseIterable {
	case left, right, down, up, diagonalUpLeft, diagonalUpRight,
		 diagonalDownLeft, diagonalDownRight
	
	var deltaCol: Int {
		switch self {
			case .left, .diagonalUpLeft, .diagonalDownLeft: return -1
			case .right, .diagonalUpRight, .diagonalDownRight: return 1
			case .up, .down: return 0
		}
	}
	
	var deltaRow: Int {
		switch self {
			case .down, .diagonalDownLeft, .diagonalDownRight: return 1
			case .up, .diagonalUpLeft, .diagonalUpRight: return -1
			case .left, .right: return 0
		}
	}
	
	static func random() -> Direction { Direction.allCases.randomElement()! }
}

public enum Language: String, Codable, CaseIterable, CustomStringConvertible {

	case english = "en", german = "de", spanish = "es", swedish = "sv"
	case norwegian = "no", italian = "it", french = "fr", japanese = "ja"
	case chinese = "zh", russian = "ru", hindi = "hi"
	case afrikaans = "af", arabic = "ar", greek = "el"
	case dutch = "nl", polish = "pl", hungarian = "hu"
	case slovak = "sk", romanian = "ro", danish = "da"
	case bulgarian = "bg", burmese = "my", cambodian = "km", czech = "cs"
	case estonian = "et", finnish = "fi", farsi = "fa", indonesian = "id"
	case hebrew = "he", icelandic = "is", korean = "ko", kurdish = "ku"
	case lithuanian = "lt", macedonian = "mk", mongolian = "mn"
	case navajo = "nv", portuguese = "pt", serbian = "sr", swahili = "sw"
	case turkish = "tr", ukrainian = "uk", vietnamese = "vi"
	case tibetan = "bo", yiddish = "yi"
	
	var alphabet: String { Alphabets.getAlphabet(for: self.rawValue) }
	
	public var description: String {
		let myLocale = Locale.current
		let name = myLocale.localizedString(forLanguageCode: self.rawValue)
		return name ?? "Unknown"
	}
	
	public static func getLanguage(from text: String) -> Language? {
		if let languageCode = NLLanguageRecognizer.dominantLanguage(for: text) {
			return Language(rawValue: languageCode.rawValue)
		} else {
			return nil
		}
	}
}

extension String {
	var trailingDigits: String {
		String(self.reversed().prefix(while: { $0.isNumber }).reversed())
	}
	
	var removeTrailingDigits: String {
		let trailingDigits = self.trailingDigits
		return String(self.dropLast(trailingDigits.count))
	}
}

@Observable public class WordList: Codable {
	public var name: String {
		get {
			if revision == 0 { return _name }
			return "\(_name)\(revision)"
		}
		set {
			var value = newValue
			if let revision = Int(newValue.trailingDigits) {
				self.revision = revision
				value = newValue.removeTrailingDigits
			}
			_name = value
		}
	}
	private var _name: String		// internal name
	public var language: Language
	public var author: String
	public var date: Date
	public var words: [String]
	private var revision: Int = 0
	
	public var averageLength: Double {
		words.map({ Double($0.count) }).reduce(0, +) / Double(words.count)
	}
	
	convenience init() {
		self.init(name: "Empty", language: .english,
				  author: "Unknown", date: Date(), words: [])
	}
	
	/// Create a copy of words
	convenience init(words: WordList) {
		self.init(name: words.name, language: words.language,
			 author: words.author, date: words.date, words: words.words)
	}
	
	convenience init?(from file: URL) {
		if let rawData = try? Data(contentsOf: file) {
			let decoder = JSONDecoder()
			if let wordList = try? decoder.decode(WordList.self, from: rawData) {
				print("Loaded word List: \(wordList.name)")
				self.init(words: wordList)
				return
			} else {
				// remove corrupted file
				try? FileManager.default.removeItem(at: file)
			}
		}
		return nil
	}
	
	init(name: String = "Empty", language: Language = .english,
		 author: String = "Unknown", date: Date = Date(), words: [String]) {
		self._name = name
		self.language = language
		self.author = author
		self.date = date
		self.words = words
	}
	
	/// Get word list with random words of a certain size (i.e., wordRange)
	init(name: String = "Empty", language: Language = .english,
		 author: String = "Unknown", date: Date = Date(),
		 wordRange: CountableClosedRange<Int>, totalWords: Int) {
		print("Creating word list")
		self._name = name
		self.language = language
		self.author = author
		self.date = date
		self.words = Self.generateWords(with: wordRange, total: totalWords)
	}
	
	/// Creates a copy of the word list
	func copy() -> WordList { WordList(words: self) }
	
	static var documentDirectory: URL? {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	}
	
	/// Saves the word list to a file
	func save(to fileName: String) {
		// 2. Get the URL for the user's Documents directory
		guard let documentsDirectory = Self.documentDirectory else { return }
		
		// 3. Append the desired filename to the directory path
		let fileURL = documentsDirectory.appendingPathComponent("\(fileName).wlist")
		
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
	
	func reviseName() {
		revision += 1
	}
	
	func delete() {
		// 2. Get the URL for the user's Documents directory
		guard let documentsDirectory = Self.documentDirectory else { return }
		
		// 3. Append the desired filename to the directory path
		let fileURL = documentsDirectory.appendingPathComponent("\(self.name).wlist")
		
		try? FileManager.default.removeItem(at: fileURL)
	}
	
	static func save(wordLists: [WordList]) {
		wordLists.forEach { wordList in
			wordList.save(to: wordList.name)
		}
	}
	
	static func loadWordLists() -> [WordList] {
		guard let documentsURL = Self.documentDirectory else { return [] }
		let fileManager = FileManager.default
		do {
			let contents = try fileManager.contentsOfDirectory(at: documentsURL,
					includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
			
			// Filter for files with "json" extension (case-insensitive)
			let wordListURLs = contents.filter { $0.pathExtension.lowercased() == "wlist" }
			var wordLists = [WordList]()
			for url in wordListURLs {
				if let wordList = WordList(from: url) {
					wordLists.append(wordList)
				}
			}
			return wordLists
		} catch {
			print("Error reading directory: \(error)")
			return []
		}
	}
	
	static func loadSystemWords() -> [String] {
		// macOS includes a comprehensive default English word file at this path
		if let wordFilePath = Bundle.main.path(forResource: "web2", ofType: nil) {
			print("Found word file")
			if let content = try? String(contentsOfFile: wordFilePath, encoding: .utf8) {
				print("Successfully loaded word file")
				return content.components(separatedBy: .newlines)
			}
		}
		return ["error", "fallback", "words"]
	}

	static let largeWordBank = loadSystemWords()
	
	static private func generateWords(with size: CountableClosedRange<Int>, total: Int) -> [String] {
		print("Generating words...")
		var words: [String] = []
		while words.count < total {
			if let word = largeWordBank.randomElement() {
				if size.contains(word.count) {
					words.append(word.capitalized)
				}
			}
		}
		return words.sorted()
	}
}

extension WordList: Identifiable { }  // auto-generated

extension WordList: Equatable {
	static public func == (lhs: WordList, rhs: WordList) -> Bool {
		lhs.id == rhs.id
	}
}

extension WordList: Hashable {
	public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
