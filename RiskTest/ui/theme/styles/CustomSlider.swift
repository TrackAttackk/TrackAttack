//
//  CustomSlider.swift
//  RiskTest
//
//  Created by selinay ceylan on 17.09.2025.
//

import Foundation
import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let thumbColor: Color
    let trackGradient: LinearGradient
    let thumbSize: CGFloat = 25
    let trackHeight: CGFloat = 10

    init(value: Binding<Double>, range: ClosedRange<Double> = 0...1, thumbColor: Color, trackGradient: LinearGradient) {
        _value = value
        self.range = range
        self.thumbColor = thumbColor
        self.trackGradient = trackGradient
    }

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width - thumbSize
            let percentage = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let thumbOffset = percentage * totalWidth

            ZStack(alignment: .leading) {
                trackGradient
                    .frame(height: trackHeight)
                    .cornerRadius(trackHeight / 2)

                Circle()
                    .fill(thumbColor)
                    .shadow(radius: 3)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: thumbOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let dragLocation = gesture.location.x
                                var newValue = range.lowerBound + Double(max(0, min(1, dragLocation / geometry.size.width))) * (range.upperBound - range.lowerBound)
                                newValue = (newValue * 100).rounded() / 100
                                value = max(range.lowerBound, min(range.upperBound, newValue))
                            }
                    )
            }
            .frame(height: thumbSize)
            .contentShape(Rectangle())
            .onTapGesture { location in
                let tapPercentage = location.x / geometry.size.width
                var newValue = range.lowerBound + Double(max(0, min(1, tapPercentage))) * (range.upperBound - range.lowerBound)
                newValue = (newValue * 100).rounded() / 100
                value = max(range.lowerBound, min(range.upperBound, newValue))
            }
        }
        .frame(height: max(thumbSize, trackHeight))
    }
}
