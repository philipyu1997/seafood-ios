//
//  ViewController.swift
//  SeaFood
//
//  Created by Philip Yu on 7/11/19.
//  Copyright © 2019 Philip Yu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set class as delegate
        imagePicker.delegate = self
        
    }
    
    // MARK: - IBAction Section

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.allowsEditing = false
        
        // Present camera, if available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            imagePicker.sourceType = .camera
            
            // Present photo library
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            imagePicker.sourceType = .photoLibrary
            // Present imagePicker source type (either camera or library)
        }
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK: - Private Function Section
    
    private func detect(image: CIImage) {
        
        // Creates model using the Inception V3 model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        // Processes the image using our model
        let request = VNCoreMLRequest(model: model) { (request, _) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                    self.navigationController?.navigationBar.barTintColor = .green
                    self.navigationController?.navigationBar.tintColor = .white
                } else {
                    self.navigationItem.title = "Not Hotdog!" // nav bar title
                    self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white] // nav bar title text color
                    self.navigationController?.navigationBar.barTintColor = .red // nav bar color
                    self.navigationController?.navigationBar.tintColor = .white // nav bar buttons
                }
            }
        }
        
        // Handles the User request
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate Section
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage.")
            }

            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
}
