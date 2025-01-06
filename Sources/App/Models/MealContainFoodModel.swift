//
//  MealContainFoodModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

final class MealContainFoodModel: Model, Content, @unchecked Sendable {
    static let schema = "meal_contain_food"

    @ID(custom: "id")
    var id: UUID?

    @Parent(key: "id_meal")
    var meal: MealModel

    @Parent(key: "id_food")
    var food: FoodModel

    @Field(key: "quantity")
    var quantity: Double // Quantité en grammes

    init() {}

    init(id: UUID? = nil, mealID: UUID, foodID: UUID, quantity: Double) {
        self.id = id
        self.$meal.id = mealID
        self.$food.id = foodID
        self.quantity = quantity
    }
}


