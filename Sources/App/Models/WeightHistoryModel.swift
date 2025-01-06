//
//  WeightHistoryModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent

final class WeightHistoryModel: Model, Content, @unchecked Sendable {
    static let schema = "weight_history"

    @ID(custom: "id_weight_history")
    var id: UUID?

    @Field(key: "current_weight")
    var currentWeight: Double

    @Field(key: "date_record")
    var dateRecord: Date

    @Parent(key: "id_user")
    var user: UserModel

    init() {}

    init(id: UUID? = nil, currentWeight: Double, dateRecord: Date, userID: UUID) {
        self.id = id
        self.currentWeight = currentWeight
        self.dateRecord = dateRecord
        self.$user.id = userID
    }
}



