//
//  Chapter+Extensions.swift
//  BrowserKit
//
//  Created by tramp on 2021/5/28.
//

import Foundation
import CoreData

extension Chapter {
    
    /// Abstract
    internal struct Abstract: Hashable {
        internal let bookID: NSManagedObjectID
        internal let objectID: NSManagedObjectID
        internal let contents: String
        internal let title: String
        internal let index: Int64
        internal let modified: Date
        internal let pages: Set<Page.Abstract>
        
    }
    
    /// Abstract
    internal var abstract: Abstract {
        let abstracts = Set(pages.map { $0.abstract })
        return .init(bookID: book.objectID, objectID: objectID, contents: contents,
                     title: title, index: index, modified: modified, pages: abstracts)
    }
}
