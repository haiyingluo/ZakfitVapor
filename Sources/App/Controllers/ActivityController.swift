//
//  ActivityController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct ActivityController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let activities = routes.grouped("activities")
        activities.post(use: create)
        activities.get(use: index)
        activities.group(":activityID") { activity in
            activity.put(use: update)
            activity.delete(use: delete)
            activity.get("calories", use: calculateCalories)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [ActivityModel] {
        try await ActivityModel.query(on: req.db).with(\.$intensity).with(\.$sport).all()
    }

    @Sendable
    func create(req: Request) async throws -> ActivityModel {
        let activity = try req.content.decode(ActivityModel.self)
        try await activity.save(on: req.db)
        return activity
    }

    @Sendable
    func update(req: Request) async throws -> ActivityModel {
        guard let id = req.parameters.get("activityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Activity ID.")
        }
        guard let existingActivity = try await ActivityModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Activity not found.")
        }

        let updatedData = try req.content.decode(ActivityModel.self)
        existingActivity.date = updatedData.date
        existingActivity.duration = updatedData.duration
        existingActivity.$intensity.id = updatedData.$intensity.id
        existingActivity.$user.id = updatedData.$user.id
        existingActivity.$sport.id = updatedData.$sport.id

        try await existingActivity.save(on: req.db)
        return existingActivity
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("activityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Activity ID.")
        }
        guard let activity = try await ActivityModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Activity not found.")
        }
        try await activity.delete(on: req.db)
        return .noContent
    }

    @Sendable
    func calculateCalories(req: Request) async throws -> [String: Double] {
        guard let id = req.parameters.get("activityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Activity ID.")
        }
        guard let activity = try await ActivityModel.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$intensity)
            .with(\.$sport)
            .first() else {
            throw Abort(.notFound, reason: "Activity not found.")
        }

        let caloriesBurned = Double(activity.duration) * activity.intensity.calorieMultiplier * Double(activity.sport.calorie)
        return ["calories": caloriesBurned]
    }
}
