//
//  IntensityModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

final class IntensityModel: Model, Content, @unchecked Sendable {
    static let schema = "intensity"

    @ID(custom: "id_intensity")
    var id: UUID?

    @Field(key: "name_intensity")
    var name: String

    @Field(key: "calorie_multiplier")
    var calorieMultiplier: Double

    init() {}

    init(id: UUID? = nil, name: String, calorieMultiplier: Double) {
        self.id = id
        self.name = name
        self.calorieMultiplier = calorieMultiplier
    }
}


