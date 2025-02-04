//
//  WorkoutPlanManager.swift
//  GYManager
//
//  Created by Danilo Diniz on 04/02/25.
//

import CoreData
import Foundation

class WorkoutPlanManager {
    static let shared = WorkoutPlanManager()
    private let context = CoreDataManager.shared.viewContext
    
    // Create
    func createWorkoutPlan(name: String, weekDays: [String], icon: String) -> WorkoutPlan {
        let plan = WorkoutPlan(context: context)
        plan.name = name
        plan.weekDays = weekDays as NSArray
        plan.icon = icon
        CoreDataManager.shared.save()
        return plan
    }
    
    // Read
    func fetchWorkoutPlans() -> [WorkoutPlan] {
        let request: NSFetchRequest<WorkoutPlan> = WorkoutPlan.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching workout plans: \(error)")
            return []
        }
    }
    
    // Read Single
    func fetchWorkoutPlan(withId id: NSManagedObjectID) -> WorkoutPlan? {
        do {
            return try context.existingObject(with: id) as? WorkoutPlan
        } catch {
            print("Error fetching workout plan: \(error)")
            return nil
        }
    }
    
    // Update
    func updateWorkoutPlan(_ plan: WorkoutPlan, name: String? = nil,
                          weekDays: [String]? = nil, icon: String? = nil) {
        if let name = name { plan.name = name }
        if let weekDays = weekDays { plan.weekDays = weekDays as NSArray}
        if let icon = icon { plan.icon = icon }
        CoreDataManager.shared.save()
    }
    
    // Delete
    func deleteWorkoutPlan(_ plan: WorkoutPlan) {
        context.delete(plan)
        CoreDataManager.shared.save()
    }
}
