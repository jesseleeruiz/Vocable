//
//  TranscriptController.swift
//  Vocable
//
//  Created by Jesse Ruiz on 4/30/20.
//  Copyright © 2020 Jesse Ruiz. All rights reserved.
//

import UIKit
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class TranscriptController {
    
    let baseURL = URL(string: "https://aligned-recordings.firebaseio.com/")!
    
    init() {
        fetchTranscriptsFromServer()
    }
    
    func fetchTranscriptsFromServer(completion: @escaping () -> Void = { }) {
        let requestURL = baseURL.appendingPathExtension("json")
        let request = URLRequest(url: requestURL)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion()
                return
            }
            
            guard let data = data else {
                NSLog("No data return from entry fetch data task")
                completion()
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let transcripts = try decoder.decode([String: TranscriptRepresentation].self, from: data).map({ $0.value })
                self.updateEntries(with: transcripts)
            } catch {
                NSLog("Error decoding TranscriptRepresentations: \(error)")
            }
            completion()
        }.resume()
    }
    
    func updateEntries(with representations: [TranscriptRepresentation]) {
        
        let identifiersToFetch = representations.map({ $0.transcriptID })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var transcriptsToCreate = representationsByID
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                let fetchRequest: NSFetchRequest<Transcript> = Transcript.fetchRequest()
                
                fetchRequest.predicate = NSPredicate(format: "transcriptID IN %@", identifiersToFetch)
                
                let existingTranscripts = try context.fetch(fetchRequest)
                for transcript in existingTranscripts {
                    guard let transcriptID = transcript.transcriptID,
                        let representation = representationsByID[transcriptID] else { continue }
                    transcript.title = representation.title
                    transcript.text = representation.text
                    transcript.createdAt = representation.createdAt
                    transcript.transcriptID = representation.transcriptID
                    transcriptsToCreate.removeValue(forKey: transcriptID)
                }
                for representation in transcriptsToCreate.values {
                    Transcript(transcriptRepresentation: representation, context: context)
                }
                CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error fetching transcripts from persistent store: \(error)")
            }
        }
    }
    
    func put(transcript: Transcript, completion: @escaping () -> Void = { }) {
        let transcriptID = transcript.transcriptID ?? UUID()
        transcript.transcriptID = transcriptID
        
        let requestURL = baseURL
            .appendingPathComponent(transcriptID.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let transcriptRepresentation = transcript.transcriptRepresentation else {
            NSLog("Transcript Representation is nil")
            completion()
            return
        }
        do {
            request.httpBody = try JSONEncoder().encode(transcriptRepresentation)
        } catch {
            NSLog("Error encoding transcript representation: \(error)")
            completion()
            return
        }
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting task: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    func deleteTranscriptFromServer(transcript: Transcript, completion: @escaping () -> Void = { }) {
        let transcriptID = transcript.transcriptID ?? UUID()
        transcript.transcriptID = transcriptID
        
        let requestURL = baseURL
            .appendingPathComponent(transcriptID.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error DELETEing transcript: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    func createTranscript(with title: String, text: String, context: NSManagedObjectContext) {
        let transcript = Transcript(title: title, text: text)
        CoreDataStack.shared.save(context: context)
        put(transcript: transcript)
    }
    
    func deleteTranscript(transcript: Transcript, context: NSManagedObjectContext) {
        CoreDataStack.shared.mainContext.delete(transcript)
        deleteTranscriptFromServer(transcript: transcript)
        CoreDataStack.shared.save(context: context)
    }
}
