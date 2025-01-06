//
//  GoalCalorieModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

final class GoalCalorieModel: Model, Content, @unchecked Sendable {
    static let schema = "goal_calorie"

    @ID(custom: "id_goal_calorie")
    var id: UUID?

    @Field(key: "goal_calorie")
    var goalCalorie: Int

    @Field(key: "date_start")
    var dateStart: Date

    @Field(key: "date_end")
    var dateEnd: Date

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Parent(key: "id_goal_type")
    var goalType: GoalTypeModel

    @Parent(key: "id_user")
    var user: UserModel

    @Parent(key: "id_calorie_methode")
    var calorieMethode: CalorieMethodeModel

    init() {}

    init(id: UUID? = nil, goalCalorie: Int, dateStart: Date, dateEnd: Date, goalTypeID: UUID, userID: UUID, calorieMethodeID: UUID) {
        self.id = id
        self.goalCalorie = goalCalorie
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.$goalType.id = goalTypeID
        self.$user.id = userID
        self.$calorieMethode.id = calorieMethodeID
    }
}
