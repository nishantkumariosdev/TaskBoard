//
//  Archiveview.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 14/08/26.
//

import Foundation
import SwiftUI

struct ArchiveView: View {
    @State var viewModel: ArchiveViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pendingDeletion: BoardTask?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                content
            }
            .navigationTitle("Archived")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Delete this task", isPresented: deletionBinding, titleVisibility: .visible, presenting: pendingDeletion) { task in
                Button("Delete", role: .destructive) {
                    viewModel.delete(id: task.id)
                    pendingDeletion = nil
                }
                Button("Cancel", role: .cancel) {
                    pendingDeletion = nil
                }
            } message: { task in
                Text("\"\(task.title)\" will be removed")
            }
        }
        .task {
            await viewModel.start()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isEmpty {
            emptyStateView
        } else {
            allArchivedItem
        }
    }
    
    private var allArchivedItem: some View {
        List {
            Section {
                ForEach(viewModel.tasks) { task in
                    ArchivedRowView(task: task)
                        .contextMenu {
                            Button("Restore to \(task.status.displayName)", systemImage: "arrow.uturn.backward") {
                                withAnimation { viewModel.restore(id: task.id) }
                            }
                            
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                pendingDeletion = task
                            }
                        }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "archivebox")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
            
            Text("Nothing archived")
                .font(.title2.weight(.semibold))
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var deletionBinding: Binding<Bool> {
        Binding(
            get: { pendingDeletion != nil },
            set: { if !$0 { pendingDeletion = nil } }
        )
    }
}

private struct ArchivedRowView: View {
    let task: BoardTask
    
    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(task.status.tint)
                .frame(width: 5)
                .clipShape(Capsule())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack(spacing: 5) {
                    Label(task.status.displayName, systemImage: task.status.systemImage)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(task.status.tint)
                    
                    Text("Archived \(RelativeTime.string(from: task.updatedAt))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }
}
