//
//  SportController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct SportController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sports = routes.grouped("sports") // Route principale
        sports.post(use: create)             // POST /sports
        sports.post("batch", use: createBatch) // POST /sports/batch
        sports.get(use: index)               // GET /sports
        sports.group(":sportID") { sport in
            sport.put(use: update)           // PUT /sports/:sportID
            sport.delete(use: delete)        // DELETE /sports/:sportID
        }
    }

    // Récupérer tous les Sports
    @Sendable
    func index(req: Request) async throws -> [SportModel] {
        try await SportModel.query(on: req.db)
            .with(\.$sportType) // Inclut les relations avec SportType
            .all()
    }

    // Créer un nouveau Sport
    @Sendable
    func create(req: Request) async throws -> SportModel {
        let sport = try req.content.decode(SportModel.self)

        // Vérification que le sportType existe
        guard let _ = try await SportTypeModel.find(sport.$sportType.id, on: req.db) else {
            throw Abort(.badRequest, reason: "SportType with ID \(sport.$sportType.id) does not exist.")
        }

        try await sport.save(on: req.db)
        return sport
    }

    // Créer plusieurs Sports
    @Sendable
    func createBatch(req: Request) async throws -> [SportModel] {
        let sports = try req.content.decode([SportModel].self) // Décoder un tableau de SportModel

        for sport in sports {
            // Vérification que chaque sportType existe
            guard let _ = try await SportTypeModel.find(sport.$sportType.id, on: req.db) else {
                throw Abort(.badRequest, reason: "SportType with ID \(sport.$sportType.id) does not exist.")
            }
            try await sport.save(on: req.db) // Enregistrer chaque sport
        }
        return sports // Retourner tous les sports créés
    }

    // Mettre à jour un Sport
    @Sendable
    func update(req: Request) async throws -> SportModel {
        guard let id = req.parameters.get("sportID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Sport ID.")
        }

        guard let existingSport = try await SportModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Sport with this ID not found.")
        }

        let updatedData = try req.content.decode(SportModel.self)

        // Vérification que le sportType existe
        guard let _ = try await SportTypeModel.find(updatedData.$sportType.id, on: req.db) else {
            throw Abort(.badRequest, reason: "SportType with ID \(updatedData.$sportType.id) does not exist.")
        }

        existingSport.name = updatedData.name
        existingSport.calorie = updatedData.calorie
        existingSport.$sportType.id = updatedData.$sportType.id

        try await existingSport.save(on: req.db)
        return existingSport
    }

    // Supprimer un Sport
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("sportID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Sport ID.")
        }

        guard let sport = try await SportModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Sport with this ID not found.")
        }

        try await sport.delete(on: req.db)
        return .noContent
    }
}

