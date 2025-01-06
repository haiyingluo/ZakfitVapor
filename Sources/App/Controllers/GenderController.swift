//
//  GenderController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct GenderController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let genders = routes.grouped("genders") // Route principale
        genders.post(use: create)              // POST /genders
        genders.get(use: index)                // GET /genders
        genders.group(":genderID") { gender in
            gender.put(use: update)
            gender.delete(use: delete)
        }
//        genders.put(":id", use: update)        // PUT /genders/:id
//        genders.delete(":id", use: delete)     // DELETE /genders/:id
    }


    // Récupérer tous les Genders
    @Sendable
    func index(req: Request) async throws -> [GenderModel] {
        try await GenderModel.query(on: req.db).all()
    }

    // Créer un nouveau Gender
    @Sendable
    func create(req: Request) async throws -> GenderModel {
        let gender = try req.content.decode(GenderModel.self)
        try await gender.save(on: req.db)
        return gender
    }

    // Mettre à jour un Gender
    @Sendable
    func update(req: Request) async throws -> GenderModel {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Gender ID.")
        }

        guard let existingGender = try await GenderModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Gender with this ID not found.")
        }

        let updatedData = try req.content.decode(GenderModel.self)
        existingGender.title = updatedData.title

        try await existingGender.save(on: req.db)
        return existingGender
    }

    // Supprimer un Gender
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Gender ID.")
        }

        guard let gender = try await GenderModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Gender with this ID not found.")
        }

        try await gender.delete(on: req.db)
        return .noContent
    }
}
