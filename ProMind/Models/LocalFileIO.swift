//
//  LocalFileIO.swift
//  ProMind
//
//  Created by HAIKUO YU on 29/4/23.
//

import Foundation
import UIKit

enum LocalFileIOError: Error {
    case unableToCompressImageIntoJPEG
    case unableToRemoveExistingItem
    case unableToWriteToDocumentDirectionary
}


class LocalFileIO {
    public func getDocumentDirectionary() -> URL {
        if #available(iOS 16.0, *) {
            return URL.documentsDirectory
        } else {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docummentDirectionary = path[0]
            return docummentDirectionary
        }
    }
    
    public func saveImageToDocument(image: UIImage, withName name: String) throws {
        guard let downsampledImage = image.jpegData(compressionQuality: 0.2) else {
            print("Unable to downsample the image!")
            throw LocalFileIOError.unableToCompressImageIntoJPEG
        }
        
        let imageURL = getDocumentDirectionary().appendingPathComponent(name, conformingTo: .jpeg)
        var imagePath: String
        if #available(iOS 16.0, *) {
            imagePath = imageURL.path()
        } else {
            imagePath = imageURL.path
        }
        
        // Check if there exists an old image and remove it once existed.
        if FileManager.default.fileExists(atPath: imagePath) {
            do {
                try FileManager.default.removeItem(atPath: imagePath)
            } catch let error {
                print("Unable to remove existing file at image path: \(imagePath)")
                print(error.localizedDescription)
                throw LocalFileIOError.unableToRemoveExistingItem
            }
        }
        
        do {
            try downsampledImage.write(to: imageURL)
        } catch let error {
            print("Unable to write downsampled image to document directionary!")
            print(error.localizedDescription)
            throw LocalFileIOError.unableToWriteToDocumentDirectionary
        }
    }
}

