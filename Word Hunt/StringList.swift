//
//  StringList.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct ListItem: Identifiable, Hashable {
	let id: UUID
	var title: String
	
	init(_ title: String) {
		self.id = UUID()
		self.title = title
	}
}

struct StringList: View {
	let title: String
	@Binding var strings: [String]
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	
	@State private var lstrings = [ListItem]()
	@State private var selectedItem: ListItem?
	@State private var editString: String = ""
	
	var body: some View {
		List(selection: $selectedItem) {
			ForEach(lstrings) { item in
				let index = lstrings.firstIndex(where: { $0.id == item.id })!
				HStack {
					Text("\(index+1))").frame(width: 40)
					TextField("Edit Word", text: $lstrings[index].title)
						.autocorrectionDisabled(true)
						.onSubmit {
							let edited = lstrings[index].title.lowercased()
								.filter { $0.isLetter }
							withAnimation {
								lstrings[index].title = edited
							}
						}
						.padding(.leading, 70)
						.frame(width: 200, height: 40)
						.textFieldStyle(.plain)
						.background(.blue.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
				}
				.padding(.top, -20)
				.font(.title3).bold()
			}
			.onDelete { indexSet in
				indexSet.forEach { item in
					lstrings.remove(at: item)
				}
			}
		}
		.onAppear {
			lstrings = strings.map { ListItem($0) }
		}
		.navigationTitle("\(title) Words")
		.listStyle(.plain)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") { dismiss() }
			}
			ToolbarItem(placement: .automatic) { addButton }
			#if os(iOS)
			ToolbarItem(placement: .automatic) { EditButton() }
			#endif
			ToolbarItem(placement: .confirmationAction) {
				Button("Done") { done() }
			}
		}
	}
		
	var addButton: some View {
		Button("Add Word", systemImage: "plus") {
			// Add a unique name
			let strings = lstrings.map(\.title)
			var postFix: Int = 1
			let itemName: String
			if let _ = strings.firstIndex(of: "untitled") {
				while strings.contains("untitled\(postFix)") {
					postFix += 1
				}
				itemName = "untitled\(postFix)"
			} else {
				itemName = "untitled"
			}
			withAnimation {
				lstrings.insert(ListItem(itemName), at: 0)
			}
		}
	}
	
	func done() {
		strings = lstrings.map(\.title)
		dismiss()
	}
}

#Preview {
	@Previewable @State var strings = SampleWordLists.all[0].words
	NavigationStack {
		StringList(title: SampleWordLists.all[0].name, strings: $strings)
	}
}
