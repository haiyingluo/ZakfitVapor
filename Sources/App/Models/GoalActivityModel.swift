//
//  GoalActivityModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent

final class GoalActivityModel: Model, Content, @unchecked Sendable {
    static let schema = "goal_activities"

    @ID(custom: "id_goal_activity")
    var id: UUID?

    @Field(key: "frequency")
    var frequency: Int

    @Field(key: "calorie_burned")
    var calorieBurned: Int

    @Field(key: "session_duration")
    var sessionDuration: Int

    @Field(key: "progress_sessions")
    var progressSessions: Int

    @Field(key: "date_start")
    var dateStart: Date?

    @Field(key: "date_end")
    var dateEnd: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Parent(key: "id_goal_type")
    var goalType: GoalTypeModel

    @Parent(key: "id_user")
    var user: UserModel

    init() {}

    init(id: UUID? = nil, frequency: Int, calorieBurned: Int, sessionDuration: Int, progressSessions: Int, dateStart: Date?, dateEnd: Date?, goalTypeID: UUID, userID: UUID) {
        self.id = id
        self.frequency = frequency
        self.calorieBurned = calorieBurned
        self.sessionDuration = sessionDuration
        self.progressSessions = progressSessions
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.$goalType.id = goalTypeID
        self.$user.id = userID
    }
}
