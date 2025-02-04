//
//  CoreDataManager.swift
//  GYManager
//
//  Created by Danilo Diniz on 04/02/25.
//

import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistenceController = PersistenceController.shared
    
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    // Função genérica para salvar
    func save() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
            viewContext.rollback()
        }
    }
}
