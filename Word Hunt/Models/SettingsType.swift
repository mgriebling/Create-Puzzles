//
//  Settings.swift
//  Word Hunt
//
//  Created by Michael Griebling on 04.07.2026.
//

import SwiftUI

public struct SettingsType {
	static let maxGridRange = 5...20
	
	var player: Player
	
	var creationMode: CreationMode
	var difficulty: Difficulty
	
	var highlight: HighLight
	var selectionColor: Color
	var selectionOKColor: Color
	var highlightColor: Color
	
	var soundsOn: Bool
	var soundVolume: Double
	
	var showTimer: Bool
	
	var horizontal: Horizontal
	var vertical: Vertical
	
	init() {
		self.creationMode = .oneGame
		self.player = Player()
		self.highlight = .allCases.first!
		self.selectionColor = .blue
		self.selectionOKColor = .green
		self.highlightColor = .yellow
		self.soundsOn = true
		self.soundVolume = 0.2
		self.showTimer = true
		self.horizontal = .left
		self.vertical = .below
		self.difficulty = .five
	}
	
	init(_ settings: Self) {
		self = settings
	}
}

public extension AppStorageKey where Value == SettingsType {
	static let settings = AppStorageKey("settings", defaultValue: SettingsType())
}

extension SettingsType: Codable {
	enum CodingKeys: String, CodingKey {
		case creationMode, player, highlight, selectionColor,
			 selectionOKColor, highlightColor, soundsOn, soundVolume, showTimer,
			 horizontal, vertical, difficulty
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.creationMode = try container.decode(CreationMode.self, forKey: .creationMode)
		self.player = try container.decode(Player.self, forKey: .player)
		self.highlight = try container.decode(HighLight.self, forKey: .highlight)
		self.selectionColor = try container.decode(Color.self, forKey: .selectionColor)
		self.selectionOKColor = try container.decode(Color.self, forKey: .selectionOKColor)
		self.highlightColor = try container.decode(Color.self, forKey: .highlightColor)
		self.soundsOn = try container.decode(Bool.self, forKey: .soundsOn)
		self.soundVolume = try container.decode(Double.self, forKey: .soundVolume)
		self.showTimer = try container.decode(Bool.self, forKey: .showTimer)
		self.horizontal = try container.decode(Horizontal.self, forKey: .horizontal)
		self.vertical = try container.decode(Vertical.self, forKey: .vertical)
		self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.creationMode, forKey: .creationMode)
		try container.encode(self.player, forKey: .player)
		try container.encode(self.highlight, forKey: .highlight)
		try container.encode(self.selectionColor, forKey: .selectionColor)
		try container.encode(self.selectionOKColor, forKey: .selectionOKColor)
		try container.encode(self.highlightColor, forKey: .highlightColor)
		try container.encode(self.soundsOn, forKey: .soundsOn)
		try container.encode(self.soundVolume, forKey: .soundVolume)
		try container.encode(self.showTimer, forKey: .showTimer)
		try container.encode(self.horizontal, forKey: .horizontal)
		try container.encode(self.vertical, forKey: .vertical)
		try container.encode(self.difficulty, forKey: .difficulty)
	}
}

extension SettingsType: RawRepresentable {
	
	public var rawValue: String {
		do {
			let jsonData = try JSONEncoder().encode(self)
			let jsonString = String(data: jsonData, encoding: .utf8)
			return jsonString ?? "Unable to convert to string"
		} catch {
			return ""
		}
	}
	
	public init?(rawValue: String) {
		if let jsonData = rawValue.data(using: .utf8) {
			if let settings = try? JSONDecoder().decode(SettingsType.self, from: jsonData) {
				self.init(settings)
				return
			}
		}
		return nil
	}
}

enum Difficulty: String, CaseIterable, Identifiable, Codable {
	case manual = "Man", three = "3", four = "4", five = "5", six = "6"
	case seven = "7", eight = "8", nine = "9", ten = "10"
	
	var value: Int { Int(self.rawValue) ?? 0 }
	
	/// returns the game grid size to give this difficulty
	var size: Int {
		switch self {
			case .three:  5
			case .four:   6
			case .five:   9
			case .six: 	 11
			case .seven: 12
			case .eight: 15
			case .nine:  18
			case .ten:   20
			default: 	  4
		}
	}

	var id: Self { self }
}

enum CreationMode: String, CaseIterable, Identifiable, Codable {
	case oneGame = "1 Game", fiveGames = "5 Games", tenGames = "10 Games", options = "Options"
	
	var id: Self { self }
}

enum HighLight: String, CaseIterable, Identifiable, Codable {
	case outline, fill, both
	
	var isFill: Bool { self == .fill || self == .both }
	var isOutline: Bool { self == .outline || self == .both }
	
	var id: Self { self }
}

enum Vertical: String, CaseIterable, Identifiable, Codable {
	case above, below

	var id: Self { self }
}

enum Horizontal: String, CaseIterable, Identifiable, Codable {
	case left, right

	var id: Self { self }
}
