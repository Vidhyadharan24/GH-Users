//
//  UIIMage+InvertImage.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

extension UIImage {
    func invertImage() -> UIImage {
        let beginImage = CIImage(image: self)
        let filter = CIFilter(name: "CIColorInvert")!
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        let newImage = UIImage(ciImage: filter.outputImage!)
        return newImage
    }
}
