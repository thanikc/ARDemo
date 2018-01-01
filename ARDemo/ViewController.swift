//
//  ViewController.swift
//  ARDemo
//
//  Created by Thanik Cheowtirakul on 26/12/17.
//  Copyright © 2017 Thanik Cheowtirakul. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum AnimationKey: String {
  case macacoSide
}

class ViewController: UIViewController, ARSCNViewDelegate {
  
  @IBOutlet var sceneView: ARSCNView!
  
  var animations = [String: CAAnimation]()
  var idle: Bool = true
  
  // Create a session configuration
  let configuration = ARWorldTrackingConfiguration()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    // Create a new scene
    let scene = SCNScene()
    
    // Set the scene to the view
    sceneView.scene = scene
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    
    // Load the DAE animations
    loadAnimations()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Run the view's session
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let location = touches.first!.location(in: sceneView)
    
    // Let's test if a 3D Object was touch
    var hitTestOptions = [SCNHitTestOption: Any]()
    hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
    
    let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
    
    if hitResults.first != nil {
      if(idle) {
        playAnimation(key: AnimationKey.macacoSide.rawValue)
      } else {
        stopAnimation(key: AnimationKey.macacoSide.rawValue)
      }
      idle = !idle
      return
    }
  }
  
  @IBAction func add(_ sender: Any) {
    resetScene()
    sceneView.session.pause()
    self.loadAnimations()
    sceneView.session.run(configuration)
  }
  
  func resetScene() {
    sceneView.session.pause()
    sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
      node.removeFromParentNode()
    }
    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
  
  // MARK: - ARSCNViewDelegate
  
  /*
   // Override to create and configure nodes for anchors added to the view's session.
   func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   let node = SCNNode()
   
   return node
   }
   */
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
  }
  
  // MARK: - Animations
  
  func loadAnimations () {
    // Load the character in the idle animation
    let idleScene = SCNScene(named: "art.scnassets/Idle.dae")!
    
    // This node will be parent of all the animation models
    let node = SCNNode()
    
    // Add all the child nodes to the parent node
    for child in idleScene.rootNode.childNodes {
      node.addChildNode(child)
    }
    
    // Set up some properties
    node.position = SCNVector3(0, -2, -3)
    node.scale = SCNVector3(0.01, 0.01, 0.01)
    
    // Add the node to the scene
    sceneView.scene.rootNode.addChildNode(node)
    
    // Load all the DAE animations
    loadAnimation(withKey: AnimationKey.macacoSide.rawValue, sceneName: "art.scnassets/MacacoSide", animationIdentifier: "MacacoSide-1")
  }
  
  func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
    let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
    let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
    
    if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
      // The animation will only play once
      animationObject.repeatCount = 1
      // To create smooth transitions between animations
      animationObject.fadeInDuration = CGFloat(1)
      animationObject.fadeOutDuration = CGFloat(0.5)
      
      // Store the animation for later use
      animations[withKey] = animationObject
    }
  }
  
  func playAnimation(key: String) {
    // Add the animation to start playing it right away
    sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
  }
  
  func stopAnimation(key: String) {
    // Stop the animation with a smooth transition
    sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
  }
  
}
