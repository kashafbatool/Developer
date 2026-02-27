//
//  EnergyCheckInView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI

struct EnergyCheckInView: View {
    @Binding var showCheckIn: Bool
    let userProgress: UserProgress

    let levels: [(emoji: String, label: String)] = [
        ("😔", "Struggling"),
        ("😐", "Low"),
        ("🙂", "Okay"),
        ("😊", "Good"),
        ("🔥", "Amazing")
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Header
                VStack(spacing: 12) {
                    Text("DAILY CHECK-IN")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary)
                        .tracking(2)

                    Text("How are you\nfeeling today?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.appPlum)
                        .multilineTextAlignment(.center)

                    Text("Your dashboard will adapt to support you")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }

                // Energy buttons
                HStack(spacing: 10) {
                    ForEach(0..<5, id: \.self) { i in
                        Button {
                            userProgress.recordCheckIn(energyLevel: i + 1)
                            withAnimation(.spring(response: 0.3)) {
                                showCheckIn = false
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Text(levels[i].emoji)
                                    .font(.system(size: 30))
                                Text(levels[i].label)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.appPlum.opacity(0.06), radius: 8, y: 3)
                        }
                    }
                }
                .padding(.horizontal)

                Button("Skip for now") {
                    showCheckIn = false
                }
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

                Spacer()
            }
        }
    }
}
