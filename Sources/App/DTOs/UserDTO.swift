//
//  UserDTO.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 04/01/2025.
//


import Vapor

struct UserDTO: Content {
    let id: UUID? 
    let lastName: String
    let firstName: String
    let email: String
    let birthday: Date
    let height: Double
    let genderID: UUID
    let goalHealthID: UUID
    let weightHistoryID: UUID?

    func toModel() -> UserModel {
        return UserModel(id:id,
                         lastName: lastName,
                         firstName: firstName,
                         email: email,
                         password: "default",
                         birthday: birthday,
                         height: height,
                         genderID: genderID,
                         goalHealthID: goalHealthID,
                         weightHistoryID: weightHistoryID)
    }
}
