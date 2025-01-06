//
//  MealController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct MealController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let meals = routes.grouped("meals")
        meals.post(use: create)             // POST /meals
        meals.get(use: index)               // GET /meals
        meals.group(":mealID") { meal in
            meal.put(use: update)           // PUT /meals/:mealID
            meal.delete(use: delete)        // DELETE /meals/:mealID
            meal.get("total", use: calculateTotals) // GET /meals/:mealID/total
        }
    }

    @Sendable
    func index(req: Request) async throws -> [MealModel] {
        try await MealModel.query(on: req.db).with(\.$mealType).all()
    }

    @Sendable
    func create(req: Request) async throws -> MealModel {
        let meal = try req.content.decode(MealModel.self)
        try await meal.save(on: req.db)
        return meal
    }

    @Sendable
    func update(req: Request) async throws -> MealModel {
        guard let id = req.parameters.get("mealID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Meal ID.")
        }
        guard let existingMeal = try await MealModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Meal not found.")
        }

        let updatedData = try req.content.decode(MealModel.self)
        existingMeal.date = updatedData.date
        existingMeal.$mealType.id = updatedData.$mealType.id
        try await existingMeal.save(on: req.db)
        return existingMeal
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("mealID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Meal ID.")
        }
        guard let meal = try await MealModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Meal not found.")
        }
        try await meal.delete(on: req.db)
        return .noContent
    }

    @Sendable
    func calculateTotals(req: Request) async throws -> [String: Float] {
        guard let mealID = req.parameters.get("mealID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Meal ID.")
        }
        let mealContains = try await MealContainFoodModel.query(on: req.db)
            .filter(\.$meal.$id == mealID)
            .with(\.$food)
            .all()

        var totalCalories: Float = 0
        var totalProteins: Float = 0
        var totalCarbs: Float = 0
        var totalFats: Float = 0

        for mealContain in mealContains {
            let food = mealContain.food
            let quantity = Float(mealContain.quantity) / 100.0 // Convert to percentage

            totalCalories += Float(food.calorie) * quantity
            totalProteins += Float(food.protein) * quantity
            totalCarbs += Float(food.glucide) * quantity
            totalFats += Float(food.lipide) * quantity
        }

        return [
            "calories": totalCalories,
            "proteins": totalProteins,
            "carbs": totalCarbs,
            "fats": totalFats
        ]
    }
}
