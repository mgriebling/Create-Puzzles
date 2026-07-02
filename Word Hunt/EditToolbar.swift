//
//  EditToolbar.swift
//  Word Hunt
//
//  Created by Michael Griebling on 01.07.2026.
//

import SwiftUI

struct EditToolbar: ToolbarContent {
	let onDone: (() -> Void)?
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	
	var body: some ToolbarContent {
		ToolbarItem(placement: .cancellationAction) {
			Button("Cancel") { dismiss() }
				.tint(Color(.systemRed))
		}
		ToolbarItem(placement: .confirmationAction) {
			Button("Done") { onDone?(); dismiss() }
				.tint(Color(.systemGreen))
		}
	}
}
