//
//  ImagePersistenceManager.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public enum ImagePersistenceError: Error {
    case noImage(Error)
    case writeError(Error)
}

public protocol ImagePersistenceManagerProtocol {
    func getImageFor(fileName: String) -> Result<Data?, ImagePersistenceError>
    func write(data: Data, fileName: String) -> ImagePersistenceError?
}


/// ImagePersistenceManager writes the image data to the file system
// REQUIRED TASK: All ​media​ has to be ​cached​ on disk.
public class ImagePersistenceManager: ImagePersistenceManagerProtocol {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
    public func getImageFor(fileName: String) -> Result<Data?, ImagePersistenceError> {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: fileURL)
            return .success(data)
        } catch (let error) {
            return .failure(.noImage(error))
        }
    }
    
    public func write(data: Data, fileName: String) -> ImagePersistenceError? {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return nil
        } catch (let error) {
            return .writeError(error)
        }
    }    
}
