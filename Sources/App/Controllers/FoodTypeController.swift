//
//  FoodTypeController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct FoodTypeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let foodTypes = routes.grouped("food_types")
        foodTypes.post(use: create)            // POST /food_types
        foodTypes.get(use: index)             // GET /food_types
        foodTypes.post("batch", use: createBatch) // POST /food_types/batch
        foodTypes.group(":foodTypeID") { foodType in
            foodType.put(use: update)         // PUT /food_types/:foodTypeID
            foodType.delete(use: delete)      // DELETE /food_types/:foodTypeID
        }
    }

    // Récupérer tous les types de nourriture
    @Sendable
    func index(req: Request) async throws -> [FoodTypeModel] {
        try await FoodTypeModel.query(on: req.db).all()
    }

    // Créer un type de nourriture
    @Sendable
    func create(req: Request) async throws -> FoodTypeModel {
        let foodType = try req.content.decode(FoodTypeModel.self)
        try await foodType.save(on: req.db)
        return foodType
    }

    // Créer plusieurs types de nourriture en batch
    @Sendable
    func createBatch(req: Request) async throws -> [FoodTypeModel] {
        let foodTypes = try req.content.decode([FoodTypeModel].self)
        for foodType in foodTypes {
            try await foodType.save(on: req.db)
        }
        return foodTypes
    }

    // Mettre à jour un type de nourriture
    @Sendable
    func update(req: Request) async throws -> FoodTypeModel {
        guard let id = req.parameters.get("foodTypeID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing FoodType ID.")
        }

        guard let existingFoodType = try await FoodTypeModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "FoodType with this ID not found.")
        }

        let updatedData = try req.content.decode(FoodTypeModel.self)
        existingFoodType.name = updatedData.name

        try await existingFoodType.save(on: req.db)
        return existingFoodType
    }

    // Supprimer un type de nourriture
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("foodTypeID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing FoodType ID.")
        }

        guard let foodType = try await FoodTypeModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "FoodType with this ID not found.")
        }

        try await foodType.delete(on: req.db)
        return .noContent
    }
}
