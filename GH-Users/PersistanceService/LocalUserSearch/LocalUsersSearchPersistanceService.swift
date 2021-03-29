//
//  LocalUsersSearchPersistanceService.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import Foundation
import CoreData

protocol LocalUsersSearchPersistanceServiceProtocol {
    func getResponse(for request: LocalUsersSearchQuery, completion: @escaping (Result<[UserEntity]?, PersistanceError>) -> Void)
}

final class LocalUsersSearchPersistanceService {
    private let persistenceManager: PersistenceManager

    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    // MARK: - Private

    private func getFetchRequest(for request: LocalUsersSearchQuery) -> NSFetchRequest<UserEntity> {
        let fetchRequest: NSFetchRequest = UserEntity.fetchRequest()
        
        let loginContainsPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(UserEntity.login), request.query)
        let loginMatchesPredicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(UserEntity.login), request.query)

        let noteContainsPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(UserEntity.note), request.query)
        let noteMatchesPredicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(UserEntity.note), request.query)
        
        let compoundPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: [loginContainsPredicate, loginMatchesPredicate, noteContainsPredicate, noteMatchesPredicate])

        fetchRequest.predicate = compoundPredicates
        return fetchRequest
    }
}

extension LocalUsersSearchPersistanceService: LocalUsersSearchPersistanceServiceProtocol {
    func getResponse(for query: LocalUsersSearchQuery, completion: @escaping (Result<[UserEntity]?, PersistanceError>) -> Void) {
        let context = persistenceManager.viewContext
        context.perform {
            do {
                let fetchRequest = self.getFetchRequest(for: query)
                let userList = try context.fetch(fetchRequest)

                DispatchQueue.main.async { return completion(.success(userList)) }
            } catch {
                DispatchQueue.main.async { return completion(.failure(PersistanceError.readError(error))) }
            }
        }
    }
}
