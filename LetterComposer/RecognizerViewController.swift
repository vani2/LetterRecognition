//
//  RecognizerViewController.swift
//  LetterComposer
//
//  Created by Ivan Vavilov on 25.11.2019.
//  Copyright © 2019 Ivan Vavilov. All rights reserved.
//

import UIKit
import CoreML

final class RecognizerViewController: CanvasViewController {
    
    @IBAction func detectLetter(_ sender: Any) {
        guard let pixelBuffer = preprocessImage().toCVPixelBuffer() else { return }
        
        let letter: String
        do {
            letter = try LetterClassifier().prediction(image: pixelBuffer).classLabel
        } catch {
            print("\(error)")
            return
        }
        
        let alert = UIAlertController(title: letter, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    @IBAction func clean(_ sender: Any) {
        cleanCanvas()
    }
    
}
