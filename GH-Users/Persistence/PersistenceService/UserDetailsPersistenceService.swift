//
//  UserDetailsPersistenceService.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation
import CoreData

enum UserDetailsPeristanceServiceError: Error {
    case invalidNote
}

protocol UserDetailsPersistenceServiceProtocol {
    func getResponse(for request: UserDetailsRequest, completion: @escaping (Result<UserEntity?, Error>) -> Void)
    func save(request: UserDetailsRequest, response: UserDetailsResponse, completion: @escaping (Error?) -> Void)
    func save(note: String, request: UserDetailsRequest, completion: @escaping (Error?) -> Void)
}

class UserDetailsPersistenceService: UserDetailsPersistenceServiceProtocol {
    private let persistenceManager: PersistenceManager

    init(persistenceManager: PersistenceManager = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
    }

    // MARK: - Private

    private func getFetchRequest(for request: UserDetailsRequest) -> NSFetchRequest<UserEntity> {
        let fetchRequest: NSFetchRequest = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@",
                                             #keyPath(UserEntity.login), request.username)
        return fetchRequest
    }
}

extension UserDetailsPersistenceService {
    func getResponse(for request: UserDetailsRequest, completion: @escaping (Result<UserEntity?, Error>) -> Void) {
        let context = persistenceManager.viewContext
        context.perform {
            do {
                let fetchRequest = self.getFetchRequest(for: request)
                let userEntity = try context.fetch(fetchRequest).first

                DispatchQueue.main.async { return completion(.success(userEntity)) }
            } catch {
                DispatchQueue.main.async { return completion(.failure(PersistenceError.readError(error))) }
            }
        }
    }
    
    func save(request: UserDetailsRequest, response: UserDetailsResponse, completion: @escaping (Error?) -> Void) {
        persistenceManager.saveInBackgroundContext {(context) in
            do {
                let fetchRequest = self.getFetchRequest(for: request)
                let userEntity = try context.fetch(fetchRequest).first
                
                userEntity?.update(user: response)

                try context.save()
    
                DispatchQueue.main.async { return completion(nil) }
            } catch (let error) {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
                DispatchQueue.main.async { return completion(PersistenceError.saveError(error)) }
            }
        }
    }
    
    func save(note: String, request: UserDetailsRequest, completion: @escaping (Error?) -> Void) {
        guard !note.isEmpty else { return completion(UserDetailsPeristanceServiceError.invalidNote) }
        persistenceManager.saveInBackgroundContext {(context) in
            do {
                let fetchRequest = self.getFetchRequest(for: request)
                let userEntity = try context.fetch(fetchRequest).first
                userEntity?.note = note
                try context.save()
    
                DispatchQueue.main.async { return completion(nil) }
            } catch (let error) {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
                DispatchQueue.main.async { return completion(PersistenceError.saveError(error)) }
            }
        }
    }    
}
