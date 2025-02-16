//
//  Achievement.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-16.
//

import SwiftUI

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
