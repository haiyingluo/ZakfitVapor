//
//  MealContainFoodController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct MealContainFoodController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let mealContainFoods = routes.grouped("meal_contain_foods")
        mealContainFoods.get(use: index)
        mealContainFoods.post(use: create)
        mealContainFoods.group(":mealContainFoodID") { mealContainFood in
            mealContainFood.put(use: update)
            mealContainFood.delete(use: delete)
        }
    }

    // Récupérer toutes les relations
    @Sendable
    func index(req: Request) async throws -> [MealContainFoodModel] {
        try await MealContainFoodModel.query(on: req.db)
            .with(\.$meal)
            .with(\.$food)
            .all()
    }

    // Créer une nouvelle relation
    @Sendable
    func create(req: Request) async throws -> MealContainFoodModel {
        let data = try req.content.decode(MealContainFoodModel.self)
        try await data.save(on: req.db)
        return data
    }

    // Mettre à jour une relation existante
    @Sendable
    func update(req: Request) async throws -> MealContainFoodModel {
        guard let id = req.parameters.get("mealContainFoodID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ID.")
        }

        guard let existing = try await MealContainFoodModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Relation not found.")
        }

        let updatedData = try req.content.decode(MealContainFoodModel.self)
        existing.$meal.id = updatedData.$meal.id
        existing.$food.id = updatedData.$food.id
        existing.quantity = updatedData.quantity

        try await existing.save(on: req.db)
        return existing
    }

    // Supprimer une relation
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("mealContainFoodID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ID.")
        }

        guard let existing = try await MealContainFoodModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Relation not found.")
        }

        try await existing.delete(on: req.db)
        return .noContent
    }
}

