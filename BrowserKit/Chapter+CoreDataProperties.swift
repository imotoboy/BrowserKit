//
//  Chapter+CoreDataProperties.swift
//  BrowserKit
//
//  Created by tramp on 2021/5/28.
//
//

import Foundation
import CoreData


extension Chapter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chapter> {
        return NSFetchRequest<Chapter>(entityName: "Chapter")
    }

    @NSManaged public var contents: String
    @NSManaged public var title: String
    @NSManaged public var index: Int64
    @NSManaged public var book: Book
    @NSManaged public var pages: Set<Page>
    @NSManaged public var modified: Date

}

// MARK: Generated accessors for pages
extension Chapter {

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: Page)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: Page)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: Set<Page>)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: Set<Page>)

}
