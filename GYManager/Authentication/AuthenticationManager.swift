import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isGuestUser: Bool = false
    private var currentNonce: String?
    private var stateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        stateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
            self?.isGuestUser = user?.isAnonymous ?? false
        }
    }
    
    deinit {
        if let handler = stateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    
    // MARK: - Email Authentication
    func createUser(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.userSession = result.user
        self.isGuestUser = false
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = result.user
        self.isGuestUser = false
    }
    
    // MARK: - Guest Authentication
    func signInAsGuest() async throws {
        let result = try await Auth.auth().signInAnonymously()
        self.userSession = result.user
        self.isGuestUser = true
    }
    
    // MARK: - Google Authentication
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.clientIDNotFound
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.tokenError
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        self.userSession = authResult.user
        self.isGuestUser = false
    }
    
    // MARK: - Apple Authentication
    func signInWithApple() async throws {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            throw AuthError.noRootViewController
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            let delegate = SignInWithAppleDelegate(currentNonce: nonce) { result in
                switch result {
                case .success(let authResult):
                    self.userSession = authResult.user
                    self.isGuestUser = false
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = SignInWithApplePresentationContextProviding(window: window)
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
        self.userSession = nil
        self.isGuestUser = false
    }
    
    // MARK: - Helper Methods
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - Custom Error Types
enum AuthError: Error {
    case clientIDNotFound
    case noRootViewController
    case tokenError
    
    var description: String {
        switch self {
        case .clientIDNotFound:
            return "Google Client ID não encontrado"
        case .noRootViewController:
            return "Não foi possível encontrar a janela principal do app"
        case .tokenError:
            return "Erro ao gerar token de autenticação"
        }
    }
}

// MARK: - Apple Sign In Support Classes
class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let completionHandler: (Result<AuthDataResult, Error>) -> Void
    private let currentNonce: String
    
    init(currentNonce: String, completionHandler: @escaping (Result<AuthDataResult, Error>) -> Void) {
        self.currentNonce = currentNonce
        self.completionHandler = completionHandler
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completionHandler(.failure(AuthError.tokenError))
            return
        }
        
        // Usando a nova sintaxe recomendada
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: currentNonce
        )
        
        Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                completionHandler(.success(result))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completionHandler(.failure(error))
    }
}

class SignInWithApplePresentationContextProviding: NSObject, ASAuthorizationControllerPresentationContextProviding {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return window
    }
}
