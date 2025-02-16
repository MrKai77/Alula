//
//  CommunityView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct CommunityView: View {
    @State private var users: [User] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Leaderboard") {
                    List(users.sorted(by: { $0.total_birds_caught ?? 0 > $1.total_birds_caught ?? 0 })) { user in
                        UserView(user: user)
                    }
                }
            }
            .navigationTitle("Community")
        }
        .task {
            do {
                users = try await SupabaseBridge.shared.loadUsers()
            } catch {
                print("Failed to fetch users: \(error)")
            }
        }
    }
}

struct UserView: View {
    let user: User

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

    var body: some View {
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
    }
}

#Preview {
    CommunityView()
}
