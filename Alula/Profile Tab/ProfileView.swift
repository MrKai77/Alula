//
//  ProfileView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var model: AlulaModel = .shared

    @State private var user: User?
    @State private var allAchievements: [Achievement]?

    var body: some View {
        VStack {
            if let user {
                userView(user)
            } else {
                ProgressView("Loading...")
            }
        }
        .task {
            do {
                user = try await SupabaseBridge.shared.loadUsers().first
                allAchievements = try await SupabaseBridge.shared.loadAchievements()
            } catch {
                print("Failed to fetch users: \(error)")
            }
        }
    }

    func userView(_ user: User) -> some View {
        VStack {
            VStack {
                user.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .clipShape(.circle)

                Text(user.user_id)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            Form {
                Section("Statistics") {
                    if let lastBirdTime = user.last_bird_time {
                        LabeledContent("Last bird identified", value: formatDate(lastBirdTime))
                    }

                    if let totalBirdsCaught = user.total_birds_caught {
                        LabeledContent("Total birds caught", value: "\(model.takenImages.count)")
                    }
                }

                if let allAchievements {
                    let achievements = user.getUnlockedAchievements(allAchievements: allAchievements)

                    Section("Achievements") {
                        List(achievements) { achievement in
                            AchievementView(achievement: achievement)
                        }
                    }
                }
            }
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
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

#Preview {
    ProfileView()
}
