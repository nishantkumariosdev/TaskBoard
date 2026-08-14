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
    let archiveFactory: any ArchiveViewModelFactory
    @State private var editorMode: TaskEditorViewModel.Mode?
    @State private var pendingDeletion: BoardTask?
    @State private var isArchiveShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SyncStatusView(status: viewModel.syncStatus)
                
                if let banner = viewModel.banner {
                    MessageBanner(message: banner) {
                        withAnimation { viewModel.banner = nil }
                    }
                }
                
                content
            }
            .background(Color(.systemBackground))
            .overlay(alignment: .bottomTrailing) { addTaskButton }
            .navigationTitle("Task Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    archiveButton
                }
            }
            .sheet(item: $editorMode) { mode in
                TaskEditorView(viewModel: editorFactory.makeEditorViewModel(mode: mode))
            }
            .sheet(isPresented: $isArchiveShowing) {
                ArchiveView(viewModel: archiveFactory.makeArchiveViewModel())
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
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .loading:
            centered {
                ProgressView("Loading your board…")
            }

        case .failed(let message):
            centered {
                BoardErrorStateView(message: message) { viewModel.load() }
            }

        case .ready:
            boardLayout
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
            onRefresh: { await viewModel.refresh() },
            onArchive: { task in
                viewModel.archive(id: task.id)
            },
            expandedTaskIDs: viewModel.expandedTaskIDs,
            onToggleExpand: { viewModel.toggleExpansion($0.id) },
            onToggleSubtask: { subtask, task in
                viewModel.toggleSubtask(subtask.id, in: task.id)
            },
            onRemoveSubtask: { subtask, task in
                withAnimation { viewModel.removeSubtask(subtask.id, from: task.id) }
            }
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
    
    private var archiveButton: some View {
        Button {
            isArchiveShowing = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "archivebox")
                if viewModel.archiveCount > 0 {
                    Text("\(viewModel.archiveCount)")
                        .font(.caption.weight(.semibold))
                }
            }
        }
    }
    
    private func centered<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var deletionBinding: Binding<Bool> {
        Binding(
            get: { pendingDeletion != nil },
            set: { if !$0 { pendingDeletion = nil } }
        )
    }
}


