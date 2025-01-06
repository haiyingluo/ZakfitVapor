//
//  UserController.swift
//  ZakfitVapor
//
//  Created by Apprenant 166 on 01/01/2025.
//

import Vapor
import Fluent
import FluentSQL


struct UserController: RouteCollection {
//    func boot(routes: RoutesBuilder) throws {
//        let users = routes.grouped("users") // Route principale
//        users.post(use: create)            // POST /users
//        users.get(use: index)             // GET /users
//
//        users.group(":userID") { user in
//            user.put(use: update)          // PUT /users/:userID
//            user.delete(use: delete)       // DELETE /users/:userID
//        }
//    }
    
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        
        let authGroupBasic = users.grouped(UserModel.authenticator(), UserModel.guardMiddleware())
        authGroupBasic.post("login",use: login)
        
        let authGroupToken = users.grouped(TokenSession.authenticator(), TokenSession.guardMiddleware())
        authGroupToken.get(use: index)
        
        //http://127.0.0.1:8081/users/byemail/?email=pierre@gmail.com
        //users.get("byemail", use: self.getUserByEmail)
        //http://127.0.0.1:8081/users/byemail/pierre@gmail.com
        authGroupToken.group("byemail") { user in
            user.get(":email", use: getUserByEmail)
        }
        
        authGroupToken.group("id") { user in
            user.get(use: getUserById)
            user.delete(use: delete)
            user.put(use: update)
        }
    }

    // Récupérer tous les utilisateurs
    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        // Rechercher tous les utilisateurs avec les relations nécessaires
        let users = try await UserModel.query(on: req.db)
            .with(\.$gender)
            .with(\.$goalHealth)
            .all()
        // Convertir les utilisateurs en DTO
        return users.map { $0.toDTO() }
    }


    // Créer un nouvel utilisateur
    @Sendable
    func create(req: Request) async throws -> HTTPStatus {
        let user = try req.content.decode(UserModel.self)
        
        if !user.email.isValidEmail() {
            throw Abort(.badRequest, reason: "Invalid email")
        }
        
        if user.password.count < 8 {
            throw Abort(.badRequest, reason: "Password too short")
        }
        
        user.password = try Bcrypt.hash(user.password)
        
        try await user.save(on: req.db)
        return .ok
    }
    
    // Récupérer l'utilisateur par ID
    @Sendable
    func getUserById(req: Request) async throws -> UserDTO {
        // Extraire l'ID utilisateur depuis le JWT
        let userId = try await DecodeRequest().getIdFromJWT(req: req)
        
        // Rechercher l'utilisateur avec ses relations nécessaires
        guard let user = try await UserModel.query(on: req.db)
            .with(\.$gender)
            .with(\.$goalHealth)
            .filter(\.$id == userId)
            .first()
        else {
            throw Abort(.notFound, reason: "User not found.")
        }
        
        // Convertir en DTO et retourner
        return user.toDTO()
    }
    
    // Récupérer l'utilisateur par mail
    @Sendable
    func getUserByEmail(req: Request) async throws -> UserDTO {
        // Extraire l'email depuis les paramètres de la requête
        guard let email = req.parameters.get("email") else {
            throw Abort(.badRequest, reason: "Invalid or missing email.")
        }

        // Rechercher l'utilisateur par email avec ses relations nécessaires
        guard let user = try await UserModel.query(on: req.db)
            .with(\.$gender)
            .with(\.$goalHealth)
            .with(\.$weightHistory)
            .filter(\.$email == email)
            .first()
        else {
            throw Abort(.notFound, reason: "User not found.")
        }

        // Convertir le modèle utilisateur en DTO et le retourner
        return user.toDTO()
    }

    // Mettre à jour un utilisateur
    @Sendable
    func update(req: Request) async throws -> UserDTO {
        // Extraire l'ID utilisateur depuis les paramètres
        guard let userIDString = req.parameters.get("userID"), let userID = UUID(uuidString: userIDString) else {
            throw Abort(.badRequest, reason: "Invalid or missing User ID.")
        }
        
        // Rechercher l'utilisateur existant
        guard let existingUser = try await UserModel.query(on: req.db)
            .with(\.$gender)
            .with(\.$goalHealth)
            .with(\.$weightHistory)
            .filter(\.$id == userID)
            .first()
        else {
            throw Abort(.notFound, reason: "User not found.")
        }
        
        // Décoder les nouvelles données depuis le corps de la requête
        let updatedData = try req.content.decode(UserDTO.self)
        
        // Mettre à jour les champs de l'utilisateur
        existingUser.lastName = updatedData.lastName
        existingUser.firstName = updatedData.firstName
        existingUser.email = updatedData.email
        existingUser.birthday = updatedData.birthday
        existingUser.height = updatedData.height
        existingUser.$gender.id = updatedData.genderID
        existingUser.$goalHealth.id = updatedData.goalHealthID
        existingUser.$weightHistory.id = updatedData.weightHistoryID
        
        // Sauvegarder les modifications dans la base de données
        try await existingUser.save(on: req.db)
        
        // Retourner l'utilisateur mis à jour sous forme de DTO
        return existingUser.toDTO()
    }


    // Supprimer un utilisateur
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        // Vérifiez si l'utilisateur est authentifié et extrait l'ID depuis le JWT
        if let userIdFromToken = try? await DecodeRequest().getIdFromJWT(req: req) {
            guard let user = try await UserModel.find(userIdFromToken, on: req.db) else {
                throw Abort(.notFound, reason: "User not found.")
            }
            try await user.delete(on: req.db)
            return .noContent
        }

        // Sinon, vérifiez si l'ID utilisateur est fourni dans les paramètres de la requête
        guard let userIDString = req.parameters.get("userID"), let userID = UUID(uuidString: userIDString) else {
            throw Abort(.badRequest, reason: "Invalid or missing User ID.")
        }

        guard let user = try await UserModel.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }

        try await user.delete(on: req.db)
        return .noContent
    }

    
    // login avec Middleware, méthode avec token:
    @Sendable
    func login(req: Request) async throws -> [String: String] {
        // Récupération des logins/mdp
        let user = try req.auth.require(UserModel.self)
        // Création du payload en fonction des informations du user
        let payload = try TokenSession(with: user)
        // Création d'un token signé à partir du payload
        let token = try await req.jwt.sign(payload)
        // Envoi du token à l'utilisateur sous forme de dictionnaire return ["token": token]
        return ["token": token]
    }
}
