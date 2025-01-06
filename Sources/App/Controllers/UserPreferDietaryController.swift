//
//  UserPreferDietaryController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 03/01/2025.
//


import Vapor
import Fluent
import Vapor

struct UserPreferDietaryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userPreferDietaries = routes.grouped("user_prefer_dietary")
        userPreferDietaries.get(use: index)                 // GET /user_prefer_dietary
        userPreferDietaries.post(use: create)               // POST /user_prefer_dietary
        userPreferDietaries.group(":id") { userPreferDietary in
            userPreferDietary.put(use: update)              // PUT /user_prefer_dietary/:id
            userPreferDietary.delete(use: delete)           // DELETE /user_prefer_dietary/:id
        }
        userPreferDietaries.get("user", ":userID", use: getUserPreferences)  // GET /user_prefer_dietary/user/:userID
    }

    // Récupérer toutes les entrées
    @Sendable
    func index(req: Request) async throws -> [UserPreferDietaryModel] {
        try await UserPreferDietaryModel.query(on: req.db).with(\.$user).with(\.$dietary).all()
    }

    // Créer une nouvelle entrée
    @Sendable
    func create(req: Request) async throws -> UserPreferDietaryModel {
        let input = try req.content.decode(UserPreferDietaryModel.self)
        try await input.save(on: req.db)
        return input
    }

    // Mettre à jour une entrée existante
    @Sendable
    func update(req: Request) async throws -> UserPreferDietaryModel {
        guard let id = req.parameters.get("id", as: UUID.self),
              let existingPreference = try await UserPreferDietaryModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Preference not found.")
        }

        let updatedData = try req.content.decode(UserPreferDietaryModel.self)
        existingPreference.$user.id = updatedData.$user.id
        existingPreference.$dietary.id = updatedData.$dietary.id

        try await existingPreference.save(on: req.db)
        return existingPreference
    }

    // Supprimer une entrée
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self),
              let preference = try await UserPreferDietaryModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Preference not found.")
        }

        try await preference.delete(on: req.db)
        return .noContent
    }

    // Récupérer les préférences diététiques d'un utilisateur spécifique
    @Sendable
    func getUserPreferences(req: Request) async throws -> [UserPreferDietaryModel] {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "User ID is required.")
        }

        return try await UserPreferDietaryModel.query(on: req.db)
            .filter(\.$user.$id == userID)
            .with(\.$dietary)
            .all()
    }
}
