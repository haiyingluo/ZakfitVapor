//
//  NotificationController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 04/01/2025.
//


import Vapor
import Fluent
import FluentSQL

struct NotificationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let notifications = routes.grouped("notifications")
        notifications.post(use: create)                 // POST /notifications
        notifications.get(use: index)                   // GET /notifications
        notifications.get(":notificationID", use: show) // GET /notifications/:notificationID
        notifications.put(":notificationID", use: update) // PUT /notifications/:notificationID
        notifications.delete(":notificationID", use: delete) // DELETE /notifications/:notificationID
        notifications.post("check-progress", use: checkProgressAndNotify) // POST /notifications/check-progress
    }

    // Créer une notification (CREATE)
    @Sendable
    func create(req: Request) async throws -> NotificationModel {
        let notification = try req.content.decode(NotificationModel.self)
        try await notification.save(on: req.db)
        return notification
    }

    // Récupérer toutes les notifications (READ - INDEX)
    @Sendable
    func index(req: Request) async throws -> [NotificationModel] {
        try await NotificationModel.query(on: req.db).all()
    }

    // Récupérer une notification spécifique par son ID (READ - SHOW)
    @Sendable
    func show(req: Request) async throws -> NotificationModel {
        guard let notification = try await NotificationModel.find(req.parameters.get("notificationID"), on: req.db) else {
            throw Abort(.notFound, reason: "Notification not found.")
        }
        return notification
    }

    // Mettre à jour une notification existante (UPDATE)
    @Sendable
    func update(req: Request) async throws -> NotificationModel {
        guard let notificationID = req.parameters.get("notificationID", as: UUID.self),
              let existingNotification = try await NotificationModel.find(notificationID, on: req.db) else {
            throw Abort(.notFound, reason: "Notification not found.")
        }

        let updatedData = try req.content.decode(NotificationModel.self)
        existingNotification.textNotification = updatedData.textNotification
        existingNotification.sentTime = updatedData.sentTime
        existingNotification.sentStatus = updatedData.sentStatus

        try await existingNotification.save(on: req.db)
        return existingNotification
    }

    // Supprimer une notification (DELETE)
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let notificationID = req.parameters.get("notificationID", as: UUID.self),
              let notification = try await NotificationModel.find(notificationID, on: req.db) else {
            throw Abort(.notFound, reason: "Notification not found.")
        }

        try await notification.delete(on: req.db)
        return .noContent
    }

    // Vérifier les progrès de l'utilisateur et envoyer une notification si nécessaire (CHECK-PROGRESS)
    @Sendable
    func checkProgressAndNotify(req: Request) async throws -> HTTPStatus {
        let input = try req.content.decode(UserProgressInput.self)

        // Rechercher l'utilisateur
        guard let user = try await UserModel.find(input.userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }

        // Calculer le pourcentage de progrès
        let progressPercentage = input.progress

        // Vérifier si le progrès atteint le seuil de notification
        if progressPercentage >= 80 {
            let notificationText = "Bravo ! Vous avez atteint \(progressPercentage)% de votre objectif d'activité."
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
