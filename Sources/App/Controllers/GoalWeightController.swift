//
//  GoalWeightController.swift
//  AtHomeVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

struct GoalWeightController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let goalWeights = routes.grouped("goal_weights")
        goalWeights.post(use: create)
        goalWeights.get(use: index)
        goalWeights.group(":goalWeightID") { goalWeight in
            goalWeight.delete(use: delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [GoalWeightModel] {
        try await GoalWeightModel.query(on: req.db)
            .with(\.$goalType)
            .with(\.$user)
            .with(\.$weightHistory)
            .all()
    }
    
    @Sendable
    func create(req: Request) async throws -> GoalWeightModel {
        let input = try req.content.decode(GoalWeightModel.self)
        let userID = input.$user.id

        // Récupérer la dernière entrée de `WeightHistoryModel` pour cet utilisateur
        guard let lastWeightHistory = try await WeightHistoryModel.query(on: req.db)
            .filter(\.$user.$id == userID) // Utilisez correctement la relation Parent
            .sort(\.$dateRecord, .descending) // Assurez-vous que `dateRecord` est défini dans le modèle
            .first() else {
                throw Abort(.notFound, reason: "No weight history found for the user.")
            }

        // Associez l'entrée de poids au nouvel objectif
        input.$weightHistory.id = lastWeightHistory.id

        // Enregistrez l'objectif
        try await input.save(on: req.db)
        return input
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("goalWeightID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Goal Weight ID.")
        }
        guard let goalWeight = try await GoalWeightModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Goal Weight not found.")
        }
        try await goalWeight.delete(on: req.db)
        return .noContent
    }
}


