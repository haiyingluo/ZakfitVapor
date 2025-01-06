//
//  FeedbackController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct FeedbackController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let feedbacks = routes.grouped("feedbacks")
        feedbacks.post(use: create)             // POST /feedbacks
        feedbacks.get(use: index)               // GET /feedbacks
        feedbacks.group(":feedbackID") { feedback in
            feedback.put(use: update)           // PUT /feedbacks/:feedbackID
            feedback.delete(use: delete)        // DELETE /feedbacks/:feedbackID
        }
    }

    // Récupérer tous les feedbacks
    @Sendable
    func index(req: Request) async throws -> [FeedbackModel] {
        try await FeedbackModel.query(on: req.db)
            .with(\.$user) // Inclure l'utilisateur associé
            .all()
    }

    // Créer un nouveau feedback
    @Sendable
    func create(req: Request) async throws -> FeedbackModel {
        let feedback = try req.content.decode(FeedbackModel.self)
        try await feedback.save(on: req.db)
        return feedback
    }

    // Mettre à jour un feedback
    @Sendable
    func update(req: Request) async throws -> FeedbackModel {
        guard let id = req.parameters.get("feedbackID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Feedback ID.")
        }

        guard let existingFeedback = try await FeedbackModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Feedback with this ID not found.")
        }

        let updatedData = try req.content.decode(FeedbackModel.self)
        existingFeedback.text = updatedData.text
        existingFeedback.date = updatedData.date

        try await existingFeedback.save(on: req.db)
        return existingFeedback
    }

    // Supprimer un feedback
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("feedbackID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing Feedback ID.")
        }

        guard let feedback = try await FeedbackModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Feedback with this ID not found.")
        }

        try await feedback.delete(on: req.db)
        return .noContent
    }
}
