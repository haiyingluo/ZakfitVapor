//
//  ActivityModel.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 02/01/2025.
//


import Vapor
import Fluent

final class ActivityModel: Model, Content, @unchecked Sendable {
    static let schema = "activity"
    
    @ID(custom: "id_activity")
    var id: UUID?
    
    @Field(key: "date_activity")
    var date: Date
    
    @Field(key: "duration_activity")
    var duration: Int // Duration in minutes
    
    @Parent(key: "id_intensity")
    var intensity: IntensityModel
    
    @Parent(key: "id_user")
    var user: UserModel
    
    @Parent(key: "id_sport")
    var sport: SportModel
    
    init() {}
    
    init(id: UUID? = nil, date: Date, duration: Int, intensityID: UUID, userID: UUID, sportID: UUID) {
        self.id = id
        self.date = date
        self.duration = duration
        self.$intensity.id = intensityID
        self.$user.id = userID
        self.$sport.id = sportID
    }
}
