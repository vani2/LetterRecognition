//
//  CanvasViewController.swift
//  LetterComposer
//
//  Created by Ivan Vavilov on 25.11.2019.
//  Copyright © 2019 Ivan Vavilov. All rights reserved.
//

import UIKit
import PencilKit

class CanvasViewController: UIViewController {

    let canvasView = PKCanvasView(frame: .zero)
    
    private let trainedImageSize = CGSize(width: 28, height: 28)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard
            let window = view.window,
            let toolPicker = PKToolPicker.shared(for: window)
        else { return }

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    func preprocessImage() -> UIImage {
        let image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 10.0)
        if let newImage = UIImage(color: .systemBackground, size: view.frame.size),
            let overlayedImage = newImage.image(
                byDrawingImage: image,
                inRect: CGRect(
                    x: view.center.x,
                    y: view.center.y,
                    width: view.frame.width,
                    height: view.frame.height)) {
            return overlayedImage.resize(newSize: trainedImageSize)
        } else {
            return image.resize(newSize: trainedImageSize)
        }
    }
    
    func cleanCanvas() {
        canvasView.drawing = PKDrawing()
    }

}
