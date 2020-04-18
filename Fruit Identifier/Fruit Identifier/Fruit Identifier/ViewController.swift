//
//  ViewController.swift
//  Fruit Identifier
//
//  Created by MacBook Pro Retina on 18/4/20.
//  Copyright © 2020 Arnab Ahamed Siam. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var testImage: UIImage!
    lazy var detectImageRequest: VNCoreMLRequest = {
        let fruitDetectModel = try! VNCoreMLModel(for: FruitImageClassifier().model)
        let fruitDetectRequest = VNCoreMLRequest(model: fruitDetectModel) {
            [unowned self]request, _ in
            self.processingResult(for: request)
        }
        fruitDetectRequest.imageCropAndScaleOption = .centerCrop
        return fruitDetectRequest
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    
    
    
    @IBAction func uploadImage(_ sender: Any){
        
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imageController.allowsEditing = false
        
        self.present(imageController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        testImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        imageView.image = testImage
        identifyImage(testImage: testImage)
    }
    
    func identifyImage(testImage: UIImage){
        
        DispatchQueue.global(qos: .userInitiated).async {
            let ciImage = CIImage(image: testImage)!
            let imageOrientation = CGImagePropertyOrientation(rawValue: UInt32(testImage.imageOrientation.rawValue))!
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: imageOrientation)
            try! handler.perform([self.detectImageRequest])
        }
    }
    
    func processingResult(for request: VNRequest) {
        
        DispatchQueue.main.async {
            let results = (request.results! as! [VNClassificationObservation]).prefix(2)
            self.labelView.text = results.map {
                result in
//                let formatter = NumberFormatter()
//                formatter.maximumFractionDigits = 1
//                let percentage = formatter.string(from: result.confidence*100 as NSNumber)!
                return "\(result.identifier)"
            }.joined(separator: "\n")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

