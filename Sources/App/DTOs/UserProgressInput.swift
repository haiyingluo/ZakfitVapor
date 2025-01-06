//
//  UserProgressInput.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 04/01/2025.
//

import Vapor
import Fluent

//  Modèle d'entrée pour les progrès de l'utilisateur
struct UserProgressInput: Content {
    let userID: UUID
    let progress: Int
}
