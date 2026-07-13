//
//  Settings.swift
//  Word Hunt
//
//  Created by Michael Griebling on 04.07.2026.
//

import SwiftUI

public struct SettingsType {
	static let maxGridRange = 4.0...20.0
	
	var gridDefaultSize: Double
	var player: Player
	
	var highlight: HighLight
	var selectionColor: Color
	var selectionOKColor: Color
	var highlightColor: Color
	
	var soundsOn: Bool
	var soundVolume: Double
	
	var showTimer: Bool
	
	init() {
		self.gridDefaultSize = 12.0
		self.player = Player()
		self.highlight = .allCases.first!
		self.selectionColor = .blue
		self.selectionOKColor = .green
		self.highlightColor = .yellow
		self.soundsOn = true
		self.soundVolume = 0.2
		self.showTimer = true
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
		case gridDefaultSize, player, highlight, selectionColor,
			 selectionOKColor, highlightColor, soundsOn, soundVolume, showTimer
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.gridDefaultSize = try container.decode(Double.self, forKey: .gridDefaultSize)
		self.player = try container.decode(Player.self, forKey: .player)
		self.highlight = try container.decode(HighLight.self, forKey: .highlight)
		self.selectionColor = try container.decode(Color.self, forKey: .selectionColor)
		self.selectionOKColor = try container.decode(Color.self, forKey: .selectionOKColor)
		self.highlightColor = try container.decode(Color.self, forKey: .highlightColor)
		self.soundsOn = try container.decode(Bool.self, forKey: .soundsOn)
		self.soundVolume = try container.decode(Double.self, forKey: .soundVolume)
		self.showTimer = try container.decode(Bool.self, forKey: .showTimer)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.gridDefaultSize, forKey: .gridDefaultSize)
		try container.encode(self.player, forKey: .player)
		try container.encode(self.highlight, forKey: .highlight)
		try container.encode(self.selectionColor, forKey: .selectionColor)
		try container.encode(self.selectionOKColor, forKey: .selectionOKColor)
		try container.encode(self.highlightColor, forKey: .highlightColor)
		try container.encode(self.soundsOn, forKey: .soundsOn)
		try container.encode(self.soundVolume, forKey: .soundVolume)
		try container.encode(self.showTimer, forKey: .showTimer)
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

enum HighLight: String, CaseIterable, Identifiable, Codable {
	case outline, fill, both
	
	var id: Self { self }
}
