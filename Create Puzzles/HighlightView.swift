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
    var cellWidth: Int
    
    var body: some View {
        // place horizontal highlight
        let len = CGFloat(word.word.count)
        let xsize = size.width / CGFloat(cellWidth)
        let ysize = size.height / CGFloat(cellWidth)
        switch word.direction {
            case .left, .right:
                getView2(xsize: xsize, ysize: ysize, id: word.id, len: len)
            case .up, .down:
                // place vertical highlight
                getView1(xsize: xsize, ysize: ysize, id: word.id, len: len)
            case .diagonalDownLeft, .diagonalUpRight:
                getView3(xsize: xsize, ysize: ysize, id: word.id, len: len)
            case .diagonalDownRight, .diagonalUpLeft:
                getView4(xsize: xsize, ysize: ysize, id: word.id, len: len)
        }
    }
    
    @ViewBuilder
    func getView1(xsize: CGFloat, ysize: CGFloat, id: Int, len: CGFloat) -> some View {
        let (x,y) = GameBoard.indexToRowCol(id)
        let xshift = CGFloat(x-1) * xsize
        let yshift = ((len-1) * ysize)/2 + CGFloat(y-1) * ysize
        Capsule()
            .stroke(.blue, lineWidth: 4)
            .frame(width:25, height: ysize*len, alignment: .leading)
            .offset(x:-286+xshift, y:-260+yshift)
    }
    
    @ViewBuilder
    func getView2(xsize: CGFloat, ysize: CGFloat, id: Int, len: CGFloat) -> some View {
        let (x,y) = GameBoard.indexToRowCol(id)
        let xshift = (len-1)*xsize/CGFloat(2) + CGFloat(x-1)*xsize
        let yshift = CGFloat(y-1) * ysize
        Capsule()
            .stroke(.blue, lineWidth: 4)
            .frame(width:xsize*len, height: 25, alignment: .leading)
            .offset(x:-285+xshift, y:-260+yshift)
    }
    
    @ViewBuilder
    func getView3(xsize: CGFloat, ysize: CGFloat, id: Int, len: CGFloat) -> some View {
        let (x,y) = GameBoard.indexToRowCol(id)
        let xysize = CGFloat(sqrt(xsize * xsize + ysize * ysize))
        let length = xysize * len
        let xshift = (CGFloat(1-len)*CGFloat(xsize))/2 + CGFloat(x-1) * CGFloat(xsize)
        let yshift = (CGFloat(len-1)*CGFloat(ysize))/2 + CGFloat(y-1) * CGFloat(ysize)
        Capsule()
            .stroke(.blue, lineWidth: 4)
            .frame(width:length, height: 25, alignment: .leading)
            .rotationEffect(.degrees(-42))
            .offset(x:-284+xshift, y:-258+yshift)
    }
    
    @ViewBuilder
    func getView4(xsize: CGFloat, ysize: CGFloat, id: Int, len: CGFloat) -> some View {
        let (x,y) = GameBoard.indexToRowCol(id)
        let xysize = CGFloat(sqrt(xsize * xsize + ysize * ysize))
        let length = xysize * len
        let xshift = (CGFloat(len-1)*CGFloat(xsize))/2 + CGFloat(x-1) * CGFloat(xsize)
        let yshift = (CGFloat(len-1)*CGFloat(ysize))/2 + CGFloat(y-1) * CGFloat(ysize)
        Capsule()
            .stroke(.blue, lineWidth: 4)
            .frame(width:length, height: 25, alignment: .leading)
            .rotationEffect(.degrees(42))
            .offset(x:-284+xshift, y:-258+yshift)
    }
    
    
}
