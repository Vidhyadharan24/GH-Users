//
//  UserDetailsPersistanceService.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation
import CoreData

protocol UserDetailsPersistanceServiceProtocol {
    func getResponse(for request: UserDetailsRequest, completion: @escaping (Result<UserEntity?, PersistanceError>) -> Void)
    func save(request: UserDetailsRequest, response: UserDetailsResponse, completion: @escaping (PersistanceError?) -> Void)
    func save(note: String, request: UserDetailsRequest)

}

class UserDetailsPersistanceService: UserDetailsPersistanceServiceProtocol {
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

extension UserDetailsPersistanceService {
    func getResponse(for request: UserDetailsRequest, completion: @escaping (Result<UserEntity?, PersistanceError>) -> Void) {
        let context = persistenceManager.viewContext
        context.perform {
            do {
                let fetchRequest = self.getFetchRequest(for: request)
                let userEntity = try context.fetch(fetchRequest).first

                completion(.success(userEntity))
            } catch {
                completion(.failure(PersistanceError.readError(error)))
            }
        }
    }
    
    func save(request: UserDetailsRequest, response: UserDetailsResponse, completion: @escaping (PersistanceError?) -> Void) {
        let context = persistenceManager.backgroundContext
        context.performAndWait {
            do {
                let fetchRequest = self.getFetchRequest(for: request)
                let userEntity = try context.fetch(fetchRequest).first
                
                userEntity?.update(user: response)

                try context.save()
    
                completion(nil)
            } catch (let error) {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
                completion(PersistanceError.saveError(error))
            }
        }
    }
    
    func save(note: String, request: UserDetailsRequest) {
        let context = persistenceManager.backgroundContext
        context.performAndWait {
            do {
                let fetchRequest = self.getFetchRequest(for: request)
                let userEntity = try context.fetch(fetchRequest).first
                userEntity?.note = note
                try context.save()
    
            } catch (let error) {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
}
