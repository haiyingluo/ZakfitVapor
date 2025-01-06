//
//  DietaryModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent

final class DietaryModel: Model, Content, @unchecked Sendable {
    static let schema = "dietary"

    @ID(custom: "id_dietary")
    var id: UUID?

    @Field(key: "name_dietary")
    var name: String

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
