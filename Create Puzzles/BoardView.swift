//
//  ContentView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI



struct BoardView: View {

    @ObservedObject var game: Game

    static let size = Game.maxSize
    
    let width = CGFloat(600)
    let columns = (1...size).map { col in GridItem(.flexible()) }
    
    var body: some View {
        VStack {
            Text("Word Search").font(.system(.largeTitle))
            Text("Score: \(game.score) %")
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(game.board.board) { item in
                    Text(item.letter)
                        .bold(true)
                        .background(game.isHighlighted(item.id) ? .yellow : .white)
                        .onTapGesture {
                            if game.isValidMove(item.id) {
                                game.addLetter(item.id)
                                if game.isWordMatch()  {
                                    game.removeActiveWord()
                                } else if !game.isWordPartialMatch() {
                                    game.clearWord()
                                }
                            } else {
                                game.clearWord()
                            }
                        }
                }
            }
            .frame(maxWidth: width, maxHeight: width)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(Game.words, id:\.self) { word in
                    HStack {
                        let index = Game.words.firstIndex(of: word)!
                        Text(word.capitalized)
                            .bold(!game.found[index])
                            .strikethrough(game.found[index])
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: width)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(game: Game())
    }
}
