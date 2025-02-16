//
//  User.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-16.
//

import SwiftUI

struct User: Codable, Identifiable {
    let user_id: String
    let last_bird_name: String?
    let last_bird_id: Int?
    let last_bird_time: Date?
    let total_birds_caught: Int?
    var user_profilepic: Int?
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
        }
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
