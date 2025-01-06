//
//  FoodController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct FoodController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let foods = routes.grouped("foods")
        foods.post(use: create)                 // POST /foods
        foods.post("batch", use: createBatch)   // POST /foods/batch
        foods.get(use: index)                   // GET /foods
        foods.group(":foodID") { food in
            food.put(use: update)               // PUT /foods/:foodID
            food.delete(use: delete)            // DELETE /foods/:foodID
        }
    }

    @Sendable
    func index(req: Request) async throws -> [FoodModel] {
        try await FoodModel.query(on: req.db)
            .with(\.$foodType)
            .all()
    }

    @Sendable
    func create(req: Request) async throws -> FoodModel {
        let food = try req.content.decode(FoodModel.self)
        try await food.save(on: req.db)
        return food
    }

    @Sendable
    func createBatch(req: Request) async throws -> [FoodModel] {
        let foods = try req.content.decode([FoodModel].self)
        for food in foods {
            try await food.save(on: req.db)
        }
        return foods
    }

    @Sendable
    func update(req: Request) async throws -> FoodModel {
        guard let id = req.parameters.get("foodID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Food ID.")
        }

        guard let existingFood = try await FoodModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Food not found.")
        }

        let updatedData = try req.content.decode(FoodModel.self)
        existingFood.name = updatedData.name
        existingFood.calorie = updatedData.calorie
        existingFood.$foodType.id = updatedData.$foodType.id

        try await existingFood.save(on: req.db)
        return existingFood
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("foodID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Food ID.")
        }

        guard let food = try await FoodModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Food not found.")
        }

        try await food.delete(on: req.db)
        return .noContent
    }
}
