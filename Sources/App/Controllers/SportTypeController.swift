//
//  SportTypeController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct SportTypeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sportTypes = routes.grouped("sport_types") // Route principale
        sportTypes.post(use: create)                  // POST /sport_types
        sportTypes.get(use: index)                    // GET /sport_types

        sportTypes.group(":sportTypeID") { sportType in
            sportType.put(use: update)                // PUT /sport_types/:sportTypeID
            sportType.delete(use: delete)             // DELETE /sport_types/:sportTypeID
        }
    }

    // Récupérer tous les SportTypes
    @Sendable
    func index(req: Request) async throws -> [SportTypeModel] {
        try await SportTypeModel.query(on: req.db).all()
    }

    // Créer un nouveau SportType
    @Sendable
    func create(req: Request) async throws -> SportTypeModel {
        let sportType = try req.content.decode(SportTypeModel.self)
        try await sportType.save(on: req.db)
        return sportType
    }

    // Mettre à jour un SportType
    @Sendable
    func update(req: Request) async throws -> SportTypeModel {
        guard let id = req.parameters.get("sportTypeID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing SportType ID.")
        }

        guard let existingSportType = try await SportTypeModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "SportType with this ID not found.")
        }

        let updatedData = try req.content.decode(SportTypeModel.self)
        existingSportType.name = updatedData.name

        try await existingSportType.save(on: req.db)
        return existingSportType
    }

    // Supprimer un SportType
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("sportTypeID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing SportType ID.")
        }

        guard let sportType = try await SportTypeModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "SportType with this ID not found.")
        }

        try await sportType.delete(on: req.db)
        return .noContent
    }
}
