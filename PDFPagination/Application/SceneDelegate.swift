//
//  SceneDelegate.swift
//  PDFPagination
//
//  Created by Jun Ho JANG on 2023/05/15.
//

import UIKit
import PDFKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        
        window?.rootViewController = navigationController
        
        do {
            let pdf = try loadPDFFile()
            guard let pdf = pdf else { return }
            let viewModel = DefaultPDFViewModel(pdf: pdf)
            let pdfViewController = PDFViewController.create(with: viewModel)
            navigationController.pushViewController(pdfViewController, animated: true)
        } catch {
            print("Cannot load pdf file")
        }
        
        window?.makeKeyAndVisible()
    }

}

enum PDFDataError: Error {
    case cannotLoadPDFFile
}

extension SceneDelegate {
    private func loadPDFFile() throws -> PDF? {
        if let path = Bundle.main.path(forResource: "roadmap", ofType: "pdf") {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                guard let pdfDocument = PDFDocument(data: data) else { return nil }
                let pdf = PDF(pdfDocument: pdfDocument, firstPageIndex: 0, lastPageIndex: pdfDocument.pageCount - 1)
                return pdf
            } catch {
                throw PDFDataError.cannotLoadPDFFile
            }
        } else {
            return nil
        }
    }
}
