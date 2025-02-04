//
//  ExerciseManager.swift
//  GYManager
//
//  Created by Danilo Diniz on 04/02/25.
//

import CoreData
import Foundation

class ExerciseManager {
    static let shared = ExerciseManager()
    private let context = CoreDataManager.shared.viewContext
    
    // Create
    func createExercise(name: String, sets: Int16, reps: Int16,
                       notes: String?, workoutPlan: WorkoutPlan) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.name = name
        exercise.sets = sets
        exercise.reps = reps
        exercise.notes = notes
        exercise.workoutPlan = workoutPlan
        CoreDataManager.shared.save()
        return exercise
    }
    
    // Read
    func fetchExercises(forWorkoutPlan plan: WorkoutPlan) -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "workoutPlan == %@", plan)
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercises: \(error)")
            return []
        }
    }
    
    // Update
    func updateExercise(_ exercise: Exercise, name: String? = nil,
                       sets: Int16? = nil, reps: Int16? = nil, notes: String? = nil) {
        if let name = name { exercise.name = name }
        if let sets = sets { exercise.sets = sets }
        if let reps = reps { exercise.reps = reps }
        if let notes = notes { exercise.notes = notes }
        CoreDataManager.shared.save()
    }
    
    // Delete
    func deleteExercise(_ exercise: Exercise) {
        context.delete(exercise)
        CoreDataManager.shared.save()
    }
}
