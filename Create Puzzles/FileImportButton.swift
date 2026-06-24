//
//  FileImportButton.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 24.06.2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileImportButton: View {
	@State private var isImporting = false

	var body: some View {
		Button(action: { isImporting = true }) {
			Label("Import File", systemImage: "square.and.arrow.down")
		}
		.fileImporter(
			isPresented: $isImporting,
			allowedContentTypes: [.text] // Change to [.pdf], [.image], etc. as needed
		) { result in
			switch result {
			case .success(let fileURL):
				print("Imported file path: \(fileURL.absoluteString)")
			case .failure(let error):
				print("Import failed: \(error.localizedDescription)")
			}
		}
	}
}


#Preview {
    FileImportButton()
}
