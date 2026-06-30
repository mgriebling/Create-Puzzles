//
//  WordHunt.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI

@main
struct WordHunt: App {
    var body: some Scene {
        WindowGroup {
			GeometryReader { geometry in
				GameChooser()
					.environment(\.sceneFrame, geometry.frame(in: .global))
			}
			.ignoresSafeArea()
        }
    }
}

extension EnvironmentValues {
	@Entry var sceneFrame: CGRect = .zero
}
