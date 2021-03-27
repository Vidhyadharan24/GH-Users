//
//  ImagePersistanceManager.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public enum ImagePersistanceError: Error {
    case noImage(Error)
    case writeError(Error)
}

public protocol ImagePersistanceManagerProtocol {
    func getImageFor(fileName: String) -> Result<Data?, ImagePersistanceError>
    
    func write(data: Data, fileName: String) -> ImagePersistanceError?
}


public class ImagePersistanceManager: ImagePersistanceManagerProtocol {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
    public func getImageFor(fileName: String) -> Result<Data?, ImagePersistanceError> {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: fileURL)
            return .success(data)
        } catch (let error) {
            return .failure(.noImage(error))
        }
    }
    
    public func write(data: Data, fileName: String) -> ImagePersistanceError? {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return nil
        } catch (let error) {
            return .writeError(error)
        }
    }    
}
