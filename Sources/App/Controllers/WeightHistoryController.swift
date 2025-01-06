//
//  WeightHistoryController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//

import Vapor
import Fluent
import FluentSQL

struct WeightHistoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let weightHistories = routes.grouped("weight_histories") // Route principale
        weightHistories.post(use: create)                       // POST /weight_histories
        weightHistories.get(use: index)                         // GET /weight_histories

        // Grouper les routes associées à un ID spécifique
        weightHistories.group(":weightHistoryID") { weightHistory in
            weightHistory.put(use: update)                      // PUT /weight_histories/:weightHistoryID
            weightHistory.delete(use: delete)                   // DELETE /weight_histories/:weightHistoryID
        }
    }

    // Récupérer tous les WeightHistories
    @Sendable
    func index(req: Request) async throws -> [WeightHistoryModel] {
        try await WeightHistoryModel.query(on: req.db).all()
    }

    // Créer un nouveau WeightHistory
    @Sendable
    func create(req: Request) async throws -> WeightHistoryModel {
        let weightHistory = try req.content.decode(WeightHistoryModel.self)
        try await weightHistory.save(on: req.db)

        // Mettre à jour la clé étrangère id_weight_history dans User
        if let user = try await UserModel.find(weightHistory.$user.id, on: req.db) {
            user.$weightHistory.id = weightHistory.id
            try await user.save(on: req.db)
        }

        return weightHistory
    }

    // Mettre à jour un WeightHistory
    @Sendable
    func update(req: Request) async throws -> WeightHistoryModel {
        guard let id = req.parameters.get("weightHistoryID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing WeightHistory ID.")
        }
        guard let existingWeightHistory = try await WeightHistoryModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "WeightHistory not found.")
        }

        let updatedData = try req.content.decode(WeightHistoryModel.self)
        existingWeightHistory.currentWeight = updatedData.currentWeight
        existingWeightHistory.dateRecord = updatedData.dateRecord

        try await existingWeightHistory.save(on: req.db)

        return existingWeightHistory
    }

    // Supprimer un WeightHistory
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("weightHistoryID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing WeightHistory ID.")
        }
        guard let weightHistory = try await WeightHistoryModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "WeightHistory not found.")
        }

        try await weightHistory.delete(on: req.db)
        return .noContent
    }
}
