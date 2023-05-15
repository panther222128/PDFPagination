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
    var currentPageIndex: Int { get }
    
    func didLoadInitialPage()
    func didMoveNextPage()
    func didMovePreviousPage()
}

final class DefaultPDFViewModel: PDFViewModel {
    
    private(set) var currentPage: PassthroughSubject<PDFPage, Never>
    private(set) var currentPageIndex: Int
    private(set) var pdfDocument: PDFDocument
    private let lastPageIndex: Int
    
    init(pdf: PDF) {
        self.currentPage = PassthroughSubject()
        self.currentPageIndex = pdf.firstPageIndex
        self.pdfDocument = pdf.pdfDocument
        self.lastPageIndex = pdf.lastPageIndex
    }
    
    func didLoadInitialPage() {
        currentPage.send(pdfDocument.page(at: currentPageIndex) ?? PDFPage())
    }
    
    func didMoveNextPage() {
        if lastPageIndex > currentPageIndex {
            currentPageIndex += 1
            currentPage.send(pdfDocument.page(at: currentPageIndex) ?? PDFPage())
        }
    }
    
    func didMovePreviousPage() {
        if currentPageIndex > 0 && lastPageIndex >= currentPageIndex {
            currentPageIndex -= 1
            currentPage.send(pdfDocument.page(at: currentPageIndex) ?? PDFPage())
        }
    }
    
}

