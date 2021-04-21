//
//  UsersListPersistenceService.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation
import CoreData

protocol UsersListPersistenceServiceProtocol {
    func getResponse(for request: UsersListRequest, completion: @escaping (Result<[UserEntity]?, PersistenceError>) -> Void)
    func save(response: UsersListResponse, completion: @escaping (PersistenceError?) -> Void)
}

public final class UsersListPersistenceService: UsersListPersistenceServiceProtocol {
    private let persistenceManager: PersistenceManager
    private let fetchLimit: Int

    init(persistenceManager: PersistenceManager, fetchLimit: Int) {
        self.persistenceManager = persistenceManager
        self.fetchLimit = fetchLimit
    }

    // MARK: - Private
    private func getFetchRequest(for request: UsersListRequest) -> NSFetchRequest<UserEntity> {
        let fetchRequest: NSFetchRequest = UserEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "%K > %d",
                                             (\UserEntity.id)._kvcKeyPathString!, request.since)
        fetchRequest.fetchLimit = fetchLimit
        return fetchRequest
    }
}

extension UsersListPersistenceService {
    func getResponse(for request: UsersListRequest, completion: @escaping (Result<[UserEntity]?, PersistenceError>) -> Void) {
        let context = persistenceManager.viewContext
        context.perform {
            do {
                let fetchRequest = self.getFetchRequest(for: request)
                let userList = try context.fetch(fetchRequest)
                
                if (userList.count > 0) {
                    DispatchQueue.main.async { return completion(.success(userList)) }
                } else {
                    DispatchQueue.main.async { return completion(.failure(.noData)) }
                }
            } catch {
                DispatchQueue.main.async { return completion(.failure(PersistenceError.readError(error))) }
            }
        }
    }
    
    func save(response: UsersListResponse, completion: @escaping (PersistenceError?) -> Void) {
        persistenceManager.saveInBackgroundContext {(context) in
            do {
                for user in response {
                    let _ = UserEntity(user: user, insertInto: context)
                }
                try context.save()
    
                DispatchQueue.main.async { return completion(nil) }
            } catch (let error) {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
                DispatchQueue.main.async { return completion(PersistenceError.saveError(error)) }
            }
        }
    }
}
