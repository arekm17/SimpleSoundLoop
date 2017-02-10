//
//  FilesRepository.swift
//  SimpleSoundLoop
//
//  Created by Arek on 08.02.2017.
//  Copyright © 2017 Arek. All rights reserved.
//

import Foundation
import UIKit


class FilesRepository : NSObject {
    
    static var files : [String] = [String]()
    private static let fileDirectory : URL = SampleFile.getFilesDirectory()

    override class func initialize () {
        updateFiles()
    }
    
    class func updateFiles() {
    
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: fileDirectory, includingPropertiesForKeys: nil, options: [])

            files = directoryContents.filter(){$0.pathExtension == "caf"}.map {$0.lastPathComponent}
        
        } catch let error as NSError {
            print(error.localizedDescription)
            files = [String]()
        }
        
    }
    
    
}

extension FilesRepository : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilesRepository.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL")
        }
        
        // we know that cell is not empty now so we use ! to force unwrapping but you could also define cell as
        // let cell = (tableView.dequeue... as? UITableViewCell) ?? UITableViewCell(style: ...)
        
        cell!.textLabel?.text = FilesRepository.files[indexPath.row]
//        cell!.detailTextLabel?.text = "1/2 cup"
        
        return cell!
    }
    
}
