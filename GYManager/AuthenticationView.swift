//
//  AuthenticationView.swift
//  GYManager
//
//  Created by Danilo Diniz on 03/02/25.
//

import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Status do usuário
            if let user = authManager.userSession {
                Text("Usuário logado: \(user.email ?? "")")
                
                if authManager.isGuestUser {
                    Text("(Modo convidado)")
                }
                
                Button("Sair") {
                    try? authManager.signOut()
                }
            } else {
                // Formulário de login
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                
                SecureField("Senha", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                // Botões de ação
                Button("Entrar") {
                    Task {
                        try? await authManager.signIn(email: email, password: password)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Registrar") {
                    Task {
                        try? await authManager.createUser(email: email, password: password)
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Entrar como Convidado") {
                    Task {
                        try? await authManager.signInAsGuest()
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
    }
}

#Preview {
    AuthenticationView()
}
