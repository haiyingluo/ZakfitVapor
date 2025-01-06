//
//  NotificationModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 04/01/2025.
//


import Vapor
import Fluent

final class NotificationModel: Model, Content, @unchecked Sendable {
    static let schema = "notification"

    @ID(custom: "id_notification")
    var id: UUID?

    @Field(key: "text_notification")
    var textNotification: String

    @Field(key: "sent_time")
    var sentTime: Date?

    @Field(key: "sent_status")
    var sentStatus: Bool

    @Parent(key: "id_user")
    var user: UserModel

    init() {}

    init(id: UUID? = nil, textNotification: String, sentTime: Date? = nil, sentStatus: Bool = false, userID: UUID) {
        self.id = id
        self.textNotification = textNotification
        self.sentTime = sentTime
        self.sentStatus = sentStatus
        self.$user.id = userID
    }
}
