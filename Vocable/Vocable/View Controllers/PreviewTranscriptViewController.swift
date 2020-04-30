//
//  PreviewTranscriptViewController.swift
//  Vocable
//
//  Created by Jesse Ruiz on 4/30/20.
//  Copyright © 2020 Jesse Ruiz. All rights reserved.
//

import UIKit
import PDFKit

class PreviewTranscriptViewController: UIViewController {
    
    // MARK: - Properties
    public var documentData: Data?
    
    // MARK: - Outlets
    @IBOutlet weak var pdfView: PDFView!
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = documentData {
            pdfView.document = PDFDocument(data: data)
            pdfView.autoScales = true
        }
    }
    
}
