//
//  GenderModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//

import Vapor
import Fluent

final class GenderModel: Model, Content, @unchecked Sendable {
    static let schema = "gender"

    @ID(custom: "id_gender")
    var id: UUID?

    @Field(key: "title_gender")
    var title: String

    init() {}

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
