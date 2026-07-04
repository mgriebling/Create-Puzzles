//
//  Settings.swift
//  Word Hunt
//
//  Created by Michael Griebling on 04.07.2026.
//

import SwiftUI

struct Settings : Codable {
	static let maxRange = 4.0...20.0
	
	var gridDefaultSize: Double
	var userName: String
	var highlight: HighLight
	var selectionColor: Color
	var selectionOKColor: Color
	var highlightColor: Color
	var soundsOn: Bool
	var soundVolume: Double
	
	init() {
		self.gridDefaultSize = 12.0
		self.userName = "Unknown"
		self.highlight = .allCases.first!
		self.selectionColor = .blue
		self.selectionOKColor = .green
		self.highlightColor = .yellow
		self.soundsOn = true
		self.soundVolume = 0.2
	}
}

extension Settings: RawRepresentable {
	
	public var rawValue: String {
		guard let data = try? JSONEncoder().encode(self),
			  let string = String(data: data, encoding: .utf8)
		else {
			return ""
		}
		return string
	}
	
	public init?(rawValue: String) {
		guard let data = rawValue.data(using: .utf8),
			  let result = try? JSONDecoder().decode(Settings.self, from: data)
		else {
			return nil
		}
		self = result
	}
}

extension Color: @retroactive Codable, @retroactive RawRepresentable {
	
	public var rawValue: String { "\(self.toInt)" }
	
	public init?(rawValue: String) { self = Color(Int(rawValue) ?? 0) }
	
	public func encode(to encoder: any Encoder) {
		var container = encoder.singleValueContainer()
		try? container.encode(self.toInt)
	}
	
	public init(from decoder: Decoder) {
		if let container = try? decoder.singleValueContainer() {
			if let rgb = try? container.decode(Int.self) {
				self = Color(rgb)
				return
			}
		}
		self = Color.black // default color
	}
}

enum HighLight: String, CaseIterable, Identifiable, Codable, RawRepresentable {
	case outline, fill, both
	
	var id: Self { self }
}
