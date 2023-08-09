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
        print("Successfully write image file to document directionary!")
    }
    
    public func saveCSVToDocument(csv: String, nameWithExtension: String) throws {
        let csvURL = getDocumentDirectionary().appendingPathComponent(nameWithExtension)
        var csvPath: String
        if #available(iOS 16.0, *) {
            csvPath = csvURL.path()
        } else {
            csvPath = csvURL.path
        }
        
        // Check if there exists files with the same name and remove it once existed.
        if FileManager.default.fileExists(atPath: csvPath) {
            do {
                try FileManager.default.removeItem(at: csvURL)
            } catch let error {
                print("Unable to remove existing csv file!")
                print(error.localizedDescription)
                throw LocalFileIOError.unableToRemoveExistingItem
            }
            print("Successfully remove duplicated file!")
        }
        
        do {
            try csv.write(to: csvURL, atomically: true, encoding: .utf8)
        } catch let error {
            print("Unable to write CSV file to document directionary!")
            print(error.localizedDescription)
            throw LocalFileIOError.unableToWriteToDocumentDirectionary
        }
        print("Successfully write CSV file to document directionary at path!")
    }
    
    public func fileExists(at url: URL) -> Bool {
        if #available(iOS 16.0, *) {
            return FileManager.default.fileExists(atPath: url.path())
        } else {
            return FileManager.default.fileExists(atPath: url.path)
        }
    }
    
    public func fileExistsAtDocument(nameWithExtension: String) -> Bool {
        let url = getFileURLAtDocument(nameWithExtension: nameWithExtension)
        return fileExists(at: url)
    }
    
    public func getFileURLAtDocument(nameWithExtension: String) -> URL {
        return getDocumentDirectionary().appendingPathComponent(nameWithExtension)
    }
    
    public func loadImageFromURL(_ url: URL) -> UIImage? {
        guard fileExists(at: url) else {
            print("Image file does not exist at url: \(url)")
            return nil
        }
        
        if #available(iOS 16.0, *) {
            return UIImage(contentsOfFile: url.path())
        } else {
            return UIImage(contentsOfFile: url.path)
        }
    }
    
    public func readPrivateKeyContentFromFile(filename: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: filename, ofType: "p8") else {
            print("Private key file not found")
            return nil
        }

        do {
            let privateKeyContent = try String(contentsOfFile: filePath, encoding: .utf8)
            return privateKeyContent
        } catch {
            print("Error reading private key content: \(error)")
            return nil
        }
    }
}

