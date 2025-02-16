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

    @State private var isEditingProfilePic = false

    var body: some View {
        VStack {
            if let user {
                userView(user)
            } else {
                ProgressView("Loading...")
            }
        }
        .sheet(isPresented: $isEditingProfilePic) {
            ProfilePictureCustomizationView(
                profilePic: Binding(
                    get: {
                        user?.user_profilepic ?? 0
                    },
                    set: { newValue in
                        isEditingProfilePic = false
                        user?.user_profilepic = newValue

                        guard let id = user?.user_id else { return }
                        SupabaseBridge.shared.updateProfilePicture(
                            for: id,
                            with: newValue
                        )
                    }
                )
            )
        }
        .task {
            do {
                user = try await SupabaseBridge.shared.loadUsers().first { $0.user_id == "adly42" }
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
                    .onTapGesture {
                        isEditingProfilePic = true
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

                    LabeledContent("Total birds caught", value: "\(model.takenImages.count)")
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
