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
	@State private var width: CGFloat = 0
	
	// Permanent History State: Stores fully validated words and paths
	@State private var foundWords: [PlacedWord] = []

	var body: some View {
		VStack(spacing: 20) {
			GeometryReader { geometry in
				let spacing: CGFloat = 0
				let totalWidth = geometry.size.width
				let cellSize = (totalWidth - (spacing * CGFloat(numCols - 1))) / CGFloat(numCols)
				let highlightSize = cellSize * 0.7
				let fontSize = cellSize * 0.6
				let fill = Set([.fill, .both]).contains(settings.highlight)
				let lineWidth = Set([.outline, .both]).contains(settings.highlight) ? 3.0 : 0.0
				#if os(iOS)
				let gray = Color(.systemGray2)
				#else
				let gray = Color(nsColor: .tertiaryLabelColor)
				#endif
				
				ZStack(alignment: .topLeading) {
					// Floating selected name
					if showWordSelection {
						let frameWidth = game.activeWord.count/2 + 1
						let center = CGFloat(numCols-frameWidth-1)/2
						Text(game.activeWord)
							.font(.system(size: fontSize, weight: .bold))
							.lineLimit(1)
							.fixedSize(horizontal: true, vertical: false)
							.frame(width: cellSize * CGFloat(frameWidth), height: fontSize)
							.padding(10)
							.background(gray)
							.cornerRadius(15)
							.offset(x: cellSize * center, y: -fontSize)
							.zIndex(10)
							.opacity(game.activeWord.isEmpty ? 0.0 : 1.0)
							.animation(.none, value: frameWidth)
					}
					
					// 1. Text Grid
					VStack(spacing: spacing) {
						ForEach(0..<numRows, id: \.self) { row in
							HStack(spacing: spacing) {
								ForEach(0..<numCols, id: \.self) { col in
									Text(game.board[row, col].letter)
										.font(.system(size: cellSize * 0.7, weight: .bold))
										.frame(width: cellSize, height: cellSize)
								}
							}
						}
					}
					.onAppear {
						self.width = geometry.size.width * 0.8
					}
					.coordinateSpace(name: "GridSpace")
					.background {
						// 2. Persistent Layer: Displays correctly guessed historical word
						ForEach(game.placedWords) { word in
							let startPoint = word.start.centerOfCell(cellSize: cellSize, spacing: spacing)
							let endPoint = word.end.centerOfCell(cellSize: cellSize, spacing: spacing)
							let color = settings.highlightColor
							let isDark = colorScheme == .dark
							if word.highlighted {
								Capsule()
									.fill(fill ? color : .clear)
									.stroke(.foreground, lineWidth: lineWidth)
									.brightness(isDark ? -0.6 : 0.5)
									.frame(width: highlightSize, height: startPoint.distance(to: endPoint) + highlightSize * 1.2)
									.rotationEffect(Angle(radians: startPoint.angle(to: endPoint)))
									.position(startPoint.midPoint(to: endPoint))
							}
						}
						
						// 3. Active Layer: Current continuous user gesture drag highlight
						if let start = dragStartCell, let end = dragCurrentCell {
							let startPoint = start.centerOfCell(cellSize: cellSize, spacing: spacing)
							let endPoint = end.centerOfCell(cellSize: cellSize, spacing: spacing)
							let selColor = settings.selectionColor
							let selColorOK = settings.selectionOKColor
							let color = detectedWord != nil ? selColorOK : selColor
							Capsule()
								.fill(fill ? color.opacity(0.6) : .clear)
								.stroke(color, lineWidth: lineWidth)
								.frame(width: cellSize, height: startPoint.distance(to: endPoint) + cellSize)
								.rotationEffect(Angle(radians: startPoint.angle(to: endPoint)))
								.position(startPoint.midPoint(to: endPoint))
								.allowsHitTesting(false)
						}
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
//				for i in 0..<game.placedWords.count-1 {
//					game.board.highlightWord(i)
//				}
				// game.board.highlightWord(game.placedWords.count-1)
			}
			.aspectRatio(1, contentMode: .fit)
		}
		.overlay {
			if game.isOver && animateWin {
				WinnerView(game: game, width: width, points: settings.player.points)
			}
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
		
		//print("Direction: \(selectionDirection)")
		while true { // currRow >= 0 && currCol >= 0 {
			// print("Current: \(currRow), \(currCol)")
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
			if let start = dragStartCell, let end = dragCurrentCell {
				let finalizedPath = PlacedWord (
					word: target, start: start, end: end
				)
				foundWords.append(finalizedPath)
				self.play(sound: "success.mp3")
				game.removeActiveWord()  // sets the highlight flag
				game.save(to: game.name)
				print("SUCCESS: Found Word \(target)")
			}
		} else {
			self.play(sound: "oops.mp3")
		}
		
		game.clearWord()
		if game.isOver {
			self.play("victory-chime.mp3")
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
	
	private func play(_ sound: String) {
		if settings.soundsOn {
			play(sound: sound, volume: settings.soundVolume)
		}
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 8, words: SampleWordLists.all[0]))
	@Previewable @State var settings = SettingsType()
	LetterGridView(game: game, allowDrag: true, settings: $settings)
}
