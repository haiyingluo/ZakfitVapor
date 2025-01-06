//
//  FeedbackModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//


import Vapor
import Fluent

final class FeedbackModel: Model, Content, @unchecked Sendable {
    static let schema = "feedback"

    @ID(custom: "id_feedback")
    var id: UUID?

    @Field(key: "text_feedback")
    var text: String

    @Field(key: "date_feedback")
    var date: Date

    @Parent(key: "id_user")
    var user: UserModel

    init() {}

    init(id: UUID? = nil, text: String, date: Date, userID: UUID) {
        self.id = id
        self.text = text
        self.date = date
        self.$user.id = userID
    }
}
