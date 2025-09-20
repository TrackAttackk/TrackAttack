//
//  HealthKitManager.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import HealthKit
import SwiftUI
import CoreML

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var dailySteps: Int = 0
    @Published var averageHeartRate: Int = 0
    @Published var restingHeartRate: Int = 0
    @Published var sleepHours: Double = 0.0
    @Published var exerciseMinutes: Int = 0
    
    private let readTypes: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
        HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
    ]
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit bu cihazda mevcut değil")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                print("HealthKit izni verildi")
                DispatchQueue.main.async {
                    self.fetchAllHealthData()
                }
            } else {
                print("HealthKit izni reddedildi: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func fetchAllHealthData() {
        fetchDailySteps()
        fetchAverageHeartRate()
        fetchRestingHeartRate()
        fetchSleepData()
        fetchExerciseMinutes()
    }
    
    private func fetchDailySteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { _, result, _ in
            guard let result = result,
                  let sum = result.sumQuantity() else { return }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            DispatchQueue.main.async {
                self.dailySteps = steps
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchAverageHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: heartRateType,
                                    quantitySamplePredicate: predicate,
                                    options: .discreteAverage) { _, result, _ in
            guard let result = result,
                  let average = result.averageQuantity() else { return }
            
            let avgHeartRate = Int(average.doubleValue(for: HKUnit(from: "count/min")))
            DispatchQueue.main.async {
                self.averageHeartRate = avgHeartRate
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchRestingHeartRate() {
        guard let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: restingHeartRateType,
                                predicate: nil,
                                limit: 1,
                                sortDescriptors: [sortDescriptor]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            
            let restingHR = Int(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
            DispatchQueue.main.async {
                self.restingHeartRate = restingHR
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchSleepData() {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType,
                                predicate: predicate,
                                limit: HKObjectQueryNoLimit,
                                sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKCategorySample] else { return }
            
            var totalSleepTime: TimeInterval = 0
            
            for sample in samples {
                if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                    totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate)
                }
            }
            
            let sleepHours = totalSleepTime / 3600
            DispatchQueue.main.async {
                self.sleepHours = sleepHours
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchExerciseMinutes() {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: exerciseType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { _, result, _ in
            guard let result = result,
                  let sum = result.sumQuantity() else { return }
            
            let minutes = Int(sum.doubleValue(for: HKUnit.minute()))
            DispatchQueue.main.async {
                self.exerciseMinutes = minutes
            }
        }
        
        healthStore.execute(query)
    }
}

extension HealthKitManager {
    
    private var scalerMean: [Float] {
        return [52.437305, 0.493687, 100.737717, 82.024503, 4341.052507, 6.494724, 33.539567, 1.823103, 0.411551, 0.469559]
    }
    
    private var scalerStd: [Float] {
        return [19.475188, 0.499960, 22.777984, 17.156535, 2526.834910, 1.319431, 22.937767, 1.453479, 0.492115, 0.499072]
    }
    
    private func scaleFeature(_ value: Float, index: Int) -> Float {
        return (value - scalerMean[index]) / scalerStd[index]
    }
    
    func predictHeartRisk(userProfile: Profile) -> String {
        do {
            let config = MLModelConfiguration()
            let model = try HeartRiskPredictorTF(configuration: config)
            
            let inputArray = try MLMultiArray(shape: [1, 10], dataType: .float32)
            
            let features: [Float] = [
                Float(userProfile.age),
                userProfile.gender == "Kadın" ? 1.0 : 0.0,
                Float(averageHeartRate),
                Float(restingHeartRate),
                Float(dailySteps),
                Float(sleepHours),
                Float(exerciseMinutes),
                Float(userProfile.attackCount),
                userProfile.smoking ? 1.0 : 0.0,
                userProfile.familyHeartDisease ? 1.0 : 0.0
            ]
            
            for i in 0..<features.count {
                let scaledValue = scaleFeature(features[i], index: i)
                inputArray[[0, NSNumber(value: i)]] = NSNumber(value: scaledValue)
            }
            
            let input = HeartRiskPredictorTFInput(dense_input: inputArray)
            let output = try model.prediction(input: input)
            
            if let resultArray = output.Identity as? MLMultiArray {
                var maxIndex = 0
                var maxValue: Float = -Float.infinity
                
                for i in 0..<resultArray.count {
                    let value = resultArray[i].floatValue
                    if value > maxValue {
                        maxValue = value
                        maxIndex = i
                    }
                }
                
                switch maxIndex {
                case 0: return "Düşük Risk"
                case 1: return "Orta Risk"
                case 2: return "Yüksek Risk"
                default: return "Bilinmiyor"
                }
            }
            
        } catch {
            print("Risk tahmini hatası: \(error.localizedDescription)")
            return "Hesaplanamadı"
        }
        
        return "Hesaplanamadı"
    }
}


