//
//  Player.swift
//  Word Hunt
//
//  Created by Michael Griebling on 13.07.2026.
//

import Foundation

struct Player : Codable {
	var name: String = "Unknown"
	var points: Int = 0
	
	mutating func add(points: Int) {
		self.points += points
	}
}
