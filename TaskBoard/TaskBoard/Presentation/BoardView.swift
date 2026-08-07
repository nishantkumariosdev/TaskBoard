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
            viewModel.onAppear()
        }
    }
    
    private var boardLayout: some View {
        GeometryReader { proxy in
            Group {
                verticalBoard
            }
        }
        .overlay { emptyStateOverlay }
    }
    
    private var verticalBoard: some View {
        BoardListView(columns: viewModel.columns, collapsedStatuses: viewModel.collapsedStatuses, onToggleCollapse: {_ in }, onEdit: {_ in }, onDelete: {_ in }, onMove: {_,_ in }, onAdd: {_ in })
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


