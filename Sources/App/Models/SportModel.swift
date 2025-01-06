//
//  SportModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//

import Vapor
import Fluent

final class SportModel: Model, Content, @unchecked Sendable {
    static let schema = "sport"

    @ID(custom: "id_sport")
    var id: UUID?

    @Field(key: "name_sport")
    var name: String

    @Field(key: "calorie_sport")
    var calorie: Int

    @Parent(key: "id_sport_type")
    var sportType: SportTypeModel

    init() {}

    init(id: UUID? = nil, name: String, calorie: Int, sportTypeID: UUID) {
        self.id = id
        self.name = name
        self.calorie = calorie
        self.$sportType.id = sportTypeID
    }
}
