//
//  BadgeDetails.swift
//  GratefulMoments
//
//  Created by Michael Griebling on 08.07.2026.
//

import SwiftUI

enum BadgeDetails: Int, Codable, CaseIterable {
	case first
	case novice
	case bright
	case skillful
	case expert
	case master
	case ultimate
	
	var requirements: String {
		switch self {
			case .first:
				"Log a moment to start your journey."
			case .novice:
				"Record five moments."
			case .bright:
				"Add a photo to one of your moments."
			case .skillful:
				"Add three entries with photos."
			case .expert:
				"Add five moments with a photo and text."
			case .master:
				"Record at least 10 moments, collecting all the other badges along the way."
			case .ultimate:
				"Achieve all 10 badges."
		}
	}
	
	var congratulatoryMessage: String {
		switch self {
			case .first:
				"Every journey begins with a single step. Congratulations — you’re on your way!"
			case .novice:
				"You’re building momentum! The more you focus on regular practice, the better you get at choosing to keep up your intentioned habits."
			case .bright:
				"Photos are a great way to capture the moment and make it last. You're doing great work!"
			case .skillful:
				"Photos connect us to our past, and looking at them can take us right back to the grateful feeling we had when we snapped them."
			case .expert:
				"Look at you, giving yourself all the ways to savor your happy memories!"
			case .master:
				"You're getting the hang of your new habit! Keep it up and see how far it can take you."
			case .ultimate:
				"You've unlocked the full potential of your gratitude practice. Keep up the great work!"
		}
	}
	
	var title: String {
		switch self {
			case .first: "Start the Journey"
			case .novice:  "5 Stars"
			case .bright: "Bright"
			case .skillful: "Shutterbug"
			case .expert: "Expressive"
			case .master: "Perfect 10"
			case .ultimate: "The Ultimate"
		}
	}
	
	var image: ImageResource {
		switch self {
			case .first: .first
			case .novice:  .novice
			case .bright: .bright
			case .skillful: .skillful
			case .expert: .expert
			case .master: .master
			case .ultimate: .ultimate
		}
	}
	
//	Metal Type			Metal HEX	Primary Accent	 Accent HEX	Aesthetic Vibe
//	Rhodium 			#E2E8F0 	Midnight Blue 	 #0F172A 	Ultra-Modern & Sleek
//	Silver 				#C0C0C0  	Classic Burgundy #722F37 	Traditional & ElegantWhite
//	Gold  				#F3EFE0  	Rich Plum 		 #4A2E35W	arm & Sophisticated
//	Yellow Gold			#FFD700		Matte Black		 #111111	High-End LuxuryBlue
//	Titanium			#4B9CD3		Copper Orange	 #B87333	Bold & High-Tech
//	Platinum-Iridium	#D1D5DB		Crimson Red	 	 #DC2626	Industrial & Powerful
//	Platinum			#E5E4E2		Deep Teal		 #004B49	Clean & Prestigious
	
//	var lockedImage: ImageResource {
//		switch self {
//			case .firstEntry: .firstEntryLocked
//			case .fiveStars:  .fiveStarsLocked
//			case .shutterbug: .shutterbugLocked
//			case .expressive: .expressiveLocked
//			case .perfectTen: .perfectTenLocked
//		}
//	}
	
	var color: Color {
		switch self {
			case .first: Color(.burgandy)
			case .novice:  Color(.yellowGold)
			case .bright: Color(.blueTitanium)
			case .skillful: Color(.whiteGold)
			case .expert: Color(.rhodium)
			case .master: Color(.platinumIridium)
			case .ultimate: Color(.platinum)
		}
	}
}
