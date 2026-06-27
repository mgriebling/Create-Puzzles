//
//  HighlightView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-12.
//

import SwiftUI

struct HighlightView: View {
	var word: PlacedWord
    var size: CGSize
	let board: GameBoard
	var scale: CGFloat = 1
	
	let spacing: CGFloat = 8
    
    var body: some View {
		let numberOfCells = board.size
        let len = CGFloat(word.word.count)
        let size = size.width / CGFloat(numberOfCells)
		let center = CGFloat(numberOfCells) / 2
        switch word.direction {
            case .left, .right:
				getView2(size: size, center: center, id: word.id, len: len)
            case .up, .down:
                getView1(size: size, center: center, id: word.id, len: len)
            case .diagonalDownLeft, .diagonalUpRight:
				getView3(size: size, center: center, id: word.id, len: len)
            case .diagonalDownRight, .diagonalUpLeft:
				getView4(size: size, center: center, id: word.id, len: len)
        }
    }
    
    @ViewBuilder
    func getView1(size: CGFloat, center: CGFloat, id: Int, len: CGFloat) -> some View {
		// Up/down highlights
        let z = board.indexToRowCol(id)
		let xs = spacing / self.size.width
		let x = CGFloat(z.col) + 0.4 + xs * CGFloat(z.col)
		let y = CGFloat(z.row) + (word.direction == .up ? -len/2+1 : len/2)
		let xshift = CGFloat(x - center) * size
		let yshift = CGFloat(y - center) * size
        Capsule()
            .stroke(.blue, lineWidth: 4*scale)
			.frame(width:size, height: size*(len), alignment: .leading)
            .offset(x:xshift, y:yshift)
    }
    
    @ViewBuilder
    func getView2(size: CGFloat, center: CGFloat, id: Int, len: CGFloat) -> some View {
		// Left/right highlights
		let z = board.indexToRowCol(id)
		let ys = spacing / self.size.height
		let x = CGFloat(z.col) - (word.direction == .left ? len/2 - 1 : -len/2)
		let y = CGFloat(z.row) + 0.4 + ys * CGFloat(z.row)
		let xshift = CGFloat(x - center) * size
		let yshift = CGFloat(y - center) * size
        Capsule()
            .stroke(.blue, lineWidth: 4*scale)
            .frame(width:size*(len), height: size, alignment: .leading)
            .offset(x:xshift, y:yshift)
    }
    
    @ViewBuilder
    func getView3(size: CGFloat, center: CGFloat, id: Int, len: CGFloat) -> some View {
		// Diagonal down left/up right
        let z = board.indexToRowCol(id)
		let offset = word.direction == .diagonalDownLeft ? -len/2+1 : len/2
		let x = CGFloat(z.col) + offset
		let y = CGFloat(z.row) - offset + 1
        let xysize = CGFloat(sqrt(2 * size * size))
        let length = xysize * len
        let xshift = CGFloat(x-center) * size
        let yshift = CGFloat(y-center) * size
        Capsule()
            .stroke(.blue, lineWidth: 4*scale)
			.frame(width:length, height: size*0.8, alignment: .leading)
            .rotationEffect(.degrees(-45))
            .offset(x:xshift, y:yshift)
    }
    
    @ViewBuilder
    func getView4(size: CGFloat, center: CGFloat, id: Int, len: CGFloat) -> some View {
		// Diagonal down right/up left
		let z = board.indexToRowCol(id)
		let offset = word.direction == .diagonalUpLeft ? -len/2+1 : len/2
		let x = CGFloat(z.col) + offset
		let y = CGFloat(z.row) + offset
        let xysize = CGFloat(sqrt(2 * size * size))
        let length = xysize * len
		let xshift = CGFloat(x-center) * size
		let yshift = CGFloat(y-center) * size
        Capsule()
            .stroke(.blue, lineWidth: 4*scale)
			.frame(width:length*0.95, height: size*0.8, alignment: .leading)
            .rotationEffect(.degrees(45))
            .offset(x:xshift, y:yshift)
    }
    
    
}
