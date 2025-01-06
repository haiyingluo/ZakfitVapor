//
//  MealModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

final class MealModel: Model, Content, @unchecked Sendable {
    static let schema = "meal"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "date_meal")
    var date: Date

    @Parent(key: "id_user")
    var user: UserModel

    @Parent(key: "id_meal_type")
    var mealType: MealTypeModel

    init() {}

    init(id: UUID? = nil, date: Date, userID: UUID, mealTypeID: UUID) {
        self.id = id
        self.date = date
        self.$user.id = userID
        self.$mealType.id = mealTypeID
    }
}
