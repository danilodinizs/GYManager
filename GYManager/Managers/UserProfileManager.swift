//
//  UserProfileManager.swift
//  GYManager
//
//  Created by Danilo Diniz on 04/02/25.
//

import CoreData
import Foundation

class UserProfileManager {
    static let shared = UserProfileManager()
    private let context = CoreDataManager.shared.viewContext
    
    // Create
    func createProfile(name: String, age: Int16, gender: String, weight: Double, height: Double) -> UserProfile {
        let profile = UserProfile(context: context)
        profile.name = name
        profile.age = age
        profile.gender = gender
        profile.weight = weight
        profile.height = height
        CoreDataManager.shared.save()
        return profile
    }
    
    // Read
    func fetchProfile() -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            let profiles = try context.fetch(request)
            return profiles.first
        } catch {
            print("Error fetching profile: \(error)")
            return nil
        }
    }
    
    // Update
    func updateProfile(_ profile: UserProfile, name: String? = nil, age: Int16? = nil,
                      gender: String? = nil, weight: Double? = nil, height: Double? = nil) {
        if let name = name { profile.name = name }
        if let age = age { profile.age = age }
        if let gender = gender { profile.gender = gender }
        if let weight = weight { profile.weight = weight }
        if let height = height { profile.height = height }
        CoreDataManager.shared.save()
    }
    
    // Delete
    func deleteProfile(_ profile: UserProfile) {
        context.delete(profile)
        CoreDataManager.shared.save()
    }
}
