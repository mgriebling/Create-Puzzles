//
//  CapsuleHighlight.swift
//  Word Hunt
//
//  Created by Google AI on 30.06.2026.
//  Modified by M. Griebling on 30.06.2026.
//

import SwiftUI

struct CellIndex: Equatable {
	let row: Int
	let col: Int
}

struct Word : Identifiable {
	let id = UUID()
	let word: String // Stores standard dictionary version
	let start: CellIndex
	let end: CellIndex
	let color: Color
}

struct WordSearchGameView: View {
	// 5x5 Game Board Matrix
	let game: Game

	// Active Interaction States
	@State private var grid: [[String]] =  []
	@State private var validWordBank: Set<String> = []
	@State private var dragStartCell: CellIndex?
	@State private var dragCurrentCell: CellIndex?
	@State private var selectionDirection: SelectionDirection = .none
	@State private var activeWordString: String = ""
	@State private var numRows = 0
	@State private var numCols = 0
	
	// Permanent History State: Stores fully validated words and paths
	@State private var foundWords: [Word] = []
	
	enum SelectionDirection {
		case none, horizontal, vertical, diagonalUp, diagonalDown
	}

	// Helper to evaluate if the current selection or its reverse forms a valid word
	private var detectedWord: String? {
		if validWordBank.contains(activeWordString.capitalized) {
			return activeWordString
		}
		let reversed = String(activeWordString.reversed())
		if validWordBank.contains(reversed.capitalized) {
			return reversed
		}
		return nil
	}

	var body: some View {
		VStack(spacing: 20) {
			// Live Status Text Bar
			HStack {
				Text("Selected: ") + Text(activeWordString.isEmpty ? "..." : activeWordString)
					.foregroundColor(detectedWord != nil ? .green : .orange)
					.bold()
				Spacer()
				Button {
					print(foundWords)
				} label: {
					Text("Print Debug")
				}

				Spacer()
				Text("Found: \(foundWords.count)/\(validWordBank.count)")
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
			.font(.system(.title3, design: .monospaced))
			.padding(.horizontal)
			
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
										.font(.system(size: cellSize * 0.6, weight: .bold))
										.frame(width: cellSize, height: cellSize)
										.background(Color.secondary.opacity(0.2))
										.cornerRadius(8)
								}
							}
						}
					}
					.coordinateSpace(name: "GridSpace")
					
					// 2. Persistent Layer: Displays correctly guessed historical words
					ForEach(foundWords) { path in
						let startPoint = centerOfCell(row: path.start.row, col: path.start.col, cellSize: cellSize, spacing: spacing)
						let endPoint = centerOfCell(row: path.end.row, col: path.end.col, cellSize: cellSize, spacing: spacing)
						
						Capsule()
							.fill(path.color.opacity(0.35))
							.frame(width: cellSize, height: distance(from: startPoint, to: endPoint) + cellSize)
							.rotationEffect(Angle(radians: angle(from: startPoint, to: endPoint)))
							.position(midPoint(from: startPoint, to: endPoint))
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
							processDrag(location: value.location, startLocation: value.startLocation, cellSize: cellSize, spacing: spacing, numRows: numRows, numCols: numCols)
						}
						.onEnded { _ in
							evaluateAndSaveWord()
						}
				)
			}
			.aspectRatio(1, contentMode: .fit)
			.padding()
			
			// Found Word List display
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 10) {
					ForEach(foundWords) { item in
						Text(item.word)
							.font(.caption)
							.bold()
							.padding(.horizontal, 12)
							.padding(.vertical, 6)
							.background(item.color.opacity(0.2))
							.cornerRadius(15)
					}
				}
				.padding(.horizontal)
			}
		}
	}
	
	// MARK: - Word Evaluation Mechanics
	
	private func processDrag(location: CGPoint, startLocation: CGPoint, cellSize: CGFloat, spacing: CGFloat, numRows: Int, numCols: Int) {
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
		
		activeWordString = tempWord
	}
	
	private func evaluateAndSaveWord() {
		// Use computed property to evaluate forward vs reverse match
		if let targetWord = detectedWord {
			// Check to avoid duplicates
			let target = targetWord.capitalized
			print("Found: \(target)")
			if !foundWords.contains(where: { $0.word == target }) {
				if let start = dragStartCell, let end = dragCurrentCell {
					let randomColor: Color = [.blue, .green, .purple, .pink, .indigo].randomElement() ?? .blue
					
					let finalizedPath = Word (
						word: targetWord,
						start: start,
						end: end,
						color: randomColor
					)
					
					withAnimation(.spring()) {
						foundWords.append(finalizedPath)
					}
					print("SUCCESS: Found Word (\(targetWord)) from path \(activeWordString)")
				}
			}
		}
		
		// UI cleanup sequence
		withAnimation(.easeOut(duration: 0.15)) {
			dragStartCell = nil
			dragCurrentCell = nil
			selectionDirection = .none
			activeWordString = ""
		}
	}
	
	// MARK: - Geometry Math Helpers
	
	private func centerOfCell(row: Int, col: Int, cellSize: CGFloat, spacing: CGFloat) -> CGPoint {
		let x = CGFloat(col) * (cellSize + spacing) + cellSize / 2
		let y = CGFloat(row) * (cellSize + spacing) + cellSize / 2
		return CGPoint(x: x, y: y)
	}
	
	private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
		hypot(to.x - from.x, to.y - from.y)
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
	@State var game = Game(board: GameBoard(size: 12, words: SampleWordLists.all[0]))
	WordSearchGameView(game: game)
}
