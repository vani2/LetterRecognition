//
//  ComposeViewController.swift
//  LetterComposer
//
//  Created by Ivan Vavilov on 24.11.2019.
//  Copyright © 2019 Ivan Vavilov. All rights reserved.
//

import UIKit
import PencilKit
import Zip

final class ComposeViewController: CanvasViewController {

    @IBOutlet var letterLabel: UILabel!
    
    private let alphabet: [Character] = ["А", "Б", "В", "Г", "Д", "Е", "Ж", "З", "И", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Ы", "Э", "Ю", "Я"]
    private var position = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        letterLabel.text = String(alphabet[position])
        view.bringSubviewToFront(letterLabel)
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
    
    @IBAction func createZipAndShare(_ sender: Any) {
        zipAndShare()
    }
    
    private func cleanCanvasAndSaveImage() {
        guard let data = preprocessImage().pngData() else { return }
        
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
        } catch {
            print("\(error)")
            return
        }
        
        if !FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil) {
            print("Can't save image")
        }
        
        cleanCanvas()
    }
    
    private func zipAndShare() {
        guard let url = createZip() else { return }
        shareZip(url)
    }
    
    private func createZip() -> URL? {
        do {
            let url = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            return try Zip.quickZipFiles(urls, fileName: "LettersRawData")
        } catch {
            print("\(error)")
            return nil
        }
    }
    
    private func shareZip(_ url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
