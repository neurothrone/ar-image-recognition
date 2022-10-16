//
//  ContentView.swift
//  ARImageRecognition
//
//  Created by Zaid Neurothrone on 2022-10-16.
//

import AVFoundation
import Combine
import RealityKit
import SwiftUI

struct ContentView : View {
  var body: some View {
    ARViewContainer().edgesIgnoringSafeArea(.all)
  }
}

class Coordinator {
  var arView: ARView?
  var cancellable: AnyCancellable?
  
  func setUpUI() {
    // NOTE: You have to use the same image on a second device. Once detected it will render the objects
    imageDetection()
//    videoDetection()
  }
  
  private func videoDetection() {
    guard let arView = arView else { return }
    guard let videoURL = Bundle.main.url(forResource: "power-puff-girls", withExtension: "mp4")
    else { fatalError("❌ -> Failed to load video") }
    
    let player = AVPlayer(url: videoURL)
    let videoMaterial = VideoMaterial(avPlayer: player)
    
    let anchor = AnchorEntity(.image(group: "AR Resources", name: "green"))
    
    let plane = ModelEntity(mesh: .generatePlane(width: 0.5, depth: 0.5), materials: [videoMaterial])
    
    // Rotation by 90 degrees
    plane.orientation = simd.simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
    anchor.addChild(plane)
    arView.scene.addAnchor(anchor)
    
    player.play()
  }
  
  private func imageDetection() {
    guard let arView = arView else { return }
    
    let anchor = AnchorEntity(.image(group: "AR Resources", name: "green"))
    
    cancellable = ModelEntity.loadAsync(named: "toy_drummer")
      .sink { completion in
        if case let .failure(error) = completion {
          print("❌ -> Failed to load model. Error: \(error)")
        }
      } receiveValue: { entity in
        entity.scale = [0.05, 0.05, 0.05]
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
      }
  }
}

struct ARViewContainer: UIViewRepresentable {
  func makeUIView(context: Context) -> ARView {
    let arView = ARView(frame: .zero)
    context.coordinator.arView = arView
    context.coordinator.setUpUI()
    return arView
  }
  
  func makeCoordinator() -> Coordinator {
    .init()
  }
  
  func updateUIView(_ uiView: ARView, context: Context) {}
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
