//
//  Cancellable.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public protocol Cancellable {
    func cancel()
}

extension BlockOperation: Cancellable {}
