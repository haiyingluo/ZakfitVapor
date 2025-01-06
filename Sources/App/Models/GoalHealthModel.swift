//
//  GoalHealthModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//

import Vapor
import Fluent

final class GoalHealthModel: Model, Content, @unchecked Sendable {
    static let schema = "goal_health"

    @ID(custom: "id_goal_health")
    var id: UUID?

    @Field(key: "name_goal_health")
    var name: String

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
