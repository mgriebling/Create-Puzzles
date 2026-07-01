//
//  CapsuleHighlight.swift
//  Word Hunt
//
//  Created by Google AI on 30.06.2026.
//  Modified by M. Griebling on 30.06.2026.
//

import SwiftUI

struct HighlightedGridView: View {
	// Row x Col Game Board Matrix
	let game: Game
	var scale: CGFloat = 1.0
	var noDrag: Bool = true
	var isLandscape: Bool = false

	// Active Interaction States
	@State private var grid: [[String]] =  []
	@State private var validWordBank: Set<String> = []
	@State private var dragStartCell: CellIndex?
	@State private var dragCurrentCell: CellIndex?
	@State private var selectionDirection: SelectionDirection = .none
	@State private var numRows = 0
	@State private var numCols = 0
	
	// Permanent History State: Stores fully validated words and paths
	@State private var foundWords: [PlacedWord] = []

	var body: some View {
		VStack(spacing: 20) {
			GeometryReader { geometry in
				let spacing: CGFloat = 2
				let totalWidth = geometry.size.width
				let cellSize = (totalWidth - (spacing * CGFloat(numCols - 1))) / CGFloat(numCols)
				
				ZStack(alignment: .topLeading) {
					// 1. Core Background Grid
					VStack(spacing: spacing) {
						ForEach(0..<numRows, id: \.self) { row in
							HStack(spacing: spacing) {
								ForEach(0..<numCols, id: \.self) { col in
									Text(grid[row][col])
										.font(.system(size: cellSize * 0.7, weight: .bold))
										.frame(width: cellSize, height: cellSize)
										.cornerRadius(8)
								}
							}
						}
					}
					.coordinateSpace(name: "GridSpace")
					
					// 2. Persistent Layer: Displays correctly guessed historical words
					ForEach(game.placedWords) { word in
						let startPoint = centerOfCell(row: word.start.row, col: word.start.col, cellSize: cellSize, spacing: spacing)
						let endPoint = centerOfCell(row: word.end.row, col: word.end.col, cellSize: cellSize, spacing: spacing)
						
						if word.highlighted {
							Capsule()
								.fill(Color.indigo.opacity(0.3))
								.frame(width: cellSize, height: distance(from: startPoint, to: endPoint) + cellSize)
								.rotationEffect(Angle(radians: angle(from: startPoint, to: endPoint)))
								.position(midPoint(from: startPoint, to: endPoint))
						}
					}
					
					// 3. Active Layer: Current continuous user gesture drag highlight
					if let start = dragStartCell, let end = dragCurrentCell, selectionDirection != .none {
						let startPoint = centerOfCell(row: start.row, col: start.col, cellSize: cellSize, spacing: spacing)
						let endPoint = centerOfCell(row: end.row, col: end.col, cellSize: cellSize, spacing: spacing)
						
						Capsule()
							.fill(detectedWord != nil ? Color.green.opacity(0.4) : Color.orange.opacity(0.4))
							.frame(width: cellSize, height: distance(from: startPoint, to: endPoint) + cellSize)
							.rotationEffect(Angle(radians: angle(from: startPoint, to: endPoint)))
							.position(midPoint(from: startPoint, to: endPoint))
							.allowsHitTesting(false)
					}
				}
				.gesture(
					DragGesture(minimumDistance: 5, coordinateSpace: .named("GridSpace"))
						.onChanged { value in
							processDrag(location: value.location, startLocation: value.startLocation, cellSize: cellSize, spacing: spacing)
						}
						.onEnded { _ in
							evaluateAndSaveWord()
						},
					isEnabled: !noDrag
				)
			}
			.onAppear {
				validWordBank = Set(game.board.words.words)
				numRows = game.board.size
				numCols = game.board.size
				let blankRow = Array(repeating: " ", count: numCols)
				grid = Array(repeating: blankRow, count: numRows)
				for row in 0..<numRows {
					for col in 0..<numCols {
						grid[row][col] = game.board[row, col].letter
					}
				}
			}
			.aspectRatio(1, contentMode: .fit)
			.padding()
		}
	}
	
	// MARK: - Word Evaluation Mechanics
	
	private func processDrag(location: CGPoint, startLocation: CGPoint, cellSize: CGFloat, spacing: CGFloat) {
		let step = cellSize + spacing
		
		let startCol = Int(floor(startLocation.x / step))
		let startRow = Int(floor(startLocation.y / step))
		
		guard startRow >= 0, startRow < numRows, startCol >= 0, startCol < numCols else { return }
		
		if dragStartCell == nil {
			dragStartCell = CellIndex(row: startRow, col: startCol)
		}
		
		let currentCol = Int(floor(location.x / step))
		let currentRow = Int(floor(location.y / step))
		
		let boundedCol = max(0, min(numCols - 1, currentCol))
		let boundedRow = max(0, min(numRows - 1, currentRow))
		
		guard let origin = dragStartCell else { return }
		
		let deltaRow = boundedRow - origin.row
		let deltaCol = boundedCol - origin.col
		
		// Lock vector tracks and lock cell endpoints
		if deltaRow == 0 && deltaCol != 0 {
			selectionDirection = .horizontal
			dragCurrentCell = CellIndex(row: origin.row, col: boundedCol)
		} else if deltaCol == 0 && deltaRow != 0 {
			selectionDirection = .vertical
			dragCurrentCell = CellIndex(row: boundedRow, col: origin.col)
		} else if abs(deltaRow) == abs(deltaCol) && deltaRow != 0 {
			selectionDirection = deltaRow == deltaCol ? .diagonalDown : .diagonalUp
			dragCurrentCell = CellIndex(row: boundedRow, col: boundedCol)
		}
		
		extractWordString()
	}
	
	private func extractWordString() {
		guard let start = dragStartCell, let end = dragCurrentCell else { return }
		
		var tempWord = ""
		let rowStep = (end.row - start.row).signum()
		let colStep = (end.col - start.col).signum()
		
		var currRow = start.row
		var currCol = start.col
		
		while true {
			tempWord.append(grid[currRow][currCol])
			if currRow == end.row && currCol == end.col { break }
			currRow += rowStep
			currCol += colStep
		}
		
		game.board.selectedWord = tempWord
	}
	
	// Helper to evaluate if the current selection forms a valid word
	private var detectedWord: String? {
		// if game.isWordMatch() {
		if validWordBank.contains(game.board.selectedWord.capitalized) {
			return game.board.selectedWord
		}
		return nil
	}
	
	private func evaluateAndSaveWord() {
		// Use computed property to evaluate forward vs reverse match
		if let targetWord = detectedWord {
			// Check to avoid duplicates
			let target = targetWord.capitalized
			print("Found: \(target)")

			if let start = dragStartCell, let end = dragCurrentCell {
				let finalizedPath = PlacedWord (
					word: target, start: start, end: end
				)
				foundWords.append(finalizedPath)
				game.removeActiveWord()
				game.save(to: game.name)
				print("SUCCESS: Found Word (\(target))")
			}
		}
		game.clearWord()
		
		// UI cleanup sequence
		withAnimation(.easeOut(duration: 0.15)) {
			dragStartCell = nil
			dragCurrentCell = nil
			selectionDirection = .none
		}
	}
	
	enum SelectionDirection {
		case none, horizontal, vertical, diagonalUp, diagonalDown
	}
	
	// MARK: - Geometry Math Helpers
	
	private func centerOfCell(row: Int, col: Int, cellSize: CGFloat, spacing: CGFloat) -> CGPoint {
		// let cellSize = cellSize.isFinite ? cellSize : 50
		let x = CGFloat(col) * (cellSize + spacing) + cellSize / 2
		let y = CGFloat(row) * (cellSize + spacing) + cellSize / 2
		return CGPoint(x: x, y: y)
	}
	
	private func distance(from s: CGPoint, to d: CGPoint) -> CGFloat {
		hypot(d.x - s.x, d.y - s.y)
	}
	
	private func angle(from: CGPoint, to: CGPoint) -> CGFloat {
		// Offset by 90 degrees (pi/2) because SwiftUI capsules extend vertically by default
		atan2(to.y - from.y, to.x - from.x) - (.pi / 2)
	}
	
	private func midPoint(from: CGPoint, to: CGPoint) -> CGPoint {
		CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
	}
}

extension Int {
	func signum() -> Int {
		return (self > 0) ? 1 : ((self < 0) ? -1 : 0)
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 16, words: SampleWordLists.all[0]))
	@Previewable @State var activeWord = ""
	HighlightedGridView(game: game, noDrag: false)
}
