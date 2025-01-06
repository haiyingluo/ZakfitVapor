//
//  CalorieMethodeModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

final class CalorieMethodeModel: Model, Content, @unchecked Sendable {
    static let schema = "calorie_methode"

    @ID(custom: "id_calorie_methode")
    var id: UUID?

    @Field(key: "name_calorie_methode")
    var name: String

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
