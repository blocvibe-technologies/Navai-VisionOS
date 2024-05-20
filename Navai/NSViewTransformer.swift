//
//  NSViewTransformer.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 01/05/24.
//

import Foundation
import UIKit


class NSViewTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let color = value as? NSData else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            return nil
        }
        
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: data)
            return color
        } catch {
            return nil
        }
    }
    
}
