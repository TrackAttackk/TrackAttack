//
//  OnBoardingView.swift
//  RiskTest
//
//  Created by selinay ceylan on 18.09.2025.
//

import SwiftUI

struct OnBoardingView: View {
    @State private var step = 1
    @State private var name = ""
    @State private var age = 18
    @State private var gender = ""
    @State private var smoking: Bool? = nil
    @State private var familyHeartDisease: Bool? = nil
    @State private var attackCount = 0
    @State private var navigateToHome = false
    
    var viewmodel = OnBoardingViewModel()
    
    private let totalSteps = 6
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                
                HStack {
                    if step > 1 {
                        Button(action: { withAnimation { step -= 1 } }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(AppColor.mainColor)
                        }
                    } else {
                        Color.clear.frame(width: 24, height: 24)
                    }

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 200, height: 10)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColor.mainColor)
                            .frame(width: CGFloat(step)/CGFloat(totalSteps) * 200, height: 10)
                            .animation(.easeInOut, value: step)
                    }

                    Text("\(step)/\(totalSteps)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                Spacer()
                
                switch step {
                case 1:
                    VStack(spacing: 40) {
                        Text("Adınızı giriniz")
                            .font(.title2).bold()
                        TextField("Ad", text: $name)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            .frame(height: 45)
                            .frame(width: 360)
                    }
                    
                case 2:
                    VStack(spacing: 24) {
                        Text("Yaşınızı seçiniz")
                            .font(.title2).bold()
                        Picker("Yaş", selection: $age) {
                            ForEach(10...100, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 200, height: 250)
                    }
                    
                case 3:
                    VStack(spacing: 40) {
                        Text("Cinsiyetinizi seçiniz")
                            .font(.title2).bold()
                        HStack(spacing: 40) {
                            GenderOptionView(title: "Kadın", imageName: "femaleblack", isSelected: gender == "Kadın") {
                                gender = "Kadın"
                            }
                            GenderOptionView(title: "Erkek", imageName: "maleblack", isSelected: gender == "Erkek") {
                                gender = "Erkek"
                            }
                        }
                        .padding()
                    }
                    
                case 4:
                    VStack(spacing: 40) {
                        Text("Sigara kullanıyor musunuz?")
                            .font(.title2).bold()
                        YesNoSelectionView(selection: $smoking, yesText: "Evet", noText: "Hayır")
                    }
                    
                case 5:
                    VStack(spacing: 40) {
                        Text("Ailenizde kalp hastalığı var mı?")
                            .font(.title2).bold()
                        YesNoSelectionView(selection: $familyHeartDisease, yesText: "Evet", noText: "Hayır")
                    }
                    
                case 6:
                    VStack(spacing: 24) {
                        Text("Bu ayki geçmiş atak sayısını seçiniz")
                            .font(.title2).bold()
                        Picker("Atak Sayısı", selection: $attackCount) {
                            ForEach(0...30, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 200, height: 250)
                    }
                    
                default:
                    EmptyView()
                }
                
                Spacer()
                
                Button(action: {
                    if step < totalSteps {
                        withAnimation { step += 1 }
                    } else {
                        Task {
                            await viewmodel.saveUserData(
                                name: name,
                                age: age,
                                gender: gender,
                                smoking: smoking,
                                familyHeartDisease: familyHeartDisease,
                                attackCount: attackCount
                            )
                        }
                        navigateToHome = true
                    }
                }) {
                    Text(step == totalSteps ? "Bitir" : "İleri")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.mainColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $navigateToHome) {
                    HomeView(authViewModel: AuthenticationViewModel())
                }
            }
            .padding(.vertical)
        }
    }
}


#Preview {
    OnBoardingView()
}
