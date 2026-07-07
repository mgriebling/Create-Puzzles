//
//  WinnerView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 06.07.2026.
//

import SwiftUI

struct WinnerView: View {
	let game: Game
	let width: CGFloat
	
	var body: some View {
		let winner = game.isOver
		let scale = width / 270
		let fontSize = (winner ? 50 : 20)*scale
		Text("WINNER!")
			.font(.system(size: fontSize, weight: .heavy, design: .rounded))
			.lineLimit(1)
			.padding(20*scale)
			.frame(width: width)
			.foregroundStyle(Color.yellow)
			.background(Color(.gray).opacity(0.7))
			.cornerRadius(20*scale)
			.rotationEffect(winner ? .degrees(0) : .degrees(360))
			.scaleEffect(winner ? 1 : 0)
			.opacity(winner ? 1 : 0)
			.animation(.easeIn(duration: 3), value: winner)
	}
}

#Preview {
	@Previewable @State var game = Game(board: GameBoard(size: 15))
	WinnerView(game: game, width: 270)
	WinnerView(game: game, width: 400)
	WinnerView(game: game, width: 800)
}

