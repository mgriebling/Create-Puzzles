//
//  ContentView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI
import Subsonic


struct BoardView: View {

    @ObservedObject var game: Game

    static let size = Game.maxSize
    
    // let width = CGFloat(600)
    let columns = Array(repeating: GridItem(.flexible(minimum: 30), spacing: 0), count: size)
    @State var width = CGFloat(800)
    @State var height = CGFloat(750)
    
    var body: some View {
        VStack {
            Text("Word Search").font(.system(.largeTitle).bold())
            Text("Score: \(game.score) %").font(.system(size: 20)).bold()
            
            ZStack {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(game.board.board) { item in
                        //Text(item.letter)
                         //   .padding(10)
                        //    .bold()
                        Rectangle().fill(.clear)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(Text(item.letter).bold().font(.system(size: 25)))
                            .background(
                                game.isHighlighted(item.id) ? .yellow : .white
                            )
                        //                            .onTapGesture {
                        //                                if game.isValidMove(item.id) {
                        //                                    game.addLetter(item.id)
                        //                                    if game.isWordMatch()  {
                        //                                        game.removeActiveWord()
                        //                                    } else if !game.isWordPartialMatch() {
                        //                                        game.clearWord()
                        //                                    }
                        //                                } else {
                        //                                    game.clearWord()
                        //                                }
                        //                            }
                    }
                }
                .aspectRatio(contentMode: .fit)
              //  .border(.blue)
                .onTapGesture { location in
                    //                       play(sound: "ding-47489.mp3")
                    print(location)
                }
                
                // place diagonal highlight
                let word = Word(word: "Alpha", id: 20, direction: .diagonalUpLeft, highlighted: true)
                HighlightView(word: word, size: CGSize(width: width, height: height), cellWidth:BoardView.size)
            }.readSize { size in
                width = size.width - 100
                height = size.height
                print("Width = \(width); Height = \(height)")
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                ForEach(Game.words, id:\.self) { word in
                    HStack {
                        let index = Game.words.firstIndex(of: word)!
                        Text(word.capitalized)
                            .foregroundColor(game.found[index] ? .gray : .black)
                            .bold()
                            .font(.system(size: 22))
                            .strikethrough(game.found[index])
                        Spacer()
                    }
                }
            }
            .padding(50)
            //.frame(maxWidth: width)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(game: Game())
    }
}
