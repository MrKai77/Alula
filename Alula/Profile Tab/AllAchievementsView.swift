//
//  AllAchievementsView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-16.
//

import SwiftUI

struct AllAchievementsView: View {
    let user: User
    let hideLocked: Bool
    @State private var allAchievements: [Achievement]?

    var unlockedAchievements: [Achievement] {
        user.getUnlockedAchievements(allAchievements: allAchievements ?? [])
    }

    var lockedAchievements: [Achievement] {
        allAchievements?.filter { achievement in
            !unlockedAchievements.contains {
                $0.achievement_id == achievement.achievement_id
            }
        } ?? []
    }

    var body: some View {
        Section("Achievements") {
            List(unlockedAchievements) { achievement in
                AchievementView(achievement: achievement)
            }

            if !hideLocked, !lockedAchievements.isEmpty {
                List(lockedAchievements) { achievement in
                    AchievementView(achievement: achievement)
                }
                .opacity(0.25)
            }
        }
        .task {
            do {
                allAchievements = try await SupabaseBridge.shared.loadAchievements()
            } catch {
                print("Failed to fetch users: \(error)")
            }
        }
    }
}

struct AchievementView: View {
    let achievement: Achievement

    var body: some View {
        HStack {
            achievement.image
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(achievement.achievement_name ?? "Unknown achievement")

                Text(achievement.achievement_desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
            }
        }
    }
}
