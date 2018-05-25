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
    
    @IBOutlet weak var planeButton: UIButton!
    @IBOutlet weak var imageRecognition: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        setupSession(plane: planeType)

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
        }
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    @IBAction func imageRecognitionPressed(_ sender: Any) {
        
        if planeType != planeDetection.image {
            planeType = planeDetection.image
            setupSession(plane: planeType)
            return
        } else {
            planeType = planeDetection.image
            setupSession(plane: planeType)
        }
        
    }
    
    
    @IBAction func planeButtonPressed(_ sender: Any) {
        
       
        if planeType == planeDetection.horizontal {
            planeType = planeDetection.vertical
            setupSession(plane: planeType)
            return
        } else {
            planeButton.titleLabel?.text = "Orizonatal"
            planeType = planeDetection.horizontal
            setupSession(plane: planeType)
            return
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
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
            
            guard let imageAnchor = anchor as? ARImageAnchor else { return }
            let referenceImage = imageAnchor.referenceImage
            
            let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
            plane.materials.first?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
        }
        
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
         if planeType == planeDetection.image {
            
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
    
}

