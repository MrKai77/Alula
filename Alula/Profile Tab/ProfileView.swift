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

#Preview {
    ProfileView()
}

#Preview {
    @Previewable @State var profilePic: Int = 1
    ProfilePictureCustomizationView(profilePic: $profilePic)
}
