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
            ZStack {
                Color("GYManagerSecondary")
                    .opacity(0.05)
                    .ignoresSafeArea()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 30) {
                            Spacer()
                            
                            imageSection(index: index)
                            
                            textSection(index: index)
                            
                            Spacer()
                            
                            if index == pages.count - 1 {
                                finalButton()
                            }
                            
                            pageIndicators()
                                .padding(.bottom, 20)
                        }
                        .tag(index)
                        .padding()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if currentPage < pages.count - 1 {
                        NavigationLink(destination: AuthenticationView()
                            .navigationBarBackButtonHidden(true)) {
                            Text("Pular")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color("GYManagerPrimary"))
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func imageSection(index: Int) -> some View {
        Image(pages[index].imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 220, height: 220)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("GYManagerPrimary"),
                                Color("GYManagerPrimary").opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
            )
            .shadow(color: Color("GYManagerPrimary").opacity(0.2), radius: 15, x: 0, y: 5)
            .padding()
    }
    
    private func textSection(index: Int) -> some View {
        VStack(spacing: 20) {
            if pages[index].showHighlight {
                Text("Bem-vindo ao ")
                    .font(.title.bold())
                    .foregroundColor(Color("GYManagerSecondary")) +
                Text("GYManager")
                    .font(.title.bold())
                    .foregroundColor(Color("GYManagerPrimary"))
            } else {
                Text(pages[index].title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("GYManagerSecondary"))
                    .multilineTextAlignment(.center)
            }
            
            Text(pages[index].description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("GYManagerSecondary").opacity(0.8))
                .padding(.horizontal, 32)
        }
    }
    
    private func finalButton() -> some View {
        NavigationLink(destination: AuthenticationView()
            .navigationBarBackButtonHidden(true)) {
            Text("Começar")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("GYManagerPrimary"))
                .cornerRadius(16)
                .padding(.horizontal, 32)
                .shadow(color: Color("GYManagerPrimary").opacity(0.3),
                        radius: 10, x: 0, y: 5)
        }
    }
    
    private func pageIndicators() -> some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { i in
                Circle()
                    .fill(currentPage == i ?
                          Color("GYManagerPrimary") :
                          Color("GYManagerSecondary").opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(currentPage == i ? 1.2 : 1)
                    .animation(.spring(), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
