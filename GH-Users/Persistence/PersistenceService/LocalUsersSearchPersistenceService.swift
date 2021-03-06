//
//  LocalUsersSearchPersistenceService.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import Foundation
import CoreData

protocol LocalUsersSearchPersistenceServiceProtocol {
    func getResponse(for request: LocalUsersSearchQuery, completion: @escaping (Result<[UserEntity]?, PersistenceError>) -> Void)
}

final class LocalUsersSearchPersistenceService {
    private let persistenceManager: PersistenceManager

    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    // MARK: - Private

    // REQUIRED TASK: Users list has to be searchable - local search only; in ​search mode,​ there is no
    // pagination; username and note (see Profile section) fields should be used when
    // searching; precise match as well as ​contains s​ hould be used.
    private func getFetchRequest(for request: LocalUsersSearchQuery) -> NSFetchRequest<UserEntity> {
        let fetchRequest: NSFetchRequest = UserEntity.fetchRequest()
        
        let loginContainsPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(UserEntity.login), request.query)
        let loginMatchesPredicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(UserEntity.login), request.query)

        let noteContainsPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(UserEntity.note), request.query)
        let noteMatchesPredicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(UserEntity.note), request.query)
        
        let compoundPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: [loginContainsPredicate, loginMatchesPredicate, noteContainsPredicate, noteMatchesPredicate])

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = compoundPredicates
        return fetchRequest
    }
}

extension LocalUsersSearchPersistenceService: LocalUsersSearchPersistenceServiceProtocol {
    func getResponse(for query: LocalUsersSearchQuery, completion: @escaping (Result<[UserEntity]?, PersistenceError>) -> Void) {
        let context = persistenceManager.viewContext
        context.perform {
            do {
                let fetchRequest = self.getFetchRequest(for: query)
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
}
