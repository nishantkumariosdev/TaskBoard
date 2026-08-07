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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                boardLayout
            }
            .background(Color(.systemBackground))
            .overlay(alignment: .bottomTrailing) { addTaskButton }
            .navigationTitle("Task Board")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editorMode) { mode in
                TaskEditorView(viewModel: editorFactory.makeEditorViewModel(mode: mode))
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
            onDelete: {_ in },
            onMove: {_,_ in },
            onAdd: { editorMode = .create(status: $0) }
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
}


