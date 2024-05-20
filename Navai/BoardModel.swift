//
//  BoardModel.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 30/04/24.
//

import Foundation
import UIKit

class BoardModel {
    
    var id: UUID
    var items: Data?
    
    init(_id: UUID,
         _items: Data?) {
        self.id = _id
        self.items = _items
    }
    
}

