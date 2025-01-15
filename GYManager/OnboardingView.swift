//
//  OnboardingView.swift
//  GYManager
//
//  Created by Danilo Diniz on 15/01/25.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingView: View {
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Bem-vindo ao GYManager!",
            description: "Organize seus treinos e acompanhe sua evolução de forma simples e eficiente",
            imageName: "figure.run"
        ),
        OnboardingPage(
            title: "Crie seus Treinos",
            description: "Monte treinos personalizados com nossa biblioteca de exercícios",
            imageName: "dumbbell.fill"
        ),
        OnboardingPage(
            title: "Aproveite nosso GYM Timer",
            description: "Aumente a efetividade utilizando um timer personalizado no momento do seu treino",
            imageName: "chart.line.uptrend.xyaxis"
        )
    ]
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<pages.count, id: \.self) { index in
                VStack(spacing: 20) {
                    Image(systemName: pages[index].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text(pages[index].title)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text(pages[index].description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    if index == pages.count - 1 {
                        Button(action: {
                            
                        }) {
                            Text("Começar")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                }
                .tag(index)
                .padding()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    OnboardingView()
}
