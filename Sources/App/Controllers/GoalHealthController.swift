//
//  GoalHealthController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct GoalHealthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let goals = routes.grouped("goal_healths") // Route principale
        goals.post(use: create)                   // POST /goal_healths
        goals.get(use: index)                    // GET /goal_healths
        goals.group(":goalID") { goal in
            goal.put(use: update)
            goal.delete(use: delete)
        }
//        goals.put(":id", use: update)            // PUT /goal_healths/:id
//        goals.delete(":id", use: delete)         // DELETE /goal_healths/:id
    }

    // Récupérer toutes les GoalHealths
    @Sendable
    func index(req: Request) async throws -> [GoalHealthModel] {
        try await GoalHealthModel.query(on: req.db).all()
    }

    // Créer un nouveau GoalHealth
    @Sendable
    func create(req: Request) async throws -> GoalHealthModel {
        let goalHealth = try req.content.decode(GoalHealthModel.self)
        try await goalHealth.save(on: req.db)
        return goalHealth
    }

    // Mettre à jour un GoalHealth
    @Sendable
    func update(req: Request) async throws -> GoalHealthModel {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing GoalHealth ID.")
        }

        guard let existingGoalHealth = try await GoalHealthModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "GoalHealth with this ID not found.")
        }

        let updatedData = try req.content.decode(GoalHealthModel.self)
        existingGoalHealth.name = updatedData.name

        try await existingGoalHealth.save(on: req.db)
        return existingGoalHealth
    }

    // Supprimer un GoalHealth
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing GoalHealth ID.")
        }

        guard let goalHealth = try await GoalHealthModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "GoalHealth with this ID not found.")
        }

        try await goalHealth.delete(on: req.db)
        return .noContent
    }
}
