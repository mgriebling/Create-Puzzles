//
//  WinnerView.swift
//  Word Hunt
//
//  Original by Google AI on 06.07.2026.
//  Modified by Michael Griebling on 06.10.2026
//

import SwiftUI

struct WinnerView: View {
	let game: Game
	let width: CGFloat
	let points: Int
	var badge: Badge? = nil
	
	@State private var displayValue = 0
	@State private var winner: Bool = false
	
	var body: some View {
		let scale = width / 270
		let fontSize = (winner ? 50 : 20) * scale
		VStack(spacing: 0) {
			if let badge {
				Image(badge.details.image)
					.resizable()
					.aspectRatio(1, contentMode: .fit)
					.frame(width: 75 * scale, height: 75 * scale)
			}
			Text("WINNER!")
				.font(.system(size: fontSize, weight: .heavy, design: .rounded))
				.lineLimit(1)
			Text("\(displayValue) points")
				.font(.system(size: fontSize/2, weight: .bold, design: .rounded))
				// Forces digits to have equal width to stop shaking
				.monospacedDigit()
				// Enables the rolling number transition
				.contentTransition(.numericText())
				// Triggers the animation when 'count' changes
				.animation(.bouncy, value: points)
		}
		.padding(20*scale)
		.frame(width: width)
		.foregroundStyle(Color.yellow)
		.background(Color(.systemGray))
		.cornerRadius(20*scale)
		.rotationEffect(winner ? .degrees(0) : .degrees(360))
		.scaleEffect(winner ? 1 : 0)
		.opacity(winner ? 1 : 0)
		.onAppear {
			withAnimation(.linear(duration: 3)) {
				winner = game.isOver
			} completion: {
				startCounting()
			}
		}
	}
	
	private func startCounting() {
		// Reset count
		displayValue = 0
		
		// Increment progressively without blocking the main UI thread
		Task {
			for i in 0...points {
				// Adjust speed: lower values skip steps for high targets
				if points > 500 && i % 10 != 0 && i != points { continue }
				
				try? await Task.sleep(for: .milliseconds(10))
				await MainActor.run {
					displayValue = i
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var game = Game(board: GameBoard(size: 15))
	WinnerView(game: game, width: 270, points: 0)
	WinnerView(game: game, width: 400, points: 10, badge: Badge(details: .puzzle1))
	WinnerView(game: game, width: 800, points: 1000, badge: Badge(details: .puzzle100))
}

