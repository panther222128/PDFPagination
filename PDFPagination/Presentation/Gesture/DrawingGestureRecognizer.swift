//
//  DrawingGestureRecognizer.swift
//  PDFPagination
//
//  Created by Jun Ho JANG on 2023/05/31.
//

import UIKit

protocol DrawingGestureRecognizer: AnyObject {
    func gestureRecognizerBegan(_ location: CGPoint)
    func gestureRecognizerMoved(_ location: CGPoint)
    func gestureRecognizerEnded(_ location: CGPoint)
}

final class DefaultDrawingGestureRecognizer: UIGestureRecognizer {
    
    weak var drawingGestureRecognizer: DrawingGestureRecognizer?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, let numberOfTouches = event.allTouches?.count, numberOfTouches == 1 {
            state = .began
            let location = touch.location(in: self.view)
            drawingGestureRecognizer?.gestureRecognizerBegan(location)
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed
        
        guard let location = touches.first?.location(in: self.view) else { return }
        drawingGestureRecognizer?.gestureRecognizerMoved(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self.view) else {
            state = .ended
            return
        }
        drawingGestureRecognizer?.gestureRecognizerEnded(location)
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
    
}
