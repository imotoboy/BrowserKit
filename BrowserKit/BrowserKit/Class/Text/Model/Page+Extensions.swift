//
//  Page+Extensions.swift
//  BrowserKit
//
//  Created by tramp on 2021/5/28.
//

import Foundation
import CoreData

extension Page {
    
    /// Abstract
    internal struct Abstract: Hashable {
        internal let chapterID: NSManagedObjectID
        internal let objectID: NSManagedObjectID
        internal let contents: String
        internal let index: Int64
    }
    
    /// Abstract
    internal var abstract: Abstract {
        return .init(chapterID: chapter.objectID, objectID: objectID, contents: contents, index: index)
    }
}

