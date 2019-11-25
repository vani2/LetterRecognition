//
//  ViewController.swift
//  LetterComposer
//
//  Created by Ivan Vavilov on 24.11.2019.
//  Copyright © 2019 Ivan Vavilov. All rights reserved.
//

import UIKit
import PencilKit
import Zip

final class ViewController: UIViewController {

    @IBOutlet var letterLabel: UILabel!
    
    private let canvasView = PKCanvasView(frame: .zero)
    private let trainedImageSize = CGSize(width: 28, height: 28)
    private let alphabet: [Character] = ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"]
    private var position = 0
    
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
        
        letterLabel.text = String(alphabet[0])
        view.bringSubviewToFront(letterLabel)
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
    
    @IBAction func repeatLetter(_ sender: Any) {
        cleanCanvasAndSaveImage()
    }
    
    @IBAction func nextLetter(_ sender: Any) {
        cleanCanvasAndSaveImage()
        position += 1
        guard position < alphabet.count else {
            zipAndShare()
            return
        }
        letterLabel.text = String(alphabet[position])
    }
    
    private func cleanCanvasAndSaveImage() {
        guard let data = preprocessImage().resize(newSize: trainedImageSize)?.pngData() else { return }
        
        var url: URL
        
        do {
            url = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            url.appendPathComponent(String(alphabet[position]))
            if !FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            }
            url.appendPathComponent("\(UUID().uuidString).png")
        } catch  {
            print("\(error)")
            return
        }
        
        if !FileManager.default.createFile(
            atPath: url.path,
            contents: data,
            attributes: nil) {
            print("Can't save image")
        }
        
        canvasView.drawing = PKDrawing()
    }
    
    private func preprocessImage() -> UIImage {
        let image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 10.0)
        if let newImage = UIImage(color: .systemBackground, size: view.frame.size),
            let overlayedImage = newImage.image(
                byDrawingImage: image,
                inRect: CGRect(
                    x: view.center.x,
                    y: view.center.y,
                    width: view.frame.width,
                    height: view.frame.height)) {
            return overlayedImage
        } else {
            return image
        }
    }
    
    private func zipAndShare() {
        let zipURL: URL
        let urls: [URL]
        do {
            let url = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            zipURL = try Zip.quickZipFiles(urls, fileName: "LettersRawData")
        } catch {
            print("\(error)")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [zipURL], applicationActivities: nil)
        present(activityVC, animated: true) {
            for url in urls {
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
}
