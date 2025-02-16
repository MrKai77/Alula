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
                        UserView(user: user, allAchievements: achievements)
                    }
                }
            }
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

struct UserView: View {
    let user: User
    let allAchievements: [Achievement]

    var birdName: String {
        let bird = PredictionConverter.convert(from: user.last_bird_id ?? 0) ?? "bird"
        let components = bird.components(separatedBy: "(")
        return (components.first ?? bird)
            .trimmingCharacters(in: .whitespaces)
    }

    var date: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: user.last_bird_time ?? Date())
    }

    var achievements: [Achievement] {
        user.getUnlockedAchievements(allAchievements: allAchievements)
            .reversed()
    }

    var body: some View {
        VStack {
            HStack {
                user.image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                    .clipShape(.circle)

                VStack(alignment: .leading) {
                    Text(user.user_id)

                    Text("Identified a \(birdName) at \(date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(user.total_birds_caught ?? 0) birds identified")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                if achievements.isEmpty {
                    Text("No Achievements Unlocked")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ZStack {
                        ForEach(Array(achievements.enumerated()), id: \.element.id) { index, achievement in
                            achievement.image
                                .resizable()
                                .scaledToFit()
                                .randomRotation(minRange: -10, maxRange: 10)
                                .offset(x: CGFloat(index) * -20)
                                .zIndex(Double(-index))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .frame(height: 50)
        }
    }
}


struct RandomRotationEffect: ViewModifier {
    let minRange: Double
    let maxRange: Double
    let rotation: Double

    init(minRange: Double, maxRange: Double) {
        self.minRange = minRange
        self.maxRange = maxRange
        self.rotation = Double.random(in: minRange...maxRange)
    }

    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(rotation))
    }
}

extension View {
    func randomRotation(minRange: Double, maxRange: Double) -> some View {
        self.modifier(RandomRotationEffect(minRange: minRange, maxRange: maxRange))
    }
}

#Preview {
    CommunityView()
}
