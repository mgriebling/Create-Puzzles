//
//  CapsuleHighlight.swift
//  Word Hunt
//
//  Created by Google AI on 30.06.2026.
//  Modified by M. Griebling on 30.06.2026.
//

import SwiftUI
import Subsonic

/// Row x Col Game Board Matrix
struct LetterGridView: View {
	let game: Game
	var allowDrag: Bool = false
	var showWordSelection: Bool = true
	@Binding var settings: SettingsType
	
	@Environment(\.colorScheme) var colorScheme: ColorScheme

	// Active Interaction States
	@State private var dragStartCell: CellIndex?
	@State private var dragCurrentCell: CellIndex?
	@State private var selectionDirection: Direction?
	@State private var numRows = 1
	@State private var numCols = 1
	@State private var animateWin = false
	@State private var done: Bool = false
	@State private var width: CGFloat = 0	// for the WinnerView
	
	let spacing = 0	// space between columns and rows

	var body: some View {
		VStack(spacing: 0) {
			GeometryReader { geometry in
				let cellSize = (geometry.size.width - CGFloat(spacing * (numCols - 1))) / CGFloat(numCols)
				
				// 1. Text Grid
				textGrid(cellSize: cellSize)
					.onAppear {
						self.width = geometry.size.width * 0.8
					}
					.coordinateSpace(name: "GridSpace")
					.background {
						// 2. Persistent Layer: Displays correctly guessed historical word
						ForEach(game.placedWords) { word in
							if word.highlighted {
								capsuleView(cellSize: cellSize, start: word.start, end: word.end, selected: false)
							}
						}
						
						// 3. Active Layer: Current continuous user gesture drag highlight
						if let start = dragStartCell, let end = dragCurrentCell {
							capsuleView(cellSize: cellSize, start: start, end: end, selected: true)
						}
					}
					.gesture(
						DragGesture(minimumDistance: 5, coordinateSpace: .named("GridSpace"))
							.onChanged { value in
								processDrag(location: value.location, startLocation: value.startLocation, cellSize: cellSize)
							}
							.onEnded { _ in
								evaluateAndSaveWord()
							},
						isEnabled: allowDrag && !game.isOver
					)
			}
			.onAppear {
				numRows = game.board.size
				numCols = game.board.size
			}
			.aspectRatio(1, contentMode: .fit)
		}
		.overlay {
			if game.isOver && animateWin {
				WinnerView(game: game, width: width, points: settings.player.points)
			}
		}
	}
	
	private func capsuleView(cellSize: CGFloat, start: CellIndex, end: CellIndex, selected: Bool) -> some View {
		let startPoint = start.centerOfCell(cellSize: cellSize, spacing: spacing)
		let endPoint = end.centerOfCell(cellSize: cellSize, spacing: spacing)
		let fill = settings.highlight.isFill
		let lineWidth = settings.highlight.isOutline ? 3.0 : 0.0
		let fillColor = detectedWord != nil ? settings.selectionOKColor : settings.selectionColor
		let color = selected ? fillColor : settings.highlightColor
		let backColor = Color.backColor
		let mix = selected ? 0.2 : 0.6
		let mix2 = selected ? 0.0 : 0.4
		let scale = selected ? 1.0 : 0.84
		let size = Double(cellSize)
		return Capsule()
			.fill(fill ? color.mix(with: backColor, by: mix) : .clear)
			.stroke(color.mix(with: backColor, by: mix2), lineWidth: lineWidth)
			.frame(width: size * scale, height: startPoint.distance(to: endPoint) + size * scale)
			.rotationEffect(Angle(radians: startPoint.angle(to: endPoint)))
			.position(startPoint.midPoint(to: endPoint))
			.allowsHitTesting(false)
	}
	
	private func textGrid(cellSize: CGFloat) -> some View {
		VStack(spacing: 0) {
			ForEach(0..<numRows, id: \.self) { row in
				HStack(spacing: 0) {
					ForEach(0..<numCols, id: \.self) { col in
						Text(game.board[row, col].letter)
							.font(.system(size: cellSize * 0.7, weight: .bold))
							.frame(width: cellSize, height: cellSize)
					}
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	// MARK: - Word Evaluation Mechanics
	
	private func processDrag(location: CGPoint, startLocation: CGPoint, cellSize: CGFloat) {
		let step = cellSize + CGFloat(spacing)
		let start = CellIndex.ifloor(startLocation / step)
		
		guard start.inRange(row: 0..<numRows, column: 0..<numCols)
		else { return }
		
		if dragStartCell == nil {
			dragStartCell = CellIndex(row: start.row, col: start.col)
		}
		
		let current = CellIndex.ifloor(location / step)
		let bounded = current.limit(to: 0..<numRows, column: 0..<numCols)
		
		guard let origin = dragStartCell else { return }
		let delta = bounded - origin
		
		// Lock vector tracks and lock cell endpoints
		if delta.row == 0 && delta.col != 0 {
			// horizontal drag
			selectionDirection = delta.col > 0 ? .right : .left
			dragCurrentCell = CellIndex(row: origin.row, col: bounded.col)
		} else if delta.col == 0 && delta.row != 0 {
			// vertical drag
			selectionDirection = delta.row > 0 ? .down : .up
			dragCurrentCell = CellIndex(row: bounded.row, col: origin.col)
		} else if abs(delta.row) == abs(delta.col) && delta.row != 0 {
			// diagonal drag
			selectionDirection = delta.row == delta.col
				? (delta.col > 0 ? .diagonalDownRight : .diagonalUpLeft)
				: (delta.col < 0 ? .diagonalDownLeft : .diagonalUpRight)
			dragCurrentCell = CellIndex(row: bounded.row, col: bounded.col)
		}
		
		extractWordString()
	}
	
	private func extractWordString() {
		guard let start = dragStartCell, let end = dragCurrentCell, let selectionDirection else { return }
		
		var tempWord = ""
		var curr = start
		while true {
			tempWord.append(game.board[curr.row, curr.col].letter)
			if curr == end { break }
			curr = curr + selectionDirection
		}
		
		game.board.selectedWord = tempWord
	}
	
	// Helper to evaluate if the current selection forms a valid word
	private var detectedWord: String? {
		if game.isWordMatch(start: dragStartCell) {
			return game.board.selectedWord
		}
		return nil
	}
	
	private func evaluateAndSaveWord() {
		// Use computed property to evaluate forward vs reverse match
		if let targetWord = detectedWord {
			// Check to avoid duplicates
			let target = targetWord.capitalized
			if let _ = dragStartCell, let _ = dragCurrentCell {
				effect("success.mp3")
				game.removeActiveWord()  // sets the highlight flag
				game.save(to: game.name)
				print("SUCCESS: Found Word \(target)")
			}
		} else {
			effect("oops.mp3")
		}
		
		game.clearWord()
		if game.isOver {
			effect("victory-chime.mp3")
			game.timer.pause()
			settings.player.add(points: game.level)
			animateWin = true
		}
		
		// UI cleanup sequence
		withAnimation(.easeOut(duration: 0.15)) {
			dragStartCell = nil
			dragCurrentCell = nil
			selectionDirection = nil
		}
	}
	
	private func effect(_ sound: String) {
		if settings.soundsOn {
			play(sound: sound, volume: settings.soundVolume)
		}
	}
}

extension CGPoint {
	
	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
	}
}

extension CellIndex {
	
	static func ifloor(_ point: CGPoint) -> CellIndex {
		let x = Int(point.x.rounded(.down))
		let y = Int(point.y.rounded(.down))
		return CellIndex(row: y, col: x)
	}
	
	static func - (lhs: CellIndex, rhs: CellIndex) -> CellIndex {
		CellIndex(row: lhs.row - rhs.row, col: lhs.col - rhs.col)
	}
	
	static func + (lhs: inout CellIndex, rhs: Direction) -> CellIndex {
		CellIndex(row: lhs.row + rhs.deltaRow, col: lhs.col + rhs.deltaCol)
	}
	
	func limit(to row: Range<Int>, column: Range<Int>) -> CellIndex {
		let row = max(row.lowerBound, min(self.row, row.upperBound))
		let col = max(column.lowerBound, min(self.col, column.upperBound))
		return CellIndex(row: row, col: col)
	}
	
	func inRange(row: Range<Int>, column: Range<Int>) -> Bool {
		if self.row <= row.upperBound, self.row >= row.lowerBound, self.col <= column.upperBound, self.col >= column.lowerBound {
			return true
		}
		return false
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 6, words: SampleWordLists.all[0]))
	@Previewable @State var settings = SettingsType()
	LetterGridView(game: game, allowDrag: true, settings: $settings)
}
