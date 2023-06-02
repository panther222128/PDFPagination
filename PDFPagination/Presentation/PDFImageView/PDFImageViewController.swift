//
//  PDFViewController.swift
//  PDFPagination
//
//  Created by Jun Ho JANG on 2023/05/15.
//

import UIKit
import PDFKit
import Combine

final class PDFImageViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var pdfImageView: UIImageView!
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    
    private var cancellable: Set<AnyCancellable> = Set([])
    private var viewModel: PDFViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previousPageButton.setTitle("-1", for: .normal)
        nextPageButton.setTitle("+1", for: .normal)
        
        subscribeCurrentPage()
        viewModel.didLoadInitialPage()
    }
    
    static func create(with viewModel: PDFViewModel) -> PDFImageViewController {
        let viewController = PDFImageViewController.instantiateViewController()
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
    
    private func move(to page: PDFPage) {
        let pageSize = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageSize.size)
        let image = renderer.image { context in
            context.cgContext.saveGState()
            context.cgContext.translateBy(x: 0, y: pageSize.size.height)
            context.cgContext.scaleBy(x: 1, y: -1)
            page.draw(with: .mediaBox, to: context.cgContext)
            context.cgContext.restoreGState()
        }

        pdfImageView.image = image
        pdfImageView.frame = CGRect(origin: .zero, size: pageSize.size)
    }
    
    @IBAction func previousPageButtonAction(_ sender: Any) {
        viewModel.didMovePreviousPage(in: .portrait)
    }
    
    @IBAction func nextPageButtonAction(_ sender: Any) {
        viewModel.didMoveNextPage(in: .portrait)
    }
    
}

extension PDFImageViewController {
    private func subscribeCurrentPage() {
        viewModel.currentPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] page in
                self?.move(to: page)
            }
            .store(in: &cancellable)
    }
}
