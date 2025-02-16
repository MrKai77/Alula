//
//  ProfilePictureCustomizationView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-16.
//

import SwiftUI

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
