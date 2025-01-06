//
//  TokenSession.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 04/01/2025.
//


import Vapor
import JWTKit

struct TokenSession: Content, Authenticatable, JWTPayload {
    var expirationTime: TimeInterval = 60 * 60 * 24 * 30
    
    // Token Data
    var expiration: ExpirationClaim
    var userId: UUID
    
    init(with user: UserModel) throws {
        self.userId = try user.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }
    
    func verify(using algorithm: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }
}
