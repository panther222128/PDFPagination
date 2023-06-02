//
//  PDFViewController.swift
//  PDFPagination
//
//  Created by Jun Ho JANG on 2023/05/17.
//

import UIKit
import PDFKit
import Combine
import PencilKit

enum MemoryWarning: Error {
    case memoryResources
}

final class PDFViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    
    private let toolPicker: PKToolPicker = PKToolPicker()
    
    private var viewModel: PDFViewModel!
    private var cancellable: Set<AnyCancellable> = Set([])
    var pageToViewMapping = [PDFPage: PKCanvasView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentOrientation = UIDevice.current.orientation
        changeDisplayMode(to: currentOrientation)
        subscribeCurrentPage()

        previousPageButton.setTitle("-1", for: .normal)
        nextPageButton.setTitle("+1", for: .normal)
        
        viewModel.didLoadInitialPage()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let currentOrientation = UIDevice.current.orientation
        changeDisplayMode(to: currentOrientation)
    }

    override func didReceiveMemoryWarning() {
        presentAlert(of: MemoryWarning.memoryResources)
    }
    
    static func create(with viewModel: PDFViewModel) -> PDFViewController {
        let viewController = PDFViewController.instantiateViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func presentAlert(of error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error Occured", message: "\(error)", preferredStyle: UIAlertController.Style.alert)
            let addAlertAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(addAlertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func previousPageButtonAction(_ sender: Any) {
        let currentOrientation = UIDevice.current.orientation
        viewModel.didMovePreviousPage(in: currentOrientation)
    }
    
    @IBAction func nextPageButtonAction(_ sender: Any) {
        let currentOrientation = UIDevice.current.orientation
        viewModel.didMoveNextPage(in: currentOrientation)
    }

}

extension PDFViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let currentPage = pdfView.currentPage else { return }
        print(currentPage)
    }
}

extension PDFViewController {
    private func changeDisplayMode(to orientation: UIDeviceOrientation) {
        if orientation.isLandscape {
            pdfView.displayMode = .twoUp
        } else if orientation.isPortrait {
            pdfView.displayMode = .singlePage
        }
    }
    
    private func setupProperties(of pdfView: PDFView) {
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
        pdfView.delegate = self
        pdfView.pageOverlayViewProvider = self
        pdfView.document?.delegate = self
        pdfView.displaysPageBreaks = false
    }
    
    private func move(to page: PDFPage) {
        setupProperties(of: pdfView)
        pdfView.document = page.document
        pdfView.go(to: page)
    }
    
}

extension PDFViewController {
    private func subscribeCurrentPage() {
        viewModel.currentPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] page in
                self?.move(to: page)
                self?.setToolPicker()
            }
            .store(in: &cancellable)
    }
}

extension PDFViewController: PDFPageOverlayViewProvider, PDFViewDelegate, PDFDocumentDelegate, PKToolPickerObserver {
    
    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        var canvasView: PKCanvasView? = nil
        canvasView = PKCanvasView(frame: .zero)
        canvasView?.drawingPolicy = .anyInput
        canvasView?.backgroundColor = .clear
        pageToViewMapping[page] = canvasView
        
        pdfView.documentView?.subviews.forEach {
            $0.isUserInteractionEnabled = true
        }
        
        let page = page as? DrawablePDFPage
        if let drawing = page?.drawing {
            canvasView?.drawing = drawing
        }
        
        canvasView?.delegate = self
        
        toolPicker.setVisible(true, forFirstResponder: canvasView ?? PKCanvasView())
        toolPicker.addObserver(canvasView ?? PKCanvasView())
        canvasView?.becomeFirstResponder()
        
        return canvasView
    }
    
    func pdfView(_ pdfView: PDFView, willEndDisplayingOverlayView overlayView: UIView, for page: PDFPage) {
        guard let overlayView = overlayView as? PKCanvasView else { return }
        let page = page as? DrawablePDFPage
        page?.drawing = overlayView.drawing
        pageToViewMapping.removeValue(forKey: page ?? DrawablePDFPage())
    }
    
}
