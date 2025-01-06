//
//  FoodModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent

final class FoodModel: Model, Content, @unchecked Sendable {
    static let schema = "food"

    @ID(custom: "id_food")
    var id: UUID?

    @Field(key: "name_food")
    var name: String

    @Field(key: "calorie_food")
    var calorie: Int

    @Field(key: "protein_food")
    var protein: Double

    @Field(key: "glucide_food")
    var glucide: Double

    @Field(key: "lipide_food")
    var lipide: Double

    @Parent(key: "id_food_type")
    var foodType: FoodTypeModel

    init() {}

    init(id: UUID? = nil, name: String, calorie: Int, protein: Double, glucide: Double, lipide: Double, foodTypeID: UUID) {
        self.id = id
        self.name = name
        self.calorie = calorie
        self.protein = protein
        self.glucide = glucide
        self.lipide = lipide
        self.$foodType.id = foodTypeID
    }
}
