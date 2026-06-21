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
	let solution: Bool
    
	init(letter: String, index: Int, solution: Bool) {
        self.letter = letter
        self.id = index
		self.solution = solution
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
    
    static func random() -> Direction {
		Direction.allCases.randomElement()!
    }
}

public struct Word: Codable, Identifiable {
    let word: String
    let direction: Direction
    let highlighted: Bool
    public let id: Int
    
    init(word:String, id: Int, direction: Direction, highlighted: Bool) {
        self.word = word
        self.id = id
        self.highlighted = true // highlighted
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
    
    private mutating func place (word: String) -> Bool {
        // pick a direction to place the word
		let direction = Direction.up // Direction.random()
        var startCol = 0 // Int.random(in: 0..<size)
        var startRow = 0 // Int.random(in: 0..<size)
        let deltaCol = direction.deltaCol
        let deltaRow = direction.deltaRow
		
		print("Start col, row: \(startCol), \(startRow)")

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
		
		print("End position (col, row): \(lastCol), \(lastRow)")
        
        // place the letters
        let backupBoard = board
        var c = startCol; var r = startRow
		print("Placing word: \(word), direction: \(direction), at col: \(c), row: \(r)")
        for letter in word.uppercased() {
            let index = indexOf(r, column:c)
            let existing = board[index].letter
            if existing == " " || existing == String(letter) {
				// place letter if location is empty or already has the letter
                board[index] = Cell(letter: String(letter), index: index, solution: true)
				print("Placed letter: \(letter) at col: \(c), row: \(r)")
                c += deltaCol; r += deltaRow
            } else {
                // need to try new placement
                board = backupBoard
                return false
            }
        }
        
        // add word to the word database
        wordPlacements.append(Word(word: word, id: indexOf(startRow, column: startCol),
								   direction: direction, highlighted: false))
		//print(wordPlacements)
        return true
    }
    
    mutating func addLetter(_ index: Int) {
		if selectedMoves.contains(index) { return }
        let letter = board[index].letter
		print("Adding letter \(letter)")
        board[index] = Cell(letter: letter, index: index, solution: false)
        selectedWord.append(letter)
        selectedMoves.append(index)
    }
    
    mutating func clearWord(_ unhighlight: Bool) {
        if unhighlight {
            for index in selectedMoves {
                let letter = board[index].letter
                board[index] = Cell(letter: letter, index: index, solution: false)
            }
        }
        
        // clear the active word
        selectedWord = ""
        selectedMoves = []
    }
    
    func validMove(_ index:Int) -> Bool {
        let moves = selectedMoves.map { GameBoard.indexToRowCol($0) }
        
        // no moves just allow everything
        if moves.isEmpty { return true }
        
        // check if move is adjacent to first or last piece
        let (row, col) = GameBoard.indexToRowCol(index)
        let (frow, fcol) = moves.first!  // must always be one piece at this point
        if moves.count == 1, row == frow || col == fcol || (abs(row-frow) == 1 && abs(col-fcol) == 1) { return true }
        if moves.count > 1, let (lrow, lcol) = moves.last {
            if row == frow && row == lrow { return true } // ok if in the same row as other pieces
            if col == fcol && col == lcol { return true } // ok if in the same column as other pieces
            let (row2, col2) = moves[1]
            let rowDelta = frow - row2
            let colDelta = fcol - col2
            if row-frow == rowDelta && col-fcol == colDelta { return true }  // ok if diagonal to first piece
            if lrow-row == rowDelta && lcol-col == colDelta { return true }  // ok if diagonal to last piece
        }
        return false
    }
    
	func isHighlighted(_ index: Int) -> Bool {
		selectedMoves.contains(index)
	}
    
    private func getRandomCharacter() -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        return String(alphabet[Int.random(in: 0..<26)])
    }
    
    init?(size: Int, words: [String]) {
        self.size = size
        
        board = []
        for index in 0..<size*size {
            board.append(Cell(letter: " ", index: index, solution: false))
        }
        
        // place the words on the grid
        wordPlacements = []
        for word in words {
            if word.count > size { return nil }
            
            // pick a direction to place the word
            var exitCount = 100  // try to place word up to exitCount times
            while !place(word: word) { exitCount -= 1; if exitCount == 0 { return nil} }
        }
        
        // fill any blanks with random characters
        for i in 0..<size*size {
            if board[i].letter == " " {
                board[i] = Cell(letter: getRandomCharacter(), index: i, solution: false)
            }
        }
    }
    
    // not sure if this is the most efficient way of accessing a board piece?
    func indexOf(_ row: Int, column: Int) -> Int {
        assert(row >= 0 && row < size && column >= 0 && column < size, "Index of board is out of limits")
        return row * size + column
    }
    
    static func indexToRowCol(_ index:Int) -> (row:Int, col:Int) {
        return (index / BoardView.size, index % BoardView.size)
    }
    
    public subscript(row:Int, column:Int) -> Cell {
        get { board[indexOf(row, column: column)] }
        set { board[indexOf(row, column: column)] = newValue }
    }
    
}
