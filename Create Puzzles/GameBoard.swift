//
//  Board.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-09.
//

import Foundation

struct Cell: Codable, Identifiable {
    let letter: String
    let id: Int
    
	init(letter: String, index: Int) {
        self.letter = letter
        self.id = index
    }
}

enum Direction: Int, Codable, CaseIterable {
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

public struct Word: Codable, Identifiable {
    let word: String
    let direction: Direction
    var highlighted: Bool
    public let id: Int
    
    init(word:String, id: Int, direction: Direction, highlighted: Bool = false) {
        self.word = word
        self.id = id
        self.highlighted = highlighted
        self.direction = direction
    }
}

struct GameBoard : Codable {
    
    let size: Int
    
    private(set) var board: [Cell]
    
    // active word selection
    private(set) var selectedWord = ""
    private var selectedMoves = [Int]()
    
    // placement of all words
    private(set) var wordPlacements = [Word]()
	
	init?(size: Int, words: [String]) {
		guard !words.isEmpty && size > 0 else { return nil }
		self.size = size
		
		board = []
		for index in 0..<size*size {
			board.append(Cell(letter: " ", index: index))
		}
		
		// place the words on the grid
		wordPlacements = []
		for word in words {
			if word.count > size { return nil }
			
			// try to place word up to exitCount times
			var exitCount = 100
			while !place(word: word) {
				exitCount -= 1
				if exitCount == 0 { return nil}
			}
		}
		
		// fill any blanks with random characters
		for i in 0..<size*size {
			if board[i].letter == " " {
				board[i] = Cell(letter: getRandomCharacter(), index: i)
			}
		}
	}
    
    private mutating func place (word: String) -> Bool {
        // pick a direction to place the word
		let direction = Direction.random()
        var startCol = Int.random(in: 0..<size)
        var startRow = Int.random(in: 0..<size)
        let deltaCol = direction.deltaCol
        let deltaRow = direction.deltaRow
		
        // adjust starting x point to fit in puzzle
        let lastCol = startCol + deltaCol * (word.count - 1)
        if lastCol < 0 { startCol -= lastCol }
        if lastCol >= size { startCol -= lastCol - size + 1 }
        if startCol < 0 || startCol >= size { return false }
        
        // adjust starting y point to fit in puzzle
        let lastRow = startRow + deltaRow * (word.count - 1)
        if lastRow < 0 { startRow -= lastRow }
        if lastRow >= size { startRow -= lastRow - size + 1 }
        if startRow < 0 || startRow >= size { return false }
		
        // place the letters
        let backupBoard = board
        var c = startCol, r = startRow

        for letter in word.uppercased() {
			let index = indexOf(r, column:c)
			let existing = board[index].letter
			if existing == " " || existing == String(letter) {
				// place letter if location is empty or already has the letter
				board[index] = Cell(letter: String(letter), index: index)
				c += deltaCol; r += deltaRow
			} else {
				// need to try new placement
				board = backupBoard
				return false
			}
		}
        
        // add word to the word database
		let index = indexOf(startRow, column:startCol)
		wordPlacements.append(Word(word: word, id: index, direction: direction))
        return true
    }
    
    mutating func addLetter(_ index: Int) {
		if selectedMoves.contains(index) { return }
        let letter = board[index].letter
        board[index] = Cell(letter: letter, index: index)
        selectedWord.append(letter)
        selectedMoves.append(index)
    }
	
	mutating func highlightWord(_ index: Int) {
		wordPlacements[index].highlighted.toggle()
	}
    
    mutating func clearWord() {
        // clear the active word
        selectedWord = ""
        selectedMoves = []
    }
    
	func isHighlighted(_ index: Int) -> Bool {
		selectedMoves.contains(index)
	}
	
    private func getRandomCharacter() -> String {
		let alphabet = Array(Alphabets.japaneseAlphabet)
		return String(alphabet[Int.random(in: 0..<alphabet.count)])
    }
 
    func indexOf(_ row: Int, column: Int) -> Int {
		let row = max(0, min(row, size-1))
		let column = max(0, min(column, size-1))
		return row * size + column
    }
    
    static func indexToRowCol(_ index:Int) -> (row:Int, col:Int) {
		let size = BoardView.size
		guard size > 0 else { return (row: 0, col: 0) }
		let index = max(0, min(index, size*size-1))
		return (row: index / size, col: index % size)
    }
    
    public subscript(row:Int, column:Int) -> Cell {
        get { board[indexOf(row, column: column)] }
        set { board[indexOf(row, column: column)] = newValue }
    }
    
}
