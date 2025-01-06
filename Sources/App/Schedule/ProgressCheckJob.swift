//
//  ProgressCheckJob.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 04/01/2025.
//


import Vapor
import Queues
import Fluent

struct ProgressCheckJob: AsyncScheduledJob {
    func run(context: JobContext) async throws {
        let db = context.application.db

        // 1. Récupérer les utilisateurs
        let users = try await UserModel.query(on: db).all()

        for user in users {
            // 2. Calculer les progrès de l'utilisateur
            let progress = try await calculateProgress(for: user, on: db)

            // 3. Vérifier si le progrès atteint le seuil de notification
            if progress >= 80 {
                let notificationText = "Bravo ! Vous avez atteint \(progress)% de votre objectif d'activité."
                let notification = NotificationModel(
                    textNotification: notificationText,
                    sentTime: Date(),
                    sentStatus: false,
                    userID: try user.requireID()
                )

                // 4. Enregistrer la notification
                try await notification.save(on: db)
            }
        }
    }

    // Fonction pour calculer les progrès
    private func calculateProgress(for user: UserModel, on db: Database) async throws -> Int {
        let goalActivities = try await GoalActivityModel.query(on: db)
            .filter(\.$user.$id == try user.requireID())
            .all()

        guard !goalActivities.isEmpty else { return 0 }

        let totalGoals = goalActivities.count
        let completedGoals = goalActivities.filter { $0.progressSessions >= $0.frequency }.count

        return (completedGoals * 100) / totalGoals
    }
}
