import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello ! C'est une requête GET"
    }
    
    app.post("hello") { req async -> String in
        "Hello ! C'est une requête POST"
    }
    
    app.put("hello") { req async -> String in
        "Hello ! C'est une requête PUT"
    }
    
    app.delete("hello") { req async -> String in
        "Hello ! C'est une requête DELETE"
    }
    
    try app.register(collection: UserController())
    try app.register(collection: FoodController())
    try app.register(collection: MealController())
    try app.register(collection: SportController())
    try app.register(collection: ActivityController())
    try app.register(collection: GenderController())
    try app.register(collection: DietaryController())
    try app.register(collection: FoodTypeController())
    try app.register(collection: MealTypeController())
    try app.register(collection: SportTypeController())
    try app.register(collection: IntensityController())
    try app.register(collection: GoalTypeController())
    try app.register(collection: GoalHealthController())
    try app.register(collection: GoalActivityController())
    try app.register(collection: WeightHistoryController())
    try app.register(collection: FeedbackController())
    try app.register(collection: MealContainFoodController())
    try app.register(collection: GoalWeightController())
//    try app.register(collection: GoalCalorieController())
    try app.register(collection: CalorieMethodeController())
    try app.register(collection: UserPreferDietaryController())
    try app.register(collection: NotificationController())
}
