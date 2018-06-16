//
//  ViewController.swift
//  Digit Recognizer
//
//  Created by Srikumar Sastry on 15/06/18.
//  Copyright © 2018 Srikumar Sastry. All rights reserved.
//

import UIKit
import Vision
import Foundation

class ViewController: UIViewController {

    var requests = [VNRequest]()
    
    @IBOutlet weak var canvasView: CanvasView!
    
    @IBOutlet weak var digitLabel: UILabel!
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.clearCanvas()
    }
    
    @IBAction func recognizeDigit(_ sender: Any) {
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        do{
            try imageRequestHandler.perform(self.requests)
            
        }catch{
            print(error)
        }
        
    }
    
    func scaleImage (image:UIImage, toSize size:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
    }
    
    func setupVision(){
        if let visionModel = try? VNCoreMLModel(for: MNIST().model){
            let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
            self.requests = [classificationRequest]
        } else {fatalError("Error")}
    }
    
    func handleClassification(request: VNRequest, error:Error?){
        if let observations = request.results {
            let classifications = observations.compactMap({$0 as? VNClassificationObservation}).filter({$0.confidence > 0.8}).map({$0.identifier})
            DispatchQueue.main.async {
                self.digitLabel.text = classifications.first
            }
        } else{print("No results");return;}
    }


}

