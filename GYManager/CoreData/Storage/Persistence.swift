import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let profile = UserProfile(context: viewContext)
        profile.name = "Danilo Diniz"
        profile.age = 20
        profile.gender = "Masculino"
        profile.weight = 72.0
        profile.height = 178.0
        profile.armLeft = 34.5
        profile.thighRight = 55.0
        profile.thighLeft = 54.5
        profile.calfRight = 37.0
        profile.calfLeft = 37.0
        profile.shoulder = 110.0
        profile.abdomen = 85.0
        
        let workoutPlan = WorkoutPlan(context: viewContext)
        workoutPlan.name = "Treino A - Superior"
        workoutPlan.weekDays = ["Segunda", "Quarta", "Sexta"]
        workoutPlan.icon = "dumbell-icon"
        
        let exercise1 = Exercise(context: viewContext)
        exercise1.name = "Supino Reto"
        exercise1.sets = 3
        exercise1.reps = 12
        exercise1.notes = "Controlar a descida"
        exercise1.workoutPlan = workoutPlan
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GYManager")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
