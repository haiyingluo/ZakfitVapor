//
//  UserPreferDietaryModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 03/01/2025.
//


import Vapor
import Fluent

final class UserPreferDietaryModel: Model, Content, @unchecked Sendable {
    static let schema = "user_prefer_dietary"

    @ID(custom: "id_user_prefer_dietary")
    var id: UUID?

    @Parent(key: "id_user")
    var user: UserModel

    @Parent(key: "id_dietary")
    var dietary: DietaryModel

    // Initialisateur par défaut
    init() {}

    // Initialisateur avec paramètres
    init(id: UUID? = nil, userID: UUID, dietaryID: UUID) {
        self.id = id
        self.$user.id = userID
        self.$dietary.id = dietaryID
    }
}
