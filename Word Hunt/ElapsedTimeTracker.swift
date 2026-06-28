//
//  ElapsedTimeTracker.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 5/21/25.
//

import SwiftUI
import SwiftData

extension View {
    func trackElapsedTime(in game: Game) -> some View {
        self.modifier(ElapsedTimeTracker(game: game))
    }
}

struct ElapsedTimeTracker: ViewModifier {
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) var scenePhase
    let game: Game
    
    var modelContextWillSavePublisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(
            for: ModelContext.willSave,
            object: modelContext
        )
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
				game.timer.start()
            }
            .onDisappear {
				game.timer.pause()
            }
            .onChange(of: game) { oldGame, newGame in
				oldGame.timer.pause()
				newGame.timer.start()
            }
            .onChange(of: scenePhase) {
                switch scenePhase {
					case .active: game.timer.start()
					case .background: game.timer.pause()
					default: break
                }
            }
            .onReceive(modelContextWillSavePublisher) { _ in
				game.timer.update()
				print("updated elapsed time to \(game.timer.elapsedTime)")
            }
    }
}

