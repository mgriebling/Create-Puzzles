//
//  HighlightView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-12.
//

import SwiftUI

struct HighlightView: View {
	var word: Word
    var size: CGSize
    var cellWidth: CGFloat
    
    var body: some View {
        let len = CGFloat(word.word.count)
        let xsize = cellWidth // size.width / cellWidth
        let ysize = cellWidth // size.height / cellWidth
        switch word.direction {
            case .left, .right:
                getView2(xsize: xsize, ysize: ysize, id: word.id, len: len)
            case .up, .down:
                getView1(xsize: xsize, ysize: ysize, id: word.id, len: len)
            case .diagonalDownLeft, .diagonalUpRight:
				getView3(xsize: xsize, ysize: ysize, id: word.id, len: len)
            case .diagonalDownRight, .diagonalUpLeft:
				getView4(xsize: xsize, ysize: ysize, id: word.id, len: len)
        }
    }
    
    @ViewBuilder
    func getView1(xsize: CGFloat, ysize: CGFloat, id: Int, len: CGFloat) -> some View {
		// Up/down highlights
        let z = GameBoard.indexToRowCol(id)
		let x = CGFloat(z.col)
		let y = CGFloat(z.row) - (word.direction == .up ? (len-1) : 0)
		let xshift = CGFloat(x - 9) * xsize - 48 // 0 - -48
		let yshift = CGFloat(y - 10) * ysize + (y * 22.7) - 95 // 0 - 95, 13 - 200
        Capsule()
            .stroke(.blue, lineWidth: 4)
			.frame(width:xsize, height: ysize*(len+1), alignment: .leading)
            .offset(x:xshift, y:yshift)
			.onAppear {
				print("1. Showing highlight for \(word.word) direction \(word.direction), size: \(xsize)")
			}
    }
    
    @ViewBuilder
    func getView2(xsize: CGFloat, ysize: CGFloat, id: Int, len: CGFloat) -> some View {
		// Left/right highlights
		let z = GameBoard.indexToRowCol(id)
		let x = CGFloat(z.col) - (word.direction == .left ? (len-1) : 0)
		let y = CGFloat(z.row)
		let xshift = CGFloat(x - 9) * xsize + (x * 7.69) + 54  // 0 - 54, 13 - 154
		let yshift = CGFloat(y - 10) * ysize + (y * 8.0) - 5 // 0 - -5, 17 - 132
        Capsule()
            .stroke(.blue, lineWidth: 4)
            .frame(width:xsize*(len+1), height: ysize, alignment: .leading)
            .offset(x:xshift, y:yshift)
			.onAppear {
				print("2. Showing highlight for \(word.word) direction \(word.direction), xsize: \(xsize), xy: \(x),\(y)")
			}
    }
    
    @ViewBuilder
    func getView3(xsize: CGFloat, ysize: CGFloat, id: Int, len: CGFloat) -> some View {
		// Diagonal down left/up right
        let (y,x) = GameBoard.indexToRowCol(id)
        let xysize = CGFloat(sqrt(xsize * xsize + ysize * ysize))
        let length = xysize * len
        let xshift = CGFloat(x-1) * xsize - size.width/2 + 145
        let yshift = CGFloat(y-1) * ysize - size.height/2 - 115
        Capsule()
            .stroke(.blue, lineWidth: 4)
            .frame(width:length, height: ysize, alignment: .leading)
            .rotationEffect(.degrees(-45))
            .offset(x:xshift, y:yshift)
			.onAppear {
				print("3. Showing highlight for \(word.word) direction \(word.direction)")
			}
    }
    
    @ViewBuilder
    func getView4(xsize: CGFloat, ysize: CGFloat, id: Int, len: CGFloat) -> some View {
		let (y,x) = GameBoard.indexToRowCol(id)
        let xysize = CGFloat(sqrt(xsize * xsize + ysize * ysize))
        let length = xysize * len
		let xshift = CGFloat(x-1) * xsize - size.width/2 + 93
		let yshift = CGFloat(y-1) * ysize - size.height/2 + 93
        Capsule()
            .stroke(.blue, lineWidth: 4)
            .frame(width:length, height: ysize, alignment: .leading)
            .rotationEffect(.degrees(45))
            .offset(x:xshift, y:yshift)
			.onAppear {
				print("4. Showing highlight for \(word.word) direction \(word.direction)")
			}
    }
    
    
}
