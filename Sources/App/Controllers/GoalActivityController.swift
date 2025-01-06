//
//  GoalActivityController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct GoalActivityController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let goalActivities = routes.grouped("goal_activities")
        goalActivities.post(use: create)             // POST /goal_activities
        goalActivities.get(use: index)               // GET /goal_activities
        goalActivities.group(":goalActivityID") { goalActivity in
            goalActivity.put(use: update)            // PUT /goal_activities/:goalActivityID
            goalActivity.delete(use: delete)         // DELETE /goal_activities/:goalActivityID
        }
    }

    // Récupérer toutes les GoalActivities
    @Sendable
    func index(req: Request) async throws -> [GoalActivityModel] {
        try await GoalActivityModel.query(on: req.db)
            .with(\.$goalType)
            .with(\.$user)
            .all()
    }

    // Créer une nouvelle GoalActivity
    @Sendable
    func create(req: Request) async throws -> GoalActivityModel {
        let goalActivity = try req.content.decode(GoalActivityModel.self)
        try await goalActivity.save(on: req.db)
        return goalActivity
    }

    // Mettre à jour une GoalActivity
    @Sendable
    func update(req: Request) async throws -> GoalActivityModel {
        guard let id = req.parameters.get("goalActivityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Goal Activity ID.")
        }

        guard let existingGoalActivity = try await GoalActivityModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Goal Activity not found.")
        }

        let updatedData = try req.content.decode(GoalActivityModel.self)
        existingGoalActivity.frequency = updatedData.frequency
        existingGoalActivity.calorieBurned = updatedData.calorieBurned
        existingGoalActivity.sessionDuration = updatedData.sessionDuration
        existingGoalActivity.progressSessions = updatedData.progressSessions
        existingGoalActivity.dateStart = updatedData.dateStart
        existingGoalActivity.dateEnd = updatedData.dateEnd
        existingGoalActivity.$goalType.id = updatedData.$goalType.id
        existingGoalActivity.$user.id = updatedData.$user.id

        try await existingGoalActivity.save(on: req.db)
        return existingGoalActivity
    }

    // Supprimer une GoalActivity
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("goalActivityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Goal Activity ID.")
        }

        guard let goalActivity = try await GoalActivityModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Goal Activity not found.")
        }

        try await goalActivity.delete(on: req.db)
        return .noContent
    }
}
