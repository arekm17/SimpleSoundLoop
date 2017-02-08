//
//  FilesRepository.swift
//  SimpleSoundLoop
//
//  Created by Arek on 08.02.2017.
//  Copyright © 2017 Arek. All rights reserved.
//

import Foundation
import UIKit


class FilesRepository : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL")
        }
        
        // we know that cell is not empty now so we use ! to force unwrapping but you could also define cell as
        // let cell = (tableView.dequeue... as? UITableViewCell) ?? UITableViewCell(style: ...)
        
        cell!.textLabel?.text = "Baking Soda"
        cell!.detailTextLabel?.text = "1/2 cup"
        
        cell!.textLabel?.text = "Hello World"
        
        return cell!
    }
    
}
