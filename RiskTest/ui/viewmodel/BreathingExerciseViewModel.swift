//
//  BreathingExerciseViewModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import SwiftUI
import Combine

class BreathingExerciseViewModel: ObservableObject {
    @Published var isBreathing = false
    @Published var breathingPhase = 0
    @Published var counter = 4
    @Published var currentCycle = 0
    @Published var totalCycles = 5
    @Published var selectedTechnique = 0
    @Published var isActive = false

    let techniques = [
        ("4-7-8", [4, 7, 8, 2]),
        ("4-4-4-4", [4, 4, 4, 4]),
        ("4-6-8", [4, 6, 8, 0])
    ]

    let phaseTexts = ["Nefes Al", "Tut", "Nefes Ver", "Bekle"]

    var currentTiming: [Int] {
        techniques[selectedTechnique].1
    }

    private var timer: Timer?

    func startBreathing() {
        isActive = true
        breathingCycle()
    }

    func stopBreathing() {
        isActive = false
        timer?.invalidate()
    }

    func resetBreathing() {
        stopBreathing()
        breathingPhase = 0
        counter = currentTiming[0]
        currentCycle = 0
        isBreathing = false
    }

    private func breathingCycle() {
        guard isActive else { return }

        let currentPhaseDuration = currentTiming[breathingPhase]
        counter = currentPhaseDuration

        if breathingPhase == 0 {
            isBreathing = true
        } else if breathingPhase == 2 {
            isBreathing = false
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.counter > 1 {
                self.counter -= 1
            } else {
                timer.invalidate()
                self.moveToNextPhase()
            }
        }
    }

    private func moveToNextPhase() {
        guard isActive else { return }

        repeat {
            breathingPhase = (breathingPhase + 1) % 4
        } while currentTiming[breathingPhase] == 0

        if breathingPhase == 0 {
            currentCycle += 1
            if currentCycle >= totalCycles {
                stopBreathing()
                return
            }
        }

        breathingCycle()
    }
}
