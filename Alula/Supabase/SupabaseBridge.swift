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

    func updateProfilePicture(for userId: String, with imageId: Int) {
        Task {
            do {
                try await client
                    .from("users")
                    .update(["user_profilepic": imageId])
                    .eq("user_id", value: userId)
                    .execute()
            } catch {
                print("Failed to update profile picture: \(error)")
            }
        }
    }

    func updateBirdsCaught(for userId: String, with amount: Int, birdId: Int) {
        Task {
            do {
                try await client
                    .from("users")
                    .update([
                        "total_birds_caught": 5 + amount,
                        "last_bird_id": birdId
                    ])
                    .eq("user_id", value: userId)
                    .execute()

                try await client
                    .from("users")
                    .update([
                        "last_bird_time": Date.now  // Separate data type
                    ])
                    .eq("user_id", value: userId)
                    .execute()
            } catch {
                print("Failed to update total birds caught: \(error)")
            }
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

    func loadGbifIucnRedListData(birdId bird: Int) async throws -> GBIF_IUCN_Data? {
        do {
            let data: [GBIF_IUCN_Data] = try await client
                .from("gbif_iucn_data")
                .select()
                .eq("bird_id", value: bird)
                .execute()
                .value

            return data.first
        } catch {
            print(error)
            throw error
        }
    }
}
