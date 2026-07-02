//
//  SettingsView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 01.07.2026.
//

import SwiftUI

struct SettingsView: View {
	@AppStorage("gridSizeMinimum") private var gridSizeMin = 10.0
	@AppStorage("gridSizeMaximum") private var gridSizeMax = 20.0
	@AppStorage("userName") private var userName = "Anonymous"
	@AppStorage("highlight") private var highlight: HighLight = .fill
	@AppStorage("selectionColor") private var selectionColor: Int = Color.orange.toInt!
	@AppStorage("selectionOKColor") private var selectionOKColor: Int = Color.green.toInt!
	@AppStorage("highlightColor") private var highlightColor: Int = Color.accentColor.toInt!
	@AppStorage("soundsOn") private var soundsOn: Bool = false
	
	static let words = WordList(words: ["Test", "High", "Push"])
	
	@State private var editColor = Color.orange
	@State private var editColor2 = Color.accentColor
	@State private var editColor3 = Color.green
	@State private var game = Game(board: GameBoard(size: 4, words: words))
	
    var body: some View {
		let maxRange = 5.0...20.0
		Form {
			Section("Word List Creator Default Name") {
				TextField("Enter your name", text: $userName)
			}
			Section("Word Grid Default Range") {
				Text("Value: \(Int(gridSizeMin))...\(Int(gridSizeMax))")
				Slider(value: $gridSizeMin, in: maxRange, step: 1) {
					Text("Word Grid Minimum")
				} minimumValueLabel: {
					Text("\(Int(maxRange.lowerBound))")
				} maximumValueLabel: {
					Text("\(Int(maxRange.upperBound))")
				} onEditingChanged: { _ in
					if gridSizeMin > gridSizeMax {
						gridSizeMax = gridSizeMin
					}
				}
				Slider(value: $gridSizeMax, in: maxRange, step: 1) {
					Text("Word Grid Maximum")
				} minimumValueLabel: {
					Text("\(Int(maxRange.lowerBound))")
				} maximumValueLabel: {
					Text("\(Int(maxRange.upperBound))")
				} onEditingChanged: { _ in
					if gridSizeMax < gridSizeMin {
						gridSizeMin = gridSizeMax
					}
				}
			}
			Section("Highlight Word") {
				Picker("Selection", selection: $highlight) {
					ForEach(HighLight.allCases) { mode in
						Text(mode.rawValue.capitalized)
					}
				}
				.pickerStyle(.segmented)
				
				HighlightedGridView(game: game, noDrag: false)
					.frame(maxWidth: 150)
					.onAppear {
						game.board.highlightWord(0)
						game.board.highlightWord(1)
					}
					.offset(x: 100, y: 20)
				ColorPicker("Selection Color", selection: $editColor)
					.onAppear {
						editColor = Color(selectionColor)
					}
					.onChange(of: editColor) {
						selectionColor = editColor.toInt!
						print(selectionColor)
					}
				ColorPicker("Selection OK Color", selection: $editColor3)
					.onAppear {
						editColor3 = Color(selectionColor)
					}
					.onChange(of: editColor3) {
						selectionColor = editColor3.toInt!
						print(selectionColor)
					}
				ColorPicker("Highlight Color", selection: $editColor2)
					.onAppear {
						editColor2 = Color(highlightColor)
					}
					.onChange(of: editColor2) {
						highlightColor = editColor2.toInt!
						print(highlightColor)
					}
			}
		}
		#if os(macOS)
		.padding()
		.frame(width: 300, height: 150)
		#else
		.navigationBarTitle("Settings")
		.toolbar {
			EditToolbar {
				// TBD
			}
		}
		#endif
    }
}

enum HighLight: String, CaseIterable, Identifiable {
	case outline, fill, both
	
	var id: Self { self }
}

#Preview {
	NavigationStack {
		SettingsView()
	}
}
