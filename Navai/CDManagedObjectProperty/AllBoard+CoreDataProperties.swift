//
//  AllBoard+CoreDataProperties.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 30/04/24.
//
//

import Foundation
import CoreData
import UIKit

extension AllBoard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AllBoard> {
        return NSFetchRequest<AllBoard>(entityName: "AllBoard")
    }

    @NSManaged public var items: Data?
    @NSManaged public var id: UUID?
    
    func convertToBoardItems() -> BoardModel {
        return BoardModel(_id: self.id!,
                          _items: self.items)
    }
    

}

extension AllBoard : Identifiable {

}
