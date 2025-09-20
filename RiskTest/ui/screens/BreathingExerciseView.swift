//
//  BreathingExerciseView.swift
//  RiskTest
//
//  Created by selinay ceylan on 18.09.2025.
//

import SwiftUI

struct BreathingExerciseView: View {
    @StateObject private var viewModel = BreathingExerciseViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(AppColor.mainColor.opacity(0.1))
                            .frame(width: 220, height: 220)
                            .blur(radius: 10)
                            .scaleEffect(viewModel.isBreathing ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: Double(viewModel.currentTiming[viewModel.breathingPhase])), value: viewModel.isBreathing)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColor.mainColor.opacity(0.2),
                                        AppColor.mainColor.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                            .overlay(
                                Circle()
                                    .stroke(AppColor.mainColor.opacity(0.3), lineWidth: 2)
                            )
                            .scaleEffect(viewModel.isBreathing ? 1.15 : 1.0)
                            .animation(.easeInOut(duration: Double(viewModel.currentTiming[viewModel.breathingPhase])), value: viewModel.isBreathing)

                        VStack(spacing: 10) {
                            Text(viewModel.isActive ? viewModel.phaseTexts[viewModel.breathingPhase] : "Başlamaya Hazır")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)

                            Text("\(viewModel.counter)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(AppColor.mainColor)
                        }
                    }

                    Spacer()

                    // Instructions
                    VStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { index in
                            if viewModel.currentTiming[index] > 0 {
                                InstructionStep(
                                    number: index + 1,
                                    title: viewModel.phaseTexts[index],
                                    description: "\(viewModel.currentTiming[index]) saniye",
                                    isActive: viewModel.isActive && viewModel.breathingPhase == index
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    HStack {
                        Text("Döngü: \(viewModel.currentCycle)/\(viewModel.totalCycles)")
                        Spacer()
                        Text("Teknik: \(viewModel.techniques[viewModel.selectedTechnique].0)")
                    }
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)

                    HStack(spacing: 20) {
                        Button(action: {
                            if viewModel.isActive {
                                viewModel.stopBreathing()
                            } else {
                                viewModel.startBreathing()
                            }
                        }) {
                            Image(systemName: viewModel.isActive ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(AppColor.mainColor.opacity(viewModel.isActive ? 0.8 : 0.6))
                                .clipShape(Circle())
                        }

                        Button(action: viewModel.resetBreathing) {
                            Image(systemName: "stop.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.6))
                                .clipShape(Circle())
                        }

                        Button(action: {}) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.vertical, 20)

                    HStack(spacing: 10) {
                        ForEach(0..<viewModel.techniques.count, id: \.self) { index in
                            Button(action: {
                                viewModel.selectedTechnique = index
                                viewModel.resetBreathing()
                            }) {
                                Text(viewModel.techniques[index].0.components(separatedBy: " ").first ?? "")
                                    .font(.caption)
                                    .foregroundColor(viewModel.selectedTechnique == index ? .white : .black)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(viewModel.selectedTechnique == index ? AppColor.mainColor : AppColor.mainColor.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(AppColor.mainColor.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Nefes Egzersizi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.mainColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("trackattack")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
            }
        }
    }
}

#Preview {
        BreathingExerciseView()
}
