//
//  ViewController.swift
//  Remember
//
//  Created by Daniel Duan on 1/7/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

// ARKIT
import UIKit
import SceneKit
import ARKit

// COREML
import CoreML
import Vision

// SCLALERTVIEW
import SCLAlertView

class ARViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    // CoreML variables
    var mostAccurateResult = ""
    let serialQueue = DispatchQueue(label: "serialQueue")
    var requests = [VNRequest]()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.autoenablesDefaultLighting = true
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        // Vision Model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading Core ML Model Failed.")
        }
        // Vision-CoreML Request
        let request = VNCoreMLRequest(model: model, completionHandler: classificationCompletionHandler)
        request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        requests = [request]
        coreMLLoop()
        
        
    }
    
    //MARK: - CoreML + Vision Methods
    
    func classificationCompletionHandler(request: VNRequest, error: Error?) {
        // Error present
        if error != nil {
            return
        }
        guard let results = request.results else {
            return
        }
        
        let predictions = results[0...1]
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        // store the most accurate result
        DispatchQueue.main.async {
            var object = predictions.components(separatedBy: "-")[0]
            object = object.components(separatedBy: ",")[0]
            self.mostAccurateResult = object
        }
        
    }
    
    // continuously update CoreML
    func coreMLLoop() {
        serialQueue.async {
            self.updateML()
            self.coreMLLoop()
        }
    }
    
    func updateML() {
        guard let pixelBuffer: CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage) else {
            return
        }
        
        let ciimage = CIImage(cvPixelBuffer: pixelBuffer!)
        let handler = VNImageRequestHandler(ciImage: ciimage, options: [:])
        do {
            try handler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    //MARK: - AR Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //TODO: Refactor Code
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            let results = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = results.first {
                // delete all previous nodes before creating the new textNode
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
                }
                
                create3DText(at: hitResult)
                // alert view
                createAlertView()
            }
            
        }
    }
    
    func create3DText(at hitResult: ARHitTestResult) {
        let textGeometry = SCNText(string: mostAccurateResult, extrusionDepth: 0.1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        let (minBound, maxBound) = textGeometry.boundingBox


        let textNode = SCNNode(geometry: textGeometry)
        textNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, Float(textGeometry.extrusionDepth/2))
        //TODO: Make 3D Text easier to read
        
        textNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        
//        let billboardConstraint = SCNBillboardConstraint()
//        billboardConstraint.freeAxes = SCNBillboardAxis.Z
//
//        sceneView.scene.rootNode.constraints = [billboardConstraint]
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    //MARK: - Create Pop Up
    func createAlertView() {
        let apperance = SCLAlertView.SCLAppearance(
            kDefaultShadowOpacity: 0.2,
            showCloseButton: true,
            showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: apperance)
        let alertViewIcon = UIImage(named: "camera_icon")
        alert.addButton("Take Photo") {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.showInfo(mostAccurateResult, subTitle: "Take a photo of the \(mostAccurateResult) and save it to your list of memories?", circleIconImage: alertViewIcon)
    }
    
    //MARK: - Setup methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        //TODO: Alert the user that their phone cannot support a true AR experience.
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // called when user presses "Use Photo"
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("picked image")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
}
