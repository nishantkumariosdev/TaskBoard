//
//  LastSyncedView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation
import SwiftUI

struct LastSyncedView: View {
    let lastSyncedAt: Date?

    var body: some View {
        if let lastSyncedAt {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.icloud")
                    .font(.caption)
                    .foregroundStyle(.green)

                Text("Last synced \(RelativeTime.string(from: lastSyncedAt))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.bar)
            .overlay(alignment: .bottom) { Divider() }
            .accessibilityElement(children: .combine)
        }
    }
}
