//
//  MealTypeController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//

import Vapor
import Fluent
import FluentSQL

struct MealTypeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let mealTypes = routes.grouped("meal_types") // Route principale
        mealTypes.post(use: create)                  // POST /meal_types
        mealTypes.get(use: index)                   // GET /meal_types
        mealTypes.group(":mealTypeID") { mealType in
            mealType.put(use: update)
            mealType.delete(use: delete)
        }

//        mealTypes.put(":id", use: update)           // PUT /meal_types/:id
//        mealTypes.delete(":id", use: delete)        // DELETE /meal_types/:id
    }

    // Récupérer tous les MealTypes
    @Sendable
    func index(req: Request) async throws -> [MealTypeModel] {
        try await MealTypeModel.query(on: req.db).all()
    }

    // Créer un nouveau MealType
    @Sendable
    func create(req: Request) async throws -> MealTypeModel {
        let mealType = try req.content.decode(MealTypeModel.self)
        try await mealType.save(on: req.db)
        return mealType
    }

    // Mettre à jour un MealType
    @Sendable
    func update(req: Request) async throws -> MealTypeModel {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing MealType ID.")
        }

        guard let existingMealType = try await MealTypeModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "MealType with this ID not found.")
        }

        let updatedData = try req.content.decode(MealTypeModel.self)
        existingMealType.name = updatedData.name

        try await existingMealType.save(on: req.db)
        return existingMealType
    }

    // Supprimer un MealType
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing MealType ID.")
        }

        guard let mealType = try await MealTypeModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "MealType with this ID not found.")
        }

        try await mealType.delete(on: req.db)
        return .noContent
    }
}
