import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth

struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color("GYManagerPrimary"), lineWidth: 3)
                        )
                        .shadow(radius: 5)
                        .padding(.top, 20)
                    
                    if let user = authManager.userSession {
                        loggedInView(user: user)
                    } else {
                        loginForm
                        divider
                        socialLoginButtons
                        guestLoginButton
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .alert("Erro", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 15) {
            TextField("Email", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            SecureField("Senha", text: $password)
                .textFieldStyle(CustomTextFieldStyle())
            
            Button(action: handleEmailLogin) {
                Text("Entrar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("GYManagerPrimary"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button(action: handleEmailSignUp) {
                Text("Criar conta")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("GYManagerSecondary"))
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
        }
    }
    
    private var divider: some View {
        HStack {
            VStack { Divider() }.foregroundColor(Color("GYManagerPrimary").opacity(0.3))
            Text("ou continue com")
                .font(.subheadline)
                .foregroundColor(.gray)
            VStack { Divider() }.foregroundColor(Color("GYManagerPrimary").opacity(0.3))
        }
    }
    
    private var socialLoginButtons: some View {
        VStack(spacing: 15) {
            Button(action: handleGoogleLogin) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text("Google")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 5)
            }
            
            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                handleAppleLogin()
            }
            .frame(height: 50)
            .cornerRadius(12)
        }
    }
    
    private var guestLoginButton: some View {
        Button(action: handleGuestLogin) {
            Text("Continuar como convidado")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("GYManagerPrimary").opacity(0.1))
                .foregroundColor(Color("GYManagerPrimary"))
                .cornerRadius(12)
        }
    }
    
    private func loggedInView(user: FirebaseAuth.User) -> some View {
        VStack(spacing: 20) {
            Text("Bem vindo ao GYManager!")
                .font(.title2)
                .bold()
            
            if authManager.isGuestUser {
                Text("Você está logado como convidado")
                    .foregroundColor(.gray)
            } else {
                Text(user.email ?? "Não disponível")
                    .foregroundColor(Color("GYManagerPrimary"))
            }
            
            Button(action: handleSignOut) {
                Text("Sair")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleEmailLogin() {
        isLoading = true
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
            } catch {
                showError(message: error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    private func handleEmailSignUp() {
        isLoading = true
        Task {
            do {
                try await authManager.createUser(email: email, password: password)
            } catch {
                showError(message: error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    private func handleGoogleLogin() {
        isLoading = true
        Task {
            do {
                try await authManager.signInWithGoogle()
            } catch {
                showError(message: error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    private func handleAppleLogin() {
        isLoading = true
        Task {
            do {
                try await authManager.signInWithApple()
            } catch {
                showError(message: error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    private func handleGuestLogin() {
        isLoading = true
        Task {
            do {
                try await authManager.signInAsGuest()
            } catch {
                showError(message: error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    private func handleSignOut() {
        do {
            try authManager.signOut()
        } catch {
            showError(message: error.localizedDescription)
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("GYManagerPrimary").opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    AuthenticationView()
}
