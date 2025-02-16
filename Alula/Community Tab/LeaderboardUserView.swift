//
//  LeaderboardUserView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-16.
//

import SwiftUI

struct LeaderboardUserView: View {
    @ObservedObject var model: AlulaModel = .shared

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

    @State private var isShowingAchievementsSheet: Bool = false

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
                        .fontWeight(.semibold)

                    Text("Identified a \(birdName) at \(date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(user.total_birds_caught ?? 0) birds identified")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                if user.user_id != model.user?.user_id {
                    AddFriendButton()
                }
            }

            Button {
                isShowingAchievementsSheet = true
            } label: {
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
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShowingAchievementsSheet) {
            UserView(user: .constant(user), disableEditing: true, hideLocked: true)
                .padding(.top, 48)
                .presentationDragIndicator(.visible)
                .presentationBackground {
                    BackgroundView()
                }
        }
    }
}

struct AddFriendButton: View {
    @State private var didAddFriend: Bool = false

    var body: some View {
        Button {
            withAnimation(.smooth) {
                didAddFriend = true
            }
        } label: {
            Image(systemName: didAddFriend ? "checkmark" : "person.badge.plus")
        }
        .foregroundStyle(.green)
    }
}
