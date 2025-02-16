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

    func loadUsers() async throws -> [User] {
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

    func loadDescription(birdId bird: Int) async throws -> BirdDescription? {
        do {
            let birdDescription: [BirdDescription] = try await client
                .from("descriptions")
                .select()
                .eq("bird_id", value: bird)
                .execute()
                .value

            return birdDescription.first
        } catch {
            print(error)
            throw error
        }
    }
}

struct Achievement: Codable, Identifiable {
    let achievement_id: Int
    let achievement_desc: String
    let achievement_name: String?

    var id: Int {
        achievement_id
    }

    var image: Image {
        switch achievement_id {
        case 1:
            Image(.achievement1)
        case 2:
            Image(.achievement2)
        case 3:
            Image(.achievement3)
        case 4:
            Image(.achievement4)
        case 5:
            Image(.achievement5)
        case 6:
            Image(.achievement6)
        case 7:
            Image(.achievement7)
        case 8:
            Image(.achievement8)
        case 9:
            Image(.achievement9)
        case 10:
            Image(.achievement10)
        case 11:
            Image(.achievement11)
        case 12:
            Image(.achievement12)
        case 13:
            Image(.achievement13)
        default:
            Image(.achievement1)
        }
    }
}

struct User: Codable, Identifiable {
    let user_id: String
    let last_bird_name: String?
    let last_bird_id: Int?
    let last_bird_time: Date?
    let total_birds_caught: Int?
    let user_profilepic: Int?
    let achievement_count: Int?
    let achievement_unlocked: String?

    var id: String {
        user_id
    }

    func getUnlockedAchievements(allAchievements: [Achievement]) -> [Achievement] {
        guard let unlockedAchievements = achievement_unlocked else {
            return []
        }

        return allAchievements.filter { achievement in
            unlockedAchievements.contains(String(achievement.achievement_id))
        } ?? []
    }

    var image: Image {
        switch user_profilepic {
        case 1:
            Image(.profile1)
        case 2:
            Image(.profile2)
        case 3:
            Image(.profile3)
        case 4:
            Image(.profile4)
        case 5:
            Image(.profile5)
        case 6:
            Image(.profile6)
        default:
            Image(.profile1)
        }
    }
}

struct BirdDescription: Codable {
    let bird_id: Int
    let bird_name: String?
    let bird_description: String?
}
