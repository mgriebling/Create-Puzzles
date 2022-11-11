//
//  Board.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-09.
//

import Foundation

struct Cell: Codable, Identifiable {
    let letter: String
    let highlighted: Bool
    let id:Int
    
    init(letter: String, index: Int, highlight: Bool) {
        self.letter = letter
        self.highlighted = highlight
        self.id = index
    }
}

struct GameBoard : Codable {
    
    let size: Int
    
    private(set) var board: [Cell]
    
    // active word selection
    private(set) var selectedWord = ""
    private var selectedMoves = [Int]()
    
    private enum Direction: Int {
        case left=0, right, down, up, diagonalUpLeft, diagonalUpRight, diagonalDownLeft, diagonalDownRight
        
        var deltaX: Int {
            switch self {
                case .left, .diagonalUpLeft, .diagonalDownLeft: return -1
                case .right, .diagonalUpRight, .diagonalDownRight: return 1
                case .up, .down: return 0
            }
        }
        
        var deltaY: Int {
            switch self {
                case .down, .diagonalDownLeft, .diagonalDownRight: return -1
                case .up, .diagonalUpLeft, .diagonalUpRight: return 1
                case .left, .right: return 0
            }
        }
        
        static func random() -> Direction {
            let choice = Int.random(in: 0...Direction.diagonalDownRight.rawValue)
            return Direction(rawValue: choice)!
        }
    }
    
    private mutating func place (word: String) -> Bool {
        // pick a direction to place the word
        let direction = Direction.random()
        var startX = Int.random(in: 0..<size)
        var startY = Int.random(in: 0..<size)
        let deltaX = direction.deltaX
        let deltaY = direction.deltaY

        // adjust starting x point to fit in puzzle
        let lastX = startX + deltaX * word.count
        if lastX < 0 { startX -= lastX }
        if lastX >= size { startX -= lastX - size + 1 }
        if startX < 0 || startX >= size { return false }
        
        // adjust starting y point to fit in puzzle
        let lastY = startY + deltaY * word.count
        if lastY < 0 { startY -= lastY }
        if lastY >= size { startY -= lastY - size + 1 }
        if startY < 0 || startY >= size { return false }
        
        // place the letters
        let backupBoard = board
        var x = startX; var y = startY
        for letter in word.uppercased() {
            let index = indexOf(x, column:y)
            let existing = board[index].letter
            if existing == " " || existing == String(letter) {
                board[index] = Cell(letter: String(letter), index: index, highlight: false)
                x += deltaX; y += deltaY
            } else {
                // need to try new placement
                board = backupBoard
                return false
            }
        }
        return true
    }
    
    mutating func addLetter(_ index: Int) {
        let letter = board[index].letter
        board[index] = Cell(letter: letter, index: index, highlight: true)
        selectedWord.append(letter)
        selectedMoves.append(index)
        print("Word = \(selectedWord)")
    }
    
    mutating func clearWord(_ unhighlight:Bool) {
        if unhighlight {
            for index in selectedMoves {
                let letter = board[index].letter
                board[index] = Cell(letter: letter, index: index, highlight: false)
            }
        }
        
        // clear the active word
        selectedWord = ""
        selectedMoves = []
    }
    
    func validMove(_ index:Int) -> Bool {
        let moves = selectedMoves.map { indexToRowCol($0) }
        
        // no moves just allow everything
        if moves.isEmpty { return true }
        
        // check if move is adjacent to first or last piece
        let (row, col) = indexToRowCol(index)
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
    
    func isHighlighted(_ index: Int) -> Bool { board[index].highlighted }
    
    private func getRandomCharacter() -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        return String(alphabet[Int.random(in: 0..<26)])
    }
    
    init?(size: Int, words: [String]) {
        self.size = size
        
        board = []
        for index in 0..<size*size {
            board.append(Cell(letter: " ", index: index, highlight: false))
        }
        
        // place the words on the grid
        for word in words {
            if word.count > size { return nil }
            
            // pick a direction to place the word
            var exitCount = 100  // try to place word up to exitCount times
            while !place(word: word) { exitCount -= 1; if exitCount == 0 { return nil} }
        }
        
        // fill any blanks with random characters
        for i in 0..<size*size {
            if board[i].letter == " " {
                board[i] = Cell(letter: getRandomCharacter(), index: i, highlight: false)
            }
        }
    }
    
    // not sure if this is the most efficient way of accessing a board piece?
    private func indexOf(_ row: Int, column: Int) -> Int {
        assert(row >= 0 && row < size && column >= 0 && column < size, "Index of board is out of limits")
        return row * size + column
    }
    
    func indexToRowCol(_ index:Int) -> (row:Int, col:Int) {
        return (index / BoardView.size, index % BoardView.size)
    }
    
    public subscript(row:Int, column: Int) -> Cell {
        get { board[indexOf(row, column: column)] }
        set { board[indexOf(row, column: column)] = newValue }
    }
    
}
