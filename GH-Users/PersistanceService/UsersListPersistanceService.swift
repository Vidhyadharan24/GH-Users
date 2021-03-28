//
//  UsersListPersistanceService.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation
import CoreData

protocol UsersListStorageServiceProtocol {
    func getResponse(for request: UsersListRequest, completion: @escaping (Result<[UserEntity]?, PersistanceError>) -> Void)
    func save(response: UsersListResponse, completion: @escaping (PersistanceError?) -> Void)
}

final class UsersListStorageService: UsersListStorageServiceProtocol {
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
        fetchRequest.predicate = NSPredicate(format: "%K.intValue > %d",
                                             (\UserEntity.id)._kvcKeyPathString!, request.since)
        fetchRequest.fetchLimit = fetchLimit
        return fetchRequest
    }
}

extension UsersListStorageService {
    func getResponse(for request: UsersListRequest, completion: @escaping (Result<[UserEntity]?, PersistanceError>) -> Void) {
        let context = persistenceManager.viewContext
        context.perform {
            do {
                let fetchRequest = self.getFetchRequest(for: request)
                let userList = try context.fetch(fetchRequest)

                DispatchQueue.main.async { return completion(.success(userList)) }
            } catch {
                DispatchQueue.main.async { return completion(.failure(PersistanceError.readError(error))) }
            }
        }
    }
    
    func save(response: UsersListResponse, completion: @escaping (PersistanceError?) -> Void) {
        let context = persistenceManager.backgroundContext
        context.performAndWait {
            do {
                for user in response {
                    let _ = UserEntity(user: user, insertInto: context)
                }
                try context.save()
    
                DispatchQueue.main.async { return completion(nil) }
            } catch (let error) {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
                DispatchQueue.main.async { return completion(PersistanceError.saveError(error)) }
            }
        }
    }
}
