//
//  IntensityController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent
import FluentSQL


struct IntensityController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let intensities = routes.grouped("intensities")
        intensities.post(use: create)
        intensities.get(use: index)
        intensities.group(":intensityID") { intensity in
            intensity.put(use: update)
            intensity.delete(use: delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [IntensityModel] {
        try await IntensityModel.query(on: req.db).all()
    }

    @Sendable
    func create(req: Request) async throws -> IntensityModel {
        let intensity = try req.content.decode(IntensityModel.self)
        try await intensity.save(on: req.db)
        return intensity
    }

    @Sendable
    func update(req: Request) async throws -> IntensityModel {
        guard let id = req.parameters.get("intensityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Intensity ID.")
        }
        guard let existingIntensity = try await IntensityModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Intensity not found.")
        }
        
        let updatedData = try req.content.decode(IntensityModel.self)
        existingIntensity.name = updatedData.name
        existingIntensity.calorieMultiplier = updatedData.calorieMultiplier
        try await existingIntensity.save(on: req.db)
        return existingIntensity
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("intensityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Intensity ID.")
        }
        guard let intensity = try await IntensityModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Intensity not found.")
        }
        try await intensity.delete(on: req.db)
        return .noContent
    }
}
