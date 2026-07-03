//
//  SettingsView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 01.07.2026.
//

import SwiftUI

struct SettingsView: View {
	static let maxRange = 4.0...20.0
	
	@AppStorage("gridDefaultSize") private var gridDefaultSize: Double = 4.0
	@AppStorage("userName") private var userName = "Anonymous"
	@AppStorage("highlight") private var highlight: HighLight = .fill
	@AppStorage("selectionColor") private var selectionColor: Int = Color.orange.toInt!
	@AppStorage("selectionOKColor") private var selectionOKColor: Int = Color.green.toInt!
	@AppStorage("highlightColor") private var highlightColor: Int = Color.accentColor.toInt!
	@AppStorage("soundsOn") private var soundsOn: Bool = false
	@AppStorage("soundVolume") private var soundVolume = 0.2
	
	// Word for the demo grid to show selection/hightling
	static let words = WordList(words: ["Test", "High", "Push", "Unit"])
	
	@State private var editColor = Color.orange
	@State private var editColor2 = Color.accentColor
	@State private var editColor3 = Color.green
	@State private var game = Game(board: GameBoard(size: 4, words: words))
	
    var body: some View {
		Form {
			Section("Word List Creator Default Name") {
				TextField("Enter your name", text: $userName)
			}
			
			Section("Word Grid Default Size: \(Int(gridDefaultSize))") {
				Slider(value: $gridDefaultSize, in: Self.maxRange, step: 1) {
					Text("Word Grid Minimum")
				} minimumValueLabel: {
					Text("\(Int(Self.maxRange.lowerBound))")
				} maximumValueLabel: {
					Text("\(Int(Self.maxRange.upperBound))")
				}
			}
			
			Section("Sound Effects") {
				Toggle("Enable", isOn: $soundsOn)
					.onChange(of: soundsOn) {
						if soundsOn {
							play(sound: "success.mp3", volume: soundVolume)
						}
					}
				HStack {
					Text("Volume:")
					Text("\(Int(soundVolume * 100))%")
					Slider(value: $soundVolume, in: 0.0...1.0) {
						Text("Sound Volume")
					} minimumValueLabel: {
						Text("Min")
					} maximumValueLabel: {
						Text("Max")
					} onEditingChanged: { editing in
						if !editing {
							play(sound: "success.mp3", volume: soundVolume)
						}
					}
				}
				.opacity(soundsOn ? 1.0 : 0.5)
				.disabled(!soundsOn)
			}
			
			Section("Highlight & Word Selection") {
				Picker("Selection", selection: $highlight) {
					ForEach(HighLight.allCases) { mode in
						Text(mode.rawValue.capitalized)
					}
				}
				.pickerStyle(.segmented)
				
				HStack {
					Spacer()
					LetterGridView(game: game, allowDrag: true, showWordSelection: false)
						.frame(maxWidth: 150)
						.onAppear {
							game.board.highlightWord(0)
							game.board.highlightWord(1)
						}
					Spacer()
				}
				
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
		.frame(width: 300, height: 300)
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
