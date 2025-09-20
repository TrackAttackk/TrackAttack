//
//  Proflies.swift
//  RiskTest
//
//  Created by selinay ceylan on 19.09.2025.
//

import Foundation

struct Profile: Identifiable {
    var id: String { uid }
    var uid: String
    var email: String
    var name: String
    var age: Int
    var gender: String
    var smoking: Bool
    var familyHeartDisease: Bool
    var attackCount: Int
    
    init(uid: String = "",
         email: String = "",
         name: String = "",
         age: Int = 0,
         gender: String = "",
         smoking: Bool = false,
         familyHeartDisease: Bool = false,
         attackCount: Int = 0) {
        self.uid = uid
        self.email = email
        self.name = name
        self.age = age
        self.gender = gender
        self.smoking = smoking
        self.familyHeartDisease = familyHeartDisease
        self.attackCount = attackCount
    }
}



