//
//  UserModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//

import Vapor
import Fluent

final class UserModel: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(custom: "id_user")
    var id: UUID?
    
    @Field(key: "nom_user")
    var lastName: String
    
    @Field(key: "prenom_user")
    var firstName: String
    
    @Field(key: "mail_user")
    var email: String
    
    @Field(key: "password_user")
    var password: String
    
    @Field(key: "birthday_user")
    var birthday: Date
    
    @Field(key: "height_user")
    var height: Double
    
    @Parent(key: "id_gender")
    var gender: GenderModel
    
    @Parent(key: "id_goal_health")
    var goalHealth: GoalHealthModel
    
    @OptionalParent(key: "id_weight_history")
    var weightHistory: WeightHistoryModel?
    
    init() {}
    
    init(
        id: UUID? = nil,
        lastName: String,
        firstName: String,
        email: String,
        password: String,
        birthday: Date,
        height: Double,
        genderID: UUID,
        goalHealthID: UUID,
        weightHistoryID: UUID? = nil
    ) {
        self.id = id ?? UUID()
        self.lastName = lastName
        self.firstName = firstName
        self.email = email
        self.password = password
        self.birthday = birthday
        self.height = height
        self.$gender.id = genderID
        self.$goalHealth.id = goalHealthID
        self.$weightHistory.id = weightHistoryID
    }
    
    // Conversion en DTO
    func toDTO() -> UserDTO {
        return UserDTO(
            id: self.id,
            lastName: self.lastName,
            firstName: self.firstName,
            email: self.email,
            birthday: self.birthday,
            height: self.height,
            genderID: self.$gender.id,
            goalHealthID: self.$goalHealth.id,
            weightHistoryID: self.$weightHistory.id
        )
    }
}

extension UserModel: ModelAuthenticatable {
    static let usernameKey = \UserModel.$email
    static let passwordHashKey = \UserModel.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

