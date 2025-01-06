//
//  GoalTypeController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct GoalTypeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let goalTypes = routes.grouped("goal_types") // Route principale
        goalTypes.post(use: create)                 // POST /goal_types
        goalTypes.post("batch", use: createBatch)   // POST /goal_types/batch
        goalTypes.get(use: index)                   // GET /goal_types
        goalTypes.group(":goalTypeID") { goalType in
            goalType.put(use: update)               // PUT /goal_types/:goalTypeID
            goalType.delete(use: delete)            // DELETE /goal_types/:goalTypeID
        }
    }

    // Récupérer tous les GoalTypes
    @Sendable
    func index(req: Request) async throws -> [GoalTypeModel] {
        try await GoalTypeModel.query(on: req.db).all()
    }

    // Créer un nouveau GoalType
    @Sendable
    func create(req: Request) async throws -> GoalTypeModel {
        let goalType = try req.content.decode(GoalTypeModel.self)
        try await goalType.save(on: req.db)
        return goalType
    }

    // Créer plusieurs GoalTypes
    @Sendable
    func createBatch(req: Request) async throws -> [GoalTypeModel] {
        let goalTypes = try req.content.decode([GoalTypeModel].self)
        for goalType in goalTypes {
            try await goalType.save(on: req.db)
        }
        return goalTypes
    }

    // Mettre à jour un GoalType
    @Sendable
    func update(req: Request) async throws -> GoalTypeModel {
        guard let id = req.parameters.get("goalTypeID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Goal Type ID.")
        }

        guard let existingGoalType = try await GoalTypeModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Goal Type not found.")
        }

        let updatedData = try req.content.decode(GoalTypeModel.self)
        existingGoalType.name = updatedData.name

        try await existingGoalType.save(on: req.db)
        return existingGoalType
    }

    // Supprimer un GoalType
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("goalTypeID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Goal Type ID.")
        }

        guard let goalType = try await GoalTypeModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Goal Type not found.")
        }

        try await goalType.delete(on: req.db)
        return .noContent
    }
}
