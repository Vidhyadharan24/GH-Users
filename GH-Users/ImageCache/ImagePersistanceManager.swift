//
//  ImagePersistanceManager.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation
import UIKit

public protocol ImagePersistanceManagerProtocol {
    func getImageFor(fileName: String) -> UIImage?
    
    func write(image: UIImage, fileName: String)
}


public class ImagePersistanceManager: ImagePersistanceManagerProtocol {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
    public func getImageFor(fileName: String) -> UIImage? {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let image = UIImage(contentsOfFile: fileURL.path) {
                return image
            }
        }
                
        return nil
    }
    
    public func write(image: UIImage, fileName: String) {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality:  1.0),
           !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }    
}
