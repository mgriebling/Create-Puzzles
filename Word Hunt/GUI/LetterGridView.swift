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
				// let totalWidth = geometry.size.width
				let cellSize = (Int(geometry.size.width) - (spacing * (numCols - 1))) / numCols
				
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
								processDrag(location: value.location, startLocation: value.startLocation, cellSize: cellSize, spacing: spacing)
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
	
	private func capsuleView(cellSize: Int, start: CellIndex, end: CellIndex, selected: Bool) -> some View {
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
	
	private func textGrid(cellSize: Int) -> some View {
		VStack(spacing: 0) {
			let size = Double(cellSize)
			ForEach(0..<numRows, id: \.self) { row in
				HStack(spacing: 0) {
					ForEach(0..<numCols, id: \.self) { col in
						Text(game.board[row, col].letter)
							.font(.system(size: size * 0.7, weight: .bold))
							.frame(width: size, height: size)
					}
				}
			}
		}
	}
	
	// MARK: - Word Evaluation Mechanics
	
	private func processDrag(location: CGPoint, startLocation: CGPoint, cellSize: Int, spacing: Int) {
		let step = CGFloat(cellSize + spacing)
		
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
			// horizontal drag
			selectionDirection = deltaCol > 0 ? .right : .left
			dragCurrentCell = CellIndex(row: origin.row, col: boundedCol)
		} else if deltaCol == 0 && deltaRow != 0 {
			// vertical drag
			selectionDirection = deltaRow > 0 ? .down : .up
			dragCurrentCell = CellIndex(row: boundedRow, col: origin.col)
		} else if abs(deltaRow) == abs(deltaCol) && deltaRow != 0 {
			// diagonal drag
			selectionDirection = deltaRow == deltaCol
				? (deltaCol > 0 ? .diagonalDownRight : .diagonalUpLeft)
				: (deltaCol < 0 ? .diagonalDownLeft : .diagonalUpRight)
			dragCurrentCell = CellIndex(row: boundedRow, col: boundedCol)
		}
		
		extractWordString()
	}
	
	private func extractWordString() {
		guard let start = dragStartCell, let end = dragCurrentCell, let selectionDirection else { return }
		
		var tempWord = ""
		let rowStep = selectionDirection.deltaRow
		let colStep = selectionDirection.deltaCol
		
		var currRow = start.row
		var currCol = start.col
		
		while true {
			tempWord.append(game.board[currRow, currCol].letter)
			if currRow == end.row && currCol == end.col { break }
			currRow += rowStep
			currCol += colStep
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

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 6, words: SampleWordLists.all[0]))
	@Previewable @State var settings = SettingsType()
	LetterGridView(game: game, allowDrag: true, settings: $settings)
}
