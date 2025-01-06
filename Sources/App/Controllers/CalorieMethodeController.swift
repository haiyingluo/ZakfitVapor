//
//  CalorieMethodeController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

struct CalorieMethodeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let calorieMethodes = routes.grouped("calorie_methodes")
        calorieMethodes.get(use: index)      // GET /calorie_methodes
        calorieMethodes.post(use: create)    // POST /calorie_methodes
        calorieMethodes.group(":id") { route in
            route.get(use: show)             // GET /calorie_methodes/:id
            route.put(use: update)           // PUT /calorie_methodes/:id
            route.delete(use: delete)        // DELETE /calorie_methodes/:id
        }
    }

    // Récupérer toutes les méthodes de calcul
    @Sendable
    func index(req: Request) async throws -> [CalorieMethodeModel] {
        try await CalorieMethodeModel.query(on: req.db).all()
    }

    // Créer une nouvelle méthode de calcul
    @Sendable
    func create(req: Request) async throws -> CalorieMethodeModel {
        let input = try req.content.decode(CalorieMethodeModel.self)
        try await input.save(on: req.db)
        return input
    }

    // Afficher une méthode de calcul spécifique
    @Sendable
    func show(req: Request) async throws -> CalorieMethodeModel {
        guard let id = req.parameters.get("id", as: UUID.self),
              let method = try await CalorieMethodeModel.find(id, on: req.db)
        else {
            throw Abort(.notFound, reason: "Calorie method not found.")
        }
        return method
    }

    // Mettre à jour une méthode de calcul existante
    @Sendable
    func update(req: Request) async throws -> CalorieMethodeModel {
        guard let id = req.parameters.get("id", as: UUID.self),
              let existingMethod = try await CalorieMethodeModel.find(id, on: req.db)
        else {
            throw Abort(.notFound, reason: "Calorie method not found.")
        }

        let input = try req.content.decode(CalorieMethodeModel.self)
        existingMethod.name = input.name
        try await existingMethod.save(on: req.db)
        return existingMethod
    }

    // Supprimer une méthode de calcul
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self),
              let method = try await CalorieMethodeModel.find(id, on: req.db)
        else {
            throw Abort(.notFound, reason: "Calorie method not found.")
        }

        try await method.delete(on: req.db)
        return .noContent
    }
}
