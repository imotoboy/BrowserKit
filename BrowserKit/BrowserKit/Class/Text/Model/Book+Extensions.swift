//
//  Book+Extensions.swift
//  BrowserKit
//
//  Created by tramp on 2021/5/28.
//

import Foundation
import CoreData

extension Book {
    
    /// Abstract
    internal struct Abstract {
        internal let objectID: NSManagedObjectID
        internal let uniqueID: String
        internal let contents: String
        internal let location: String
        internal let modified: Date
        internal let chapters: Set<Chapter.Abstract>
    }
    
    internal var abstract: Abstract {
        let chapters = Set(chapters.map { $0.abstract })
        return .init(objectID: objectID, uniqueID: uniqueID, contents: contents,
                     location: location, modified: modified, chapters: chapters)
    }
}
