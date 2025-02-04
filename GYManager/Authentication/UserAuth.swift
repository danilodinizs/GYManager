import SwiftUI
import CoreData

class UserAuth: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentProfile: UserProfile?
    
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.isAuthenticated = false
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        error = nil
        
        // Simula uma chamada de API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLoading = false
            // Simula autenticação bem-sucedida
            if email == "teste@teste.com" && password == "123456" {
                self?.isAuthenticated = true
                self?.loadUserProfile()
            } else {
                self?.error = "Credenciais inválidas"
            }
        }
    }
    
    func signOut() {
        isAuthenticated = false
        currentProfile = nil
    }
    
    private func loadUserProfile() {
        let context = persistenceController.container.viewContext
        let fetchRequest = UserProfile.fetchRequest()
        
        do {
            if let profile = try context.fetch(fetchRequest).first {
                currentProfile = profile
            } else {
                // Criar um novo perfil se não existir
                let newProfile = UserProfile(context: context)
                newProfile.name = "Novo Usuário"
                newProfile.age = 0
                newProfile.gender = ""
                newProfile.weight = 0
                newProfile.height = 0
                
                try context.save()
                currentProfile = newProfile
            }
        } catch {
            print("Erro ao carregar perfil: \(error)")
        }
    }
}
