//
//  TaskEditorView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation
import SwiftUI

struct TaskEditorView: View {
    @State var viewModel: TaskEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Add title here", text: $viewModel.title, axis: .vertical)
                        .lineLimit(1...3)
                        .focused($titleFocused)
                        .submitLabel(.done)
                }
                
                Section("Description") {
                    TextField("Add any details (optional)", text: $viewModel.details, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section("Status") {
                    Picker("Status", selection: $viewModel.status) {
                        ForEach(TaskStatus.allCases) { status in
                            Label(status.displayName, systemImage: status.systemImage)
                                .tag(status)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                if let createdAt = viewModel.createdAt {
                    Section("Created") {
                        Text(AbsoluteTime.string(from: createdAt))
                            .foregroundStyle(.secondary)
                    }
                    if let updatedAt = viewModel.updatedAt, viewModel.hasBeenEdited {
                        Section("Last Updated") {
                            Text(AbsoluteTime.string(from: updatedAt))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.screenTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() { dismiss() }
                    }
                    .disabled(!viewModel.canSave)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                titleFocused = !viewModel.isEditing
            }
        }
    }
}
