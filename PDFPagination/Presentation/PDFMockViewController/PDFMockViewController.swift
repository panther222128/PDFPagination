//
//  PDFMockViewController.swift
//  PDFPagination
//
//  Created by Jun Ho JANG on 2023/05/26.
//

import UIKit
import PDFKit
import PencilKit
import Combine

final class PDFMockViewController: UIViewController, UIScrollViewDelegate, StoryboardInstantiable {
    
    private var viewModel: PDFViewModel!
    
    private var pdfView: PDFView! = PDFView()
    private var canvasView: PKCanvasView! = PKCanvasView()
    private var scrollView: UIScrollView! = UIScrollView()
    private var cancellable: Set<AnyCancellable> = Set([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeCurrentPage()
        
        viewModel.didLoadInitialPage()
        setupPDFView()
        setupCanvasView()
        setupScrollView()
    }
    
    static func create(with viewModel: PDFViewModel) -> PDFMockViewController {
        let viewController = PDFMockViewController.instantiateViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func setupPDFView() {
        pdfView = PDFView(frame: view.bounds)
        view.addSubview(pdfView)
    }
    
    private func setupCanvasView() {
        guard let documentView = pdfView.documentView else { return }
        documentView.addSubview(canvasView)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.delegate = self
        scrollView.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        pdfView.heightAnchor.constraint(equalToConstant: scrollView.frame.height).isActive = true
        pdfView.widthAnchor.constraint(equalToConstant: scrollView.frame.width).isActive = true
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.maximumZoomScale = maximumZoomScaleForViews()
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        
        scrollView.backgroundColor = .clear
    }
    
    private func maximumZoomScaleForViews() -> CGFloat {
        let pdfViewScale = pdfView.scaleFactorForSizeToFit
        let canvasViewScale = canvasView.maximumZoomScale
        pdfView.displayMode = .singlePage
        return max(pdfViewScale, canvasViewScale)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    private func move(to page: PDFPage) {
        pdfView.document = page.document
        pdfView.go(to: page)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let documentView = pdfView.documentView else { return }
        
        documentView.addSubview(canvasView)
        
        canvasView.zoomScale = 1.0
        canvasView.maximumZoomScale = 5.0
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        
        canvasView.frame = pdfView.documentView?.frame ?? CGRect()
        
        pdfView.backgroundColor = .clear
    }
    
}

extension PDFMockViewController {
    private func subscribeCurrentPage() {
        viewModel.currentPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] page in
                self?.move(to: page)
            }
            .store(in: &cancellable)
    }
}
