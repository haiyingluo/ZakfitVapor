//
//  DietaryController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct DietaryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let dietaries = routes.grouped("dietaries") // Route principale
        dietaries.post(use: create)                 // POST /dietaries
        dietaries.get(use: index)                  // GET /dietaries
        dietaries.group(":dietaryID") { dietary in
            dietary.put(use: update)
            dietary.delete(use: delete)
        }
//        dietaries.put(":id", use: update)          // PUT /dietaries/:id
//        dietaries.delete(":id", use: delete)       // DELETE /dietaries/:id
    }

    // Récupérer tous les Dietary
    @Sendable
    func index(req: Request) async throws -> [DietaryModel] {
        try await DietaryModel.query(on: req.db).all()
    }

    // Créer un nouveau Dietary
    @Sendable
    func create(req: Request) async throws -> DietaryModel {
        let dietary = try req.content.decode(DietaryModel.self)
        try await dietary.save(on: req.db)
        return dietary
    }

    // Mettre à jour un Dietary
    @Sendable
    func update(req: Request) async throws -> DietaryModel {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Dietary ID.")
        }

        guard let existingDietary = try await DietaryModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Dietary with this ID not found.")
        }

        let updatedData = try req.content.decode(DietaryModel.self)
        existingDietary.name = updatedData.name

        try await existingDietary.save(on: req.db)
        return existingDietary
    }

    // Supprimer un Dietary
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Dietary ID.")
        }

        guard let dietary = try await DietaryModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Dietary with this ID not found.")
        }

        try await dietary.delete(on: req.db)
        return .noContent
    }
}
