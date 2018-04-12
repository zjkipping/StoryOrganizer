//
//  URL.swift
//  StoryOrganizer
//
//  Created by Adam Thoma-Perry on 4/19/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import Foundation

extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    
                    return nil
                }
            }
            
            return filePath
        } else {
            return nil
        }
    }
}
