//
//  TranscriptRepresentation.swift
//  Vocable
//
//  Created by Jesse Ruiz on 4/30/20.
//  Copyright © 2020 Jesse Ruiz. All rights reserved.
//

import Foundation

struct TranscriptRepresentation: Codable {
    let title: String
    let text: String
    let createdAt: Date
    let transcriptID: UUID
}
