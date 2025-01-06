//
//  FoodTypeModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent

final class FoodTypeModel: Model, Content, @unchecked Sendable {
    static let schema = "food_type"

    @ID(custom: "id_food_type")
    var id: UUID?

    @Field(key: "name_food_type")
    var name: String

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
