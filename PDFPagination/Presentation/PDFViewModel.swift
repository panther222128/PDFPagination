//
//  PDFViewModel.swift
//  PDFPagination
//
//  Created by Jun Ho JANG on 2023/05/15.
//

import Foundation
import Combine
import PDFKit

protocol PDFViewModel {
    var currentPage: PassthroughSubject<PDFPage, Never> { get }
    
    func didLoadInitialPage()
    func didMoveNextPage(in orientation: UIDeviceOrientation)
    func didMovePreviousPage(in orientation: UIDeviceOrientation)
}

final class DefaultPDFViewModel: PDFViewModel {
    
    private(set) var currentPage: PassthroughSubject<PDFPage, Never>
    private var currentPageIndex: Int {
        didSet {
            guard let page = pdfDocument.page(at: currentPageIndex) else { return }
            currentPage.send(page)
        }
    }
    private let pdfDocument: PDFDocument
    private let lastPageIndex: Int
    
    init(pdf: PDF) {
        self.currentPage = PassthroughSubject()
        self.pdfDocument = pdf.pdfDocument
        self.currentPageIndex = pdf.firstPageIndex
        self.lastPageIndex = pdf.lastPageIndex
    }
    
    func didLoadInitialPage() {
        currentPageIndex = 0
    }

    func didMovePreviousPage(in orientation: UIDeviceOrientation) {
        if currentPageIndex > 0 && lastPageIndex >= currentPageIndex {
            if orientation.isPortrait {
                currentPageIndex -= 1
            } else if orientation.isLandscape {
                currentPageIndex -= 2
            }
        }
    }
    
    func didMoveNextPage(in orientation: UIDeviceOrientation) {
        if lastPageIndex > currentPageIndex {
            if orientation.isPortrait {
                currentPageIndex += 1
            } else if orientation.isLandscape {
                currentPageIndex += 2
            }
        }
    }

}

