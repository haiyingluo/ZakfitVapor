//
//  GoalCalorieController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

struct GoalCalorieController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let goals = routes.grouped("goals")
        goals.get(use: index)
        goals.post(use: create)
        goals.put(":goalID", use: update)
        goals.delete(":goalID", use: delete)
        
        // Fonctions supplémentaires
        goals.post("calculate-bmr", use: calculateBMR)
        goals.post("check-progress", use: checkProgressAndNotify)
    }

    //  Récupérer toutes les entrées BMR
    @Sendable
    func index(req: Request) async throws -> [GoalCalorieModel] {
        try await GoalCalorieModel.query(on: req.db).all()
    }

    //  Créer une nouvelle entrée BMR
    @Sendable
    func create(req: Request) async throws -> GoalCalorieModel {
        let goal = try req.content.decode(GoalCalorieModel.self)
        try await goal.save(on: req.db)
        return goal
    }

    //  Mettre à jour une entrée BMR existante
    @Sendable
    func update(req: Request) async throws -> GoalCalorieModel {
        guard let goalID = req.parameters.get("goalID", as: UUID.self),
              let existingGoal = try await GoalCalorieModel.find(goalID, on: req.db) else {
            throw Abort(.notFound, reason: "Goal not found.")
        }

        let updatedData = try req.content.decode(GoalCalorieModel.self)
        existingGoal.goalCalorie = updatedData.goalCalorie
        existingGoal.dateStart = updatedData.dateStart
        existingGoal.dateEnd = updatedData.dateEnd
        existingGoal.$user.id = updatedData.$user.id

        try await existingGoal.save(on: req.db)
        return existingGoal
    }

    // ✅ Supprimer une entrée BMR
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let goalID = req.parameters.get("goalID", as: UUID.self),
              let goal = try await GoalCalorieModel.find(goalID, on: req.db) else {
            throw Abort(.notFound, reason: "Goal not found.")
        }

        try await goal.delete(on: req.db)
        return .noContent
    }
    
    // Calculer le BMR d'un utilisateur
    @Sendable
    func calculateBMR(req: Request) async throws -> [String: Double] {
        let input = try req.content.decode(UserDTO.self)

        // Déballer l'ID optionnel avant de l'utiliser
        guard let userID = input.id else {
            throw Abort(.badRequest, reason: "User ID is required.")
        }

        // Rechercher l'utilisateur avec son historique de poids
        guard let user = try await UserModel.query(on: req.db)
            .with(\.$weightHistory)
            .filter(\.$id == userID)
            .first()
        else {
            throw Abort(.notFound, reason: "User not found.")
        }

        // Calculer le dernier poids et l'âge de l'utilisateur
        guard let lastWeightHistory = user.weightHistory else {
            throw Abort(.notFound, reason: "No weight history found for the user.")
        }

        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: user.birthday, to: Date())
        guard let age = ageComponents.year else {
            throw Abort(.badRequest, reason: "Could not calculate age.")
        }

        // Calcul du BMR
        let bmr: Double
                if user.gender.title == "Homme" {
                    bmr = 88.362 + (13.397 * lastWeightHistory.currentWeight) + (4.799 * user.height) - (5.677 * Double(age))
                } else if user.gender.title == "Femme" {
                    bmr = 447.593 + (9.247 * lastWeightHistory.currentWeight) + (3.098 * user.height) - (4.330 * Double(age))
                } else {
                    throw Abort(.badRequest, reason: "Invalid gender specified.")
                }

        return ["bmr": bmr]
    }


    //  Vérifier les progrès et envoyer une notification si nécessaire
    @Sendable
    func checkProgressAndNotify(req: Request) async throws -> HTTPStatus {
        let input = try req.content.decode(UserProgressInput.self)

        guard let user = try await UserModel.find(input.userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }

        let progressPercentage = input.progress
        if progressPercentage >= 80 {
            let notificationText = "Bravo ! Vous avez atteint \(progressPercentage)% de votre objectif."
            let notification = NotificationModel(
                textNotification: notificationText,
                sentTime: Date(),
                sentStatus: false,
                userID: input.userID
            )
            try await notification.save(on: req.db)
            return .created
        }

        return .ok
    }
}

