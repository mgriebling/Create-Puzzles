//
//  SettingsView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 01.07.2026.
//

import SwiftUI

struct SettingsView: View {
	
	@AppStorage("settings") private var settings = Settings()
	
	// Word for the demo grid to show selection/hightling
	static let words = WordList(words: ["Test", "High", "Push", "Unit"])
	
	@State private var editColor = Color.orange
	@State private var editColor2 = Color.accentColor
	@State private var editColor3 = Color.green
	@State private var game = Game(board: GameBoard(size: 4, words: words))
	@State private var localSettings = Settings()
	
    var body: some View {
		Form {
			Section("Word List Creator Default Name") {
				TextField("Enter your name", text: $localSettings.userName)
			}
			
			Section("Word Grid Default Size: \(Int(localSettings.gridDefaultSize))") {
				Slider(value: $localSettings.gridDefaultSize, in: Settings.maxRange, step: 1) {
					Text("Word Grid Minimum")
				} minimumValueLabel: {
					Text("\(Int(Settings.maxRange.lowerBound))")
				} maximumValueLabel: {
					Text("\(Int(Settings.maxRange.upperBound))")
				}
			}
			
			Section("Sound Effects") {
				Toggle("Enable", isOn: $localSettings.soundsOn)
					.onChange(of: localSettings.soundsOn) {
						if localSettings.soundsOn {
							play(sound: "success.mp3", volume: localSettings.soundVolume)
						}
					}
				HStack {
					Text("Volume:")
					Text("\(Int(localSettings.soundVolume * 100))%")
					Slider(value: $localSettings.soundVolume, in: 0.0...1.0) {
						Text("Sound Volume")
					} minimumValueLabel: {
						Text("Min")
					} maximumValueLabel: {
						Text("Max")
					} onEditingChanged: { editing in
						if !editing {
							play(sound: "success.mp3", volume: localSettings.soundVolume)
						}
					}
				}
				.opacity(localSettings.soundsOn ? 1.0 : 0.5)
				.disabled(!localSettings.soundsOn)
			}
			
			Section("Highlight & Word Selection") {
				Picker("Selection", selection: $localSettings.highlight) {
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
				
				ColorPicker("Selection Color", selection: $localSettings.selectionColor, supportsOpacity: false)
				
				ColorPicker("Selection OK Color", selection: $localSettings.selectionOKColor, supportsOpacity: false)
				
				ColorPicker("Highlight Color", selection: $localSettings.highlightColor, supportsOpacity: false)
			}
		}
		.onAppear {
			localSettings = settings
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

#Preview {
	NavigationStack {
		SettingsView()
	}
}
