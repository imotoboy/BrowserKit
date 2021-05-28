//
//  Book+CoreDataProperties.swift
//  BrowserKit
//
//  Created by tramp on 2021/5/28.
//
//

import Foundation
import CoreData


extension Book {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }
    
    @NSManaged public var contents: String
    @NSManaged public var uniqueID: String
    @NSManaged public var location: String
    @NSManaged public var modified: Date
    @NSManaged public var chapters: Set<Chapter>
    
}

// MARK: Generated accessors for chapters
extension Book {
    
    @objc(addChaptersObject:)
    @NSManaged public func addToChapters(_ value: Chapter)
    
    @objc(removeChaptersObject:)
    @NSManaged public func removeFromChapters(_ value: Chapter)
    
    @objc(addChapters:)
    @NSManaged public func addToChapters(_ values: Set<Chapter>)
    
    @objc(removeChapters:)
    @NSManaged public func removeFromChapters(_ values: Set<Chapter>)
    
}
