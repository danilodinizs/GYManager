//
//  GYManagerApp.swift
//  GYManager
//
//  Created by Danilo Diniz on 15/01/25.
//

import SwiftUI
import FirebaseCore

@main
struct GYManagerApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
