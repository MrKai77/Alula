//
//  SupabaseBridge.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI
import Supabase

class SupabaseBridge {
    static let shared: SupabaseBridge = .init()

    private let client: SupabaseClient

    private static let url: URL = URL(string: "https://qcxeawytidjttqxgyrvm.supabase.co")!
    private static let key: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFjeGVhd3l0aWRqdHRxeGd5cnZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2NDkwODUsImV4cCI6MjA1NTIyNTA4NX0.auSekok-f-tGo32saXKeXiD2WWBopg1iiyB8R5bDrVg"


    private init() {
        self.client = SupabaseClient(
            supabaseURL: Self.url,
            supabaseKey: Self.key
        )
    }

    func loadAchievements() async throws -> [Achievement] {
        do {
            let achievements: [Achievement] = try await client
                .from("achievements")
                .select()
                .execute()
                .value

            return achievements
        } catch {
            print(error)
            throw error
        }
    }

    func loadFriends() async throws -> [User] {
        do {
            let users: [User] = try await client
                .from("users")
                .select()
                .execute()
                .value

            return users
        } catch {
            print(error)
            throw error
        }
    }
}

struct Achievement: Codable {
    let achievement_id: Int
    let achievement_desc: String?
    let icon: Int?
    let achievement_name: String?
}

struct User: Codable {
    let user_id: String
    let last_bird_name: String?
    let last_bird_id: Int?
    let last_bird_time: Date?
    let total_birds_caught: Int?
    let user_profilepic: Int?
    let achievement_count: Int?
    let achievement_unlocked: String?

    func getUnlockedAchievements() -> [Int] {
        guard let unlockedAchievements = achievement_unlocked else {
            return []
        }

        return unlockedAchievements
            .split(separator: ",")
            .compactMap { Int($0) }
    }
}
