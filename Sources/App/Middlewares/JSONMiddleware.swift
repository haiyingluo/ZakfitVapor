//
//  JSONMiddleware.swift
//  AtHomeVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//

import Vapor

struct JSONMiddleware : AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        
        guard request.headers.contentType?.description == "application/json" else {
            throw Abort(.unauthorized, reason: "Content-Type must be JSON")
        }
        
        return try await next.respond(to: request)
    }
}
