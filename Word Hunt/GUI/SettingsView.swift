//
//  SettingsView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 01.07.2026.
//

import SwiftUI

struct SettingsView: View {
	
	@AppStorage(.settings) private var settings
	
	// Word for the demo grid to show selection/hightling
	static let words = WordList(words: ["Test", "High", "Push", "Unit"])
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	
	@State private var internalSettings = SettingsType()
	@State private var game = Game(board: GameBoard(size: 4, words: words))
	
	var body: some View {
		NavigationStack {
			Form {
				Section("Word List Creator Default Name") {
					TextField("Enter your name", text: $internalSettings.player.name)
						.showClearButton($internalSettings.player.name)
				}
				
				Section("Word Grid Default Size: \(Int(internalSettings.gridDefaultSize))") {
					Slider(value: $internalSettings.gridDefaultSize, in: SettingsType.maxGridRange, step: 1) {
						Text("Word Grid Minimum")
					} minimumValueLabel: {
						Text("\(Int(SettingsType.maxGridRange.lowerBound))")
					} maximumValueLabel: {
						Text("\(Int(SettingsType.maxGridRange.upperBound))")
					}
				}
				
				Section("Word List (relative to letter grid):") {
					Picker("Horizontal", selection: $internalSettings.horizontal) {
						ForEach(Horizontal.allCases) { mode in
							Text(mode.rawValue.capitalized)
						}
					}
					.pickerStyle(.segmented)
					
					Picker("Vertical", selection: $internalSettings.vertical) {
						ForEach(Vertical.allCases) { mode in
							Text(mode.rawValue.capitalized)
						}
					}
					.pickerStyle(.segmented)
				}
				
				Section("Timer") {
					Toggle("Enable", isOn: $internalSettings.showTimer)
				}
				
				Section("Sound Effects") {
					Toggle("Enable", isOn: $internalSettings.soundsOn)
						.onChange(of: internalSettings.soundsOn) {
							if internalSettings.soundsOn {
								play(sound: "success.mp3", volume: internalSettings.soundVolume)
							}
						}
					HStack {
						Text("Volume:")
						Text("\(Int(internalSettings.soundVolume * 100))%")
						Slider(value: $internalSettings.soundVolume, in: 0.0...1.0) {
							Text("Sound Volume")
						} minimumValueLabel: {
							Image(systemName: "speaker")
						} maximumValueLabel: {
							Image(systemName: "speaker.wave.3")
						} onEditingChanged: { editing in
							if !editing {
								play(sound: "success.mp3", volume: internalSettings.soundVolume)
							}
						}
					}
					.opacity(internalSettings.soundsOn ? 1.0 : 0.5)
					.disabled(!internalSettings.soundsOn)
				}
				
				Section("Highlight & Word Selection") {
					Picker("Selection", selection: $internalSettings.highlight) {
						ForEach(HighLight.allCases) { mode in
							Text(mode.rawValue.capitalized)
						}
					}
					.pickerStyle(.segmented)
					
					HStack {
						Spacer()
						LetterGridView(game: game, allowDrag: true, showWordSelection: false, settings: $internalSettings).id(UUID())
							.frame(maxWidth: 150)
							.onAppear {
								game.board.highlightWord(0)
								game.board.highlightWord(1)
							}
						Spacer()
					}
					
					ColorPicker("Selection Color", selection: $internalSettings.selectionColor, supportsOpacity: false)
					ColorPicker("Selection OK Color", selection: $internalSettings.selectionOKColor, supportsOpacity: false)
					ColorPicker("Highlight Color", selection: $internalSettings.highlightColor, supportsOpacity: false)
				}
			}
			.onAppear {
				internalSettings = settings
			}
#if os(macOS)
			.padding()
			.frame(width: 450, height: 700)
#else
			.navigationBarTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
#endif
			.toolbar {
				EditToolbar() {
					settings = internalSettings
					dismiss()
				} //(okDisabled: internalSettings == settings) {
//					settings = internalSettings
//					dismiss()
//				}
			}
		}
	}
}

#Preview {
	SettingsView()
}
