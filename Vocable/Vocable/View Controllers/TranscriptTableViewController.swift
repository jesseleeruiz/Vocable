//
//  TranscriptTableViewController.swift
//  Vocable
//
//  Created by Jesse Ruiz on 4/30/20.
//  Copyright © 2020 Jesse Ruiz. All rights reserved.
//

import UIKit
import CoreData

class TranscriptTableViewController: UITableViewController {
    
    // MARK: - Properties
    let transcriptController = TranscriptController()
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    let timestamp = NSDate().timeIntervalSince1970
    
    lazy var fetchedResultsController: NSFetchedResultsController<Transcript> = {
        let fetchRequest: NSFetchRequest<Transcript> = Transcript.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: CoreDataStack.shared.mainContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for frc: \(error)")
        }
        return frc
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TranscriptCell", for: indexPath)
        
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).title
        
        let myTimeInterval = TimeInterval(timestamp)
        let date = Date(timeIntervalSince1970: myTimeInterval)
        cell.detailTextLabel?.text = "Created on \(dateFormatter.string(from: date))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transcript = fetchedResultsController.object(at: indexPath)
            transcriptController.deleteTranscript(transcript: transcript, context: CoreDataStack.shared.mainContext)
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTranscript" {
            if let addVC = segue.destination as? AddTranscriptViewController {
                addVC.transcriptController = transcriptController
            }
        } else if segue.identifier == "showTranscript" {
            if let detailVC = segue.destination as? ShowTranscriptViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                detailVC.transcript = fetchedResultsController.object(at: indexPath)
                detailVC.transcriptController = transcriptController
            }
        }
    }
}
    
    extension TranscriptTableViewController: NSFetchedResultsControllerDelegate {
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.beginUpdates()
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.endUpdates()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange anObject: Any,
                        at indexPath: IndexPath?,
                        for type: NSFetchedResultsChangeType,
                        newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
                tableView.insertRows(at: [newIndexPath], with: .fade)
            case .delete:
                guard let indexPath = indexPath else { return }
                tableView.deleteRows(at: [indexPath], with: .fade)
            case .move:
                guard let indexPath = indexPath,
                    let newIndexPath = newIndexPath else { return }
                tableView.moveRow(at: indexPath, to: newIndexPath)
            case .update:
                guard let indexPath = indexPath else { return }
                tableView.reloadRows(at: [indexPath], with: .fade)
            @unknown default:
                fatalError()
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange sectionInfo: NSFetchedResultsSectionInfo,
                        atSectionIndex sectionIndex: Int,
                        for type: NSFetchedResultsChangeType) {
            
            let indexSet = IndexSet(integer: sectionIndex)
            
            switch type {
            case .insert:
                tableView.insertSections(indexSet, with: .fade)
            case .delete:
                tableView.deleteSections(indexSet, with: .fade)
            default:
                return
            }
        }
}
