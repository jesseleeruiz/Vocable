//
//  Transcript+Convenience.swift
//  Vocable
//
//  Created by Jesse Ruiz on 4/30/20.
//  Copyright © 2020 Jesse Ruiz. All rights reserved.
//

import Foundation
import CoreData

extension Transcript {
    var transcriptRepresentation: TranscriptRepresentation? {
        guard let title = title,
            let text = text,
            let createdAt = createdAt else { return nil }
        return TranscriptRepresentation(title: title, text: text, createdAt: createdAt)
    }
    
    @discardableResult convenience init(title: String,
                                        text: String,
                                        createdAt: Date = Date(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.text = text
        self.createdAt = createdAt
    }
    
    @discardableResult convenience init?(transcriptRepresentation: TranscriptRepresentation, context: NSManagedObjectContext) {
        self.init(title: transcriptRepresentation.title,
                  text: transcriptRepresentation.text,
                  createdAt: transcriptRepresentation.createdAt,
                  context: context)
    }
}
