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
            let createdAt = createdAt,
            let transcriptID = transcriptID else { return nil }
        return TranscriptRepresentation(title: title, text: text, createdAt: createdAt, transcriptID: transcriptID)
    }
    
    @discardableResult convenience init(title: String,
                                        text: String,
                                        createdAt: Date = NSDate.init(timeIntervalSince1970: 0) as Date,
                                        transcriptID: UUID = UUID(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.text = text
        self.createdAt = createdAt
        self.transcriptID = transcriptID
    }
    
    @discardableResult convenience init?(transcriptRepresentation: TranscriptRepresentation, context: NSManagedObjectContext) {
        self.init(title: transcriptRepresentation.title,
                  text: transcriptRepresentation.text,
                  createdAt: transcriptRepresentation.createdAt,
                  transcriptID: transcriptRepresentation.transcriptID,
                  context: context)
    }
}
