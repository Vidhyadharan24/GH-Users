//
//  RepositoryTask.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public class RepositoryTask: Cancellable {
    var task: Cancellable?
    var isCancelled: Bool = false
    
    public func cancel() {
        task?.cancel()
        isCancelled = true
    }
}
