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
        
        // SCENE
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        //IMAGE PICKER
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        // VISION
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading Core ML Model Failed.")
        }
        let request = VNCoreMLRequest(model: model, completionHandler: classificationCompletionHandler)
        request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        requests = [request]
        coreMLLoop()
        
    }
    
    //MARK: - COREML/VISION METHODS
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
    
    // continuously update CoreMl
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
    
    //MARK: - ARKIT METHODS
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            let results = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = results.first {
                // delete all previous nodes before creating the new textNode
                create3DText(at: hitResult)
                // create the alert pop up
                createAlertView()
            }
            
        }
    }
    
    func create3DText(at hitResult: ARHitTestResult) {
        
        // CONSTRAINTS
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // TEXT GEOMETRY
        let textGeometry = SCNText(string: mostAccurateResult, extrusionDepth: 0.01)
        var font = UIFont(name: "Futura", size: 0.15)
        // font = font?.bold()
        textGeometry.font = font
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        textGeometry.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.4549019608, green: 0.7490196078, blue: 0.8392156863, alpha: 1)
        textGeometry.firstMaterial?.isDoubleSided = true
        
        
        // NODE
        let (minBound, maxBound) = textGeometry.boundingBox
        let textNode = SCNNode(geometry: textGeometry)
        textNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, Float(textGeometry.extrusionDepth/2))
        textNode.scale = SCNVector3(0.2, 0.2, 0.2)
        
        // PARENT NODE
        let textNodeParent = SCNNode()
        textNodeParent.addChildNode(textNode)
        textNodeParent.constraints = [billboardConstraint]
        
        sceneView.scene.rootNode.addChildNode(textNodeParent)
        textNodeParent.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
    }
    
    //MARK: - SCLALERTVIEW FUNCTIONALITY
    func createAlertView() {
        let apperance = SCLAlertView.SCLAppearance(
            kDefaultShadowOpacity: 0.2,
            showCloseButton: false,
            showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: apperance)
        let alertViewIcon = UIImage(named: "camera_icon")
        alert.addButton("Take Photo") {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.addButton("Cancel") {
            print("cancel button tapped")
        }
        alert.showInfo(mostAccurateResult, subTitle: "Take a photo of the \(mostAccurateResult)and save it to your list of memories?", circleIconImage: alertViewIcon)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // called when user presses "Use Photo"
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let newMemory = Memory(objectName: mostAccurateResult, imageOfObject: userPickedImage)
            
            // passed data to MemoriesTableViewController
            let navController = self.tabBarController!.viewControllers![1] as! UINavigationController
            let vc = navController.topViewController as! MemoriesTableViewController
            vc.memoriesArray.append(newMemory)

        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    //MARK: - SETUP METHODS
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        //TODO: Alert the user that their phone cannot support a true AR experience.
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
