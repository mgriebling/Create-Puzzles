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

struct GameBoard : Codable {
    
	let size: Int
    
    private(set) var board: [Cell]
    
    // active word selection
    private(set) var selectedWord = ""
    private var selectedMoves = [Int]()
	
	// active set of words
	private(set) var words: Words
    
    // placement of all words
    private(set) var wordPlacements = [Word]()
	private(set) var missingWords = [String]()
	
	init?(size: Int, words: Words = Words()) {
		guard size > 0 else { return nil }
		self.size = size
		self.words = words
		wordPlacements = []
		board = []
		missingWords = []
		
		// iterate to find the best board placement
		if words.words.isEmpty {
			clearBoard()
		} else {
			bestPlacement(size, words.words)
		}
		
		// fill any blanks with random characters
		for i in 0..<size*size {
			if board[i].letter == " " {
				board[i] = Cell(letter: getRandomCharacter(), index: i)
			}
		}
	}
	
	private mutating func bestPlacement(_ size: Int, _ words: [String]) {
		var unplaced = 0
		var limit = 10
		var bestPlacement = 100
		var bestPlacementWords = [Word]()
		var bestBoard = [Cell]()
		repeat {
			clearBoard()
			wordPlacements = []
			unplaced = generatePuzzle(with: words)
			print("Unplaced: \(unplaced) ----------------------------")
			if unplaced < bestPlacement {
				bestPlacement = unplaced
				bestPlacementWords = wordPlacements
				bestBoard = board
			}
			limit -= 1
		} while unplaced > 0 && limit > 0
		
		// show final placements
		board = bestBoard
		wordPlacements = bestPlacementWords.sorted(by: { $0.word < $1.word } )
		print("Best placement: \(bestPlacement)")
		
		let newSet = Set(wordPlacements.map(\.word))
		missingWords = words.filter { !newSet.contains($0) }.sorted(by: <)
		if !missingWords.isEmpty {
			print("Missing: \(missingWords.joined(separator: ", "))")
		}
	}
	
	private mutating func clearBoard() {
		board = []
		for index in 0..<size*size {
			board.append(Cell(letter: " ", index: index))
		}
	}
	
	// Checks placement validity and scores the quality of the overlap
	private func scorePlacement(for word: String, atRow row: Int, col: Int, direction: Direction) -> Int? {
		let letters = Array(word.uppercased())
		var currentScore = 0
		
		for i in 0..<letters.count {
			let newRow = row + (i * direction.deltaRow)
			let newCol = col + (i * direction.deltaCol)
			
			// 1. Fail if out of bounds
			guard newRow >= 0 && newRow < size && newCol >= 0 && newCol < size else {
				return nil
			}
			
			// 2. Fail if there is a letter conflict
			let currentCell = board[indexOf(newRow, column: newCol)].letter
			if currentCell != " " && currentCell != String(letters[i]) {
				return nil
			}
			
			// 3. Reward valid overlaps
			if currentCell == String(letters[i]) {
				currentScore += 10
			}
		}
		
		return currentScore
	}
	
	// Write the word letters into the matrix
	private mutating func placeWord(_ word: String, atRow row: Int, col: Int, direction: Direction) {
		let letters = Array(word.uppercased())
		for i in 0..<letters.count {
			let newRow = row + (i * direction.deltaRow)
			let newCol = col + (i * direction.deltaCol)
			let index = indexOf(newRow, column:newCol)
			board[index] = Cell(letter: String(letters[i]), index: index)
		}
		
		// add word to the word database
		let index = indexOf(row, column:col)
		wordPlacements.append(Word(word: word, id: index, direction: direction))
	}
	
	// Check if the word fits at the given coordinates
	private func canPlaceWord(_ word: String, atRow row: Int, col: Int, direction: Direction) -> Bool {
		let letters = Array(word.uppercased())
		for i in 0..<letters.count {
			let newRow = row + (i * direction.deltaRow)
			let newCol = col + (i * direction.deltaCol)
			
			// Check bounds
			guard newRow >= 0 && newRow < size && newCol >= 0 && newCol < size else {
				return false
			}
			
			// Check conflicts (empty spaces or matching characters are fine)
			let currentCell = board[indexOf(newRow, column: newCol)].letter
			if currentCell != " " && currentCell != String(letters[i]) {
				return false
			}
		}
		return true
	}
	
	// Automatically loops through all words and places them randomly
	private mutating func generatePuzzle(with words: [String]) -> Int {
		// Sort words by length so long words establish a base infrastructure first
		let sortedWords = words.sorted { $0.count > $1.count }
		var unplaced = 0
		
		for word in sortedWords {
			var bestRow = 0
			var bestCol = 0
			var bestDirection = Direction.right
			var maxScore = -1
			
			// Test 150 random combinations to find the best overlapping spot
			let sampleSize = 150
			for _ in 0..<sampleSize {
				let r = Int.random(in: 0..<size)
				let c = Int.random(in: 0..<size)
				guard let d = Direction.allCases.randomElement() else { continue }
				
				if let score = scorePlacement(for: word, atRow: r, col: c, direction: d) {
					// Introduce a tiny random bonus (+0 or +1) so non-overlapping words
					// don't always cluster in the top-left corner (0,0) when maxScore is 0
					let tieBreakerScore = score + Int.random(in: 0...1)
					
					if tieBreakerScore > maxScore {
						maxScore = tieBreakerScore
						bestRow = r
						bestCol = c
						bestDirection = d
					}
				}
			}
			
			// If maxScore is still -1, it means no valid spot was found in 150 tries
			if maxScore >= 0 {
				placeWord(word, atRow: bestRow, col: bestCol, direction: bestDirection)
			} else {
				print("Could not place word: \(word)")
				unplaced += 1
			}
		}
		return unplaced
	}
    
    mutating func addLetter(_ index: Int) {
		if selectedMoves.contains(index) { return }
        let letter = board[index].letter
        board[index] = Cell(letter: letter, index: index)
        selectedWord.append(letter)
        selectedMoves.append(index)
    }
	
	mutating func highlightWord(_ index: Int) {
		wordPlacements[index].highlighted = true
	}
	
	func ishighlighted(_ index: Int) -> Bool {
		wordPlacements[index].highlighted
	}
    
    mutating func clearWord() {
        // clear the active word
        selectedWord = ""
        selectedMoves = []
    }
    
	func charIsHighlighted(_ index: Int) -> Bool {
		selectedMoves.contains(index)
	}
	
    private func getRandomCharacter() -> String {
		let alphabet = Array(Alphabets.englishAlphabet)
		return String(alphabet[Int.random(in: 0..<alphabet.count)])
    }
 
    func indexOf(_ row: Int, column: Int) -> Int {
		let row = max(0, min(row, size-1))
		let column = max(0, min(column, size-1))
		return row * size + column
    }
    
    func indexToRowCol(_ index:Int) -> (row:Int, col:Int) {
		// let size = BoardView.size
		guard size > 0 && index < size*size else { return (row: 0, col: 0) }
		return (row: index / size, col: index % size)
    }
    
    public subscript(row:Int, column:Int) -> Cell {
        get { board[indexOf(row, column: column)] }
        set { board[indexOf(row, column: column)] = newValue }
    }
    
}
