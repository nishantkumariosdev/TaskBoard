//
//  BoardView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation
import SwiftUI

struct BoardView: View {
    @State var viewModel: BoardViewModel
    
    let editorFactory: any TaskEditorViewModelFactory
    @State private var editorMode: TaskEditorViewModel.Mode?
    @State private var pendingDeletion: BoardTask?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                LastSyncedView(lastSyncedAt: viewModel.lastSyncedAt)
                
                boardLayout
            }
            .background(Color(.systemBackground))
            .overlay(alignment: .bottomTrailing) { addTaskButton }
            .navigationTitle("Task Board")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editorMode) { mode in
                TaskEditorView(viewModel: editorFactory.makeEditorViewModel(mode: mode))
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
                Text("\"\(task.title)\" will be removed from task board")
            }
        }
        .task {
            await viewModel.start()
        }
    }
    
    private var boardLayout: some View {
        verticalBoard
            .overlay { emptyStateOverlay }
    }
    
    private var verticalBoard: some View {
        BoardListView(
            columns: viewModel.columns,
            collapsedStatuses: viewModel.collapsedStatuses,
            onToggleCollapse: { viewModel.toggleCollapse($0) },
            onEdit: { editorMode = .edit(task: $0) },
            onDelete: { pendingDeletion = $0 },
            onMove: { task, status in
                viewModel.move(id: task.id, to: status, position: 0)
            },
            onAdd: { editorMode = .create(status: $0) },
            onDropTask: { taskId, status, index in
                viewModel.handleDrop(taskId: taskId, into: status, at: index)
            },
            onRefresh: { await viewModel.refresh() }
        )
    }
    
    @ViewBuilder
    private var emptyStateOverlay: some View {
        if viewModel.isBoardEmpty {
            BoardEmptyStateView {
                editorMode = .create(status: .todo)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
    
    @ViewBuilder
    private var addTaskButton: some View {
        if !viewModel.isBoardEmpty {
            Button {
                editorMode = .create(status: .todo)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.accentColor)
                    .shadow(color: .black.opacity(0.20), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
            .padding(.bottom, 25)
        }
    }
    
    private var deletionBinding: Binding<Bool> {
        Binding(
            get: { pendingDeletion != nil },
            set: { if !$0 { pendingDeletion = nil } }
        )
    }
}


