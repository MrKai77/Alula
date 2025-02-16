//
//  CommunityView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct CommunityView: View {
    @State private var users: [User] = []
    @State private var achievements: [Achievement] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Leaderboard") {
                    List(users.sorted(by: { $0.total_birds_caught ?? 0 > $1.total_birds_caught ?? 0 })) { user in
                        LeaderboardUserView(user: user, allAchievements: achievements)
                    }
                }
                .listRowBackground(Color.primary.opacity(0.125))
                .listRowSeparatorTint(.primary.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .background { BackgroundView() }
            .navigationTitle("Community")
        }
        .task {
            do {
                users = try await SupabaseBridge.shared.loadUsers()
                achievements = try await SupabaseBridge.shared.loadAchievements()
            } catch {
                print("Failed to fetch users: \(error)")
            }
        }
    }
}

#Preview {
    CommunityView()
}
