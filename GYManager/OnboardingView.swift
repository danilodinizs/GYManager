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
    let showHighlight: Bool
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var shouldNavigate = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Bem-vindo ao GYManager!",
            description: "Organize seus treinos e acompanhe sua evolução de forma simples e eficiente",
            imageName: "logo",
            showHighlight: true
        ),
        OnboardingPage(
            title: "Crie seus Treinos",
            description: "Monte treinos personalizados com nossa biblioteca de exercícios",
            imageName: "treinos",
            showHighlight: false
        ),
        OnboardingPage(
            title: "Aproveite nosso GYM Timer",
            description: "Aumente a efetividade utilizando um timer personalizado no momento do seu treino",
            imageName: "timer",
            showHighlight: false
        )
    ]
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(pages[index].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("GYManagerPrimary"), lineWidth: 4)
                            )
                            .shadow(radius: 10)
                            .padding()
        
                        
                        if pages[index].showHighlight {
                            Text("Bem-vindo ao ")
                                .font(.title)
                                .bold() +
                            Text("GYManager")
                                .font(.title)
                                .bold()
                                .foregroundColor(Color("GYManagerPrimary"))

                        } else {
                            Text(pages[index].title)
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                        
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
                                    .background(Color("GYManagerPrimary"))
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if currentPage < pages.count - 1 {
                        NavigationLink(destination: AuthenticationView()
                            .navigationBarBackButtonHidden(true)) {
                                Text("Pular")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                        }
                    }
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        }
}

#Preview {
    OnboardingView()
}
