//
//  Encodable+getData.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import Foundation

extension Encodable {
    func toData() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
}
