//
//  GYManagerApp.swift
//  GYManager
//
//  Created by Danilo Diniz on 15/01/25.
//

import SwiftUI

@main
struct GYManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
