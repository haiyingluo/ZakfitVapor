//
//  GoalWeightModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

final class GoalWeightModel: Model, Content, @unchecked Sendable {
    static let schema = "goal_weight"

    @ID(custom: "id_goal_weight")
    var id: UUID?

    @Field(key: "goal_weight")
    var goalWeight: Double

    @Field(key: "recommended_calorie_deficit")
    var recommendedCalorieDeficit: Int

    @Field(key: "date_start")
    var dateStart: Date

    @Field(key: "date_end")
    var dateEnd: Date

    @Parent(key: "id_goal_type")
    var goalType: GoalTypeModel

    @Parent(key: "id_user")
    var user: UserModel

    @OptionalParent(key: "id_weight_history")
    var weightHistory: WeightHistoryModel?

    init() {}

    init(
        id: UUID? = nil,
        goalWeight: Double,
        recommendedCalorieDeficit: Int,
        dateStart: Date,
        dateEnd: Date,
        goalTypeID: UUID,
        userID: UUID,
        weightHistoryID: UUID? = nil
    ) {
        self.id = id
        self.goalWeight = goalWeight
        self.recommendedCalorieDeficit = recommendedCalorieDeficit
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.$goalType.id = goalTypeID
        self.$user.id = userID
        self.$weightHistory.id = weightHistoryID
    }
}
