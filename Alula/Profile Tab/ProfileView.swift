//
//  ProfileView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var model: AlulaModel = .shared

    var body: some View {
        VStack {
            if let user = model.user {
                UserView(
                    user: Binding(
                        get: {
                            user
                        },
                        set: { newValue in
                            model.user = newValue
                        }
                    )
                )
            } else {
                ProgressView("Loading...")
            }
        }
    }
}

struct UserView: View {
    @ObservedObject var model: AlulaModel = .shared

    @Binding var user: User
    let disableEditing: Bool
    let hideLocked: Bool

    @State private var isEditingProfilePic = false

    init(user: Binding<User>, disableEditing: Bool = false, hideLocked: Bool = false) {
        self._user = user
        self.disableEditing = disableEditing
        self.hideLocked = hideLocked
    }

    var body: some View {
        VStack {
            VStack {
                user.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .clipShape(.circle)
                    .onTapGesture {
                        if !disableEditing {
                            isEditingProfilePic = true
                        }
                    }

                Text(user.user_id)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            Form {
                Section("Statistics") {
                    if let lastBirdTime = user.last_bird_time {
                        LabeledContent("Last bird identified", value: formatDate(lastBirdTime))
                    }

                    LabeledContent("Total birds caught", value: "\(user.total_birds_caught ?? 0)")
                }

                AllAchievementsView(user: user, hideLocked: hideLocked)
            }
        }
        .sheet(isPresented: $isEditingProfilePic) {
            ProfilePictureCustomizationView(
                profilePic: Binding(
                    get: {
                        user.user_profilepic ?? 0
                    },
                    set: { newValue in
                        isEditingProfilePic = false
                        user.user_profilepic = newValue

                        SupabaseBridge.shared.updateProfilePicture(
                            for: user.user_id,
                            with: newValue
                        )
                    }
                )
            )
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

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

struct ProfilePictureCustomizationView: View {
    @Binding var profilePic: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("Select your profile picture")
                .font(.title)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(1..<7) { index in
                    Button {
                        withAnimation(.smooth(duration: 0.25)) {
                            profilePic = index
                        }
                    } label: {
                        Image("profile_\(index)")
                            .resizable()
                            .scaledToFit()
                            .clipShape(.circle)
                            .padding(12)
                            .overlay {
                                if profilePic == index {
                                    Circle()
                                        .inset(by: 8)
                                        .stroke(.secondary, lineWidth: 4)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium])
    }
}

#Preview {
    ProfileView()
}

#Preview {
    @Previewable @State var profilePic: Int = 1
    ProfilePictureCustomizationView(profilePic: $profilePic)
}
