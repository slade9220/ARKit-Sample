//
//  ViewController.swift
//  ARKit Sample
//
//  Created by Gennaro Amura on 24/05/18.
//  Copyright © 2018 Gennaro Amura. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var planeType = planeDetection.image
    var boolImgPlane = false
    
    @IBOutlet weak var horizontalPlane: UIButton!
    @IBOutlet weak var imageRecognition: UIButton!
    @IBOutlet weak var verticalPlane: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageRecognition.isHidden = true
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        setupSession(plane: planeType)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapGesture(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinchToZoom(gesture:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }
    
    
    func setupSession(plane: planeDetection) {
        
        let configuration = ARWorldTrackingConfiguration()
        
        if plane == planeDetection.horizontal {
            configuration.planeDetection = .horizontal
        }
        if plane == planeDetection.vertical {
            configuration.planeDetection = .vertical
        }
        if plane == planeDetection.image {
            guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
            configuration.detectionImages = referenceImages
            boolImgPlane = false
        }
        
        for child in sceneView.scene.rootNode.childNodes{
            child.removeFromParentNode()
        }
        if plane == planeDetection.none {
            sceneView.session.run(configuration)
        } else {
           sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
        
    }
    
    
    @IBAction func imageRecognitionPressed(_ sender: Any) {
        
        if planeType != planeDetection.image {
            planeType = planeDetection.image
            setupSession(plane: planeType)
            imageRecognition.isHidden = true
            verticalPlane.isHidden = false
            horizontalPlane.isHidden = false
            return
        }
        
    }

    @IBAction func planeButtonPressed(_ sender: Any) {

        if planeType != planeDetection.horizontal {
            planeType = planeDetection.horizontal
            setupSession(plane: planeType)
            imageRecognition.isHidden = false
            verticalPlane.isHidden = false
            horizontalPlane.isHidden = true
        }
        
    }
    
    @IBAction func verticalPlanePressed(_ sender: Any) {
        
        if planeType != planeDetection.vertical {
            planeType = planeDetection.vertical
            setupSession(plane: planeType)
            imageRecognition.isHidden = false
            verticalPlane.isHidden = true
            horizontalPlane.isHidden = false
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if planeType == planeDetection.none {
            return
        }
        
        if  planeType == planeDetection.horizontal {
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            plane.materials.first?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)
            
            let planeNode = SCNNode(geometry: plane)
            
            
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
        }
        if  planeType == planeDetection.vertical {
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            let width = CGFloat(planeAnchor.extent.z)
            let height = CGFloat(planeAnchor.extent.y)
            let plane = SCNPlane(width: width, height: height)
            
            plane.materials.first?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)
            
            
            let planeNode = SCNNode(geometry: plane)
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.y = .pi / 2
            planeNode.eulerAngles.z = .pi / 2
            print(planeNode)
            node.addChildNode(planeNode)
        }
        
        if planeType == planeDetection.image {
            if(boolImgPlane) {
                print("return")
                return
            }else{
                guard let imageAnchor = anchor as? ARImageAnchor else { return }
                let referenceImage = imageAnchor.referenceImage

                let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                     height: referenceImage.physicalSize.height)
                let planeNode = SCNNode(geometry: plane)
                planeNode.opacity = 0.25
                planeNode.eulerAngles.x = -.pi / 2
                
                node.addChildNode(planeNode)
            }
        }
        
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
         if planeType == planeDetection.image || planeType == planeDetection.none {
            
            return
            
         } else {
            
            guard let planeAnchor = anchor as?  ARPlaneAnchor,
                let planeNode = node.childNodes.first,
                let plane = planeNode.geometry as? SCNPlane
                else { return }
            
            if planeType == planeDetection.horizontal {
                let width = CGFloat(planeAnchor.extent.x)
                let height = CGFloat(planeAnchor.extent.z)
                plane.width = width
                plane.height = height
            }
            
            if planeType == planeDetection.vertical {
                let width = CGFloat(planeAnchor.extent.z)
                let height = CGFloat(planeAnchor.extent.y)
                plane.width = width
                plane.height = height
            }
            
            
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x, y, z)
        }

    }
    
    @objc func handleTapGesture(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        if planeType == planeDetection.none {
            return
        } else{
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let x = translation.x
            let y = translation.y
            let z = translation.z
            
            guard let shipScene = SCNScene(named: "art.scnassets/ship.scn"),
                let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
                else { return }
            
            
            planeType = planeDetection.none
            
            setupSession(plane: planeType)
            shipNode.position = SCNVector3(x,y,z)
            sceneView.scene.rootNode.addChildNode(shipNode)
        }
        
    }
    
    @objc func pinchToZoom(gesture:UIPinchGestureRecognizer) {
        if (gesture.state == .began || gesture.state == .changed) {
            guard let node = sceneView.scene.rootNode.childNodes.first else { return }
            node.scale = SCNVector3(gesture.scale,gesture.scale,gesture.scale)
            
        }
    }
    
}


extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

