//
//  ShowTranscriptViewController.swift
//  Vocable
//
//  Created by Jesse Ruiz on 4/30/20.
//  Copyright © 2020 Jesse Ruiz. All rights reserved.
//

import UIKit

class ShowTranscriptViewController: UIViewController {
    
    // MARK: - Properties
    var transcript: Transcript? {
        didSet {
            updateViews()
        }
    }
    var transcriptController: TranscriptController?
    var transcriptRep: TranscriptRepresentation?
    
    // MARK: - Outlets
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        guard let title = self.title,
            let text = textView.text else { return }
        let pdfCreator = PDFCreator(title: title, text: text)
        let pdfData = pdfCreator.createPDF()
        let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - Methods
    private func updateViews() {
        guard isViewLoaded else { return }
    
        title = transcript?.title
        textView.text = transcript?.text
        textView.layer.borderColor = UIColor.systemGray2.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 4.0
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPreview" {
            guard let previewVC = segue.destination as? PreviewTranscriptViewController else { return }
            if let title = self.title,
                let text = textView.text {
                let pdfCreator = PDFCreator(title: title, text: text)
                previewVC.documentData = pdfCreator.createPDF()
            }
        }
    }
}
