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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                boardLayout
            }
            .background(Color(.systemBackground))
            .navigationTitle("Task Board")
            .navigationBarTitleDisplayMode(.inline)
            
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
            VStack(spacing: 16) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                
                VStack(spacing: 6) {
                    Text("Your board is empty")
                        .font(.title3.weight(.semibold))
                    Text("Add a task to get started")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Button(action: {}) {
                    Label("Add your first task", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(32)
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
}


