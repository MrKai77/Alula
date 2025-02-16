//
//  ProfileView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct ProfileView: View {
    @State private var user: User?

    var body: some View {
//        NavigationStack {
////            Form {
//////                Section("Leaderboard") {
//////                    List(users.sorted(by: { $0.total_birds_caught ?? 0 > $1.total_birds_caught ?? 0 })) { user in
//////                        UserView(user: user)
//////                    }
//////                }
////            }
////            .navigationTitle("Community")
//        }
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
            } catch {
                print("Failed to fetch users: \(error)")
            }
        }
    }

    func userView(_ user: User) -> some View {
        VStack {
            user.image
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .clipShape(.circle)

            Text(user.user_id)
                .font(.largeTitle)
                .fontWeight(.bold)

            Form {
                Section("Statistics") {
                    if let lastBirdTime = user.last_bird_time {
                        LabeledContent("Last bird identified", value: formatDate(lastBirdTime))
                    }

                    if let totalBirdsCaught = user.total_birds_caught {
                        LabeledContent("Total birds caught", value: "\(totalBirdsCaught)")
                    }
                }

//                if let achievements = user.getUnlockedAchievements() {
//                    Section("Achievements") {
//                        List(achievements) { achievement in
//                            AchievementView(achievement: achievement)
//                        }
//                    }
//                }
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
            Image(systemName: "star")
                .foregroundColor(.yellow)

            Text(achievement.achievement_name ?? "Unknown achievement")
        }
    }
}

#Preview {
    ProfileView()
}
