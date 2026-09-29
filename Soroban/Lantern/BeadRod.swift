import SceneKit
import SpriteKit
import SwiftUI

/// One SceneKit rod for the board. SpriteKit draws only the lantern on the lit bead.
struct BeadRod: UIViewRepresentable {
    var count: Int
    var litIndex: Int
    var rowHeight: CGFloat

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        let scene = SCNScene()
        scene.background.contents = UIColor.clear
        view.scene = scene

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        cameraNode.camera = camera
        cameraNode.name = "camera"
        cameraNode.position = SCNVector3(0, 0, 8)
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 700
        ambient.name = "ambient"
        scene.rootNode.addChildNode(ambient)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = 900
        key.eulerAngles = SCNVector3(-0.6, 0.4, 0)
        key.name = "key"
        scene.rootNode.addChildNode(key)

        let overlay = SKScene(size: CGSize(width: BoardMetrics.beadColumn, height: rowHeight))
        overlay.backgroundColor = .clear
        overlay.scaleMode = .resizeFill
        view.overlaySKScene = overlay
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard let scene = view.scene else { return }
        scene.rootNode.childNodes.filter { $0.name == "bead" || $0.name == "rod" }.forEach { $0.removeFromParentNode() }

        let seats = max(count, 1)
        if let camera = scene.rootNode.childNode(withName: "camera", recursively: false)?.camera {
            camera.orthographicScale = Double(seats) * 0.5
        }

        if count > 0 {
            let rod = SCNCylinder(radius: 0.05, height: CGFloat(count))
            rod.firstMaterial?.diffuse.contents = UIColor(BoardColor.muted)
            let rodNode = SCNNode(geometry: rod)
            rodNode.name = "rod"
            scene.rootNode.addChildNode(rodNode)

            for index in 0..<count {
                let sphere = SCNSphere(radius: 0.32)
                let lit = index == litIndex
                sphere.firstMaterial?.diffuse.contents = UIColor(lit ? BoardColor.accent : BoardColor.surface)
                let node = SCNNode(geometry: sphere)
                node.name = "bead"
                let y = (Double(count - 1) / 2.0) - Double(index)
                node.position = SCNVector3(0, y, 0)
                scene.rootNode.addChildNode(node)
            }
        }

        let height = max(rowHeight * CGFloat(max(count, 1)), rowHeight)
        let overlay = view.overlaySKScene ?? SKScene(size: CGSize(width: BoardMetrics.beadColumn, height: height))
        overlay.backgroundColor = .clear
        overlay.scaleMode = .resizeFill
        overlay.size = CGSize(width: BoardMetrics.beadColumn, height: height)
        overlay.removeAllChildren()
        if count > 0, litIndex >= 0, litIndex < count {
            let lantern = SKShapeNode(circleOfRadius: 11)
            lantern.fillColor = UIColor(BoardColor.accent)
            lantern.strokeColor = UIColor(BoardColor.ink)
            lantern.lineWidth = 1
            lantern.position = CGPoint(
                x: BoardMetrics.beadColumn / 2,
                y: height - (CGFloat(litIndex) + 0.5) * rowHeight
            )
            overlay.addChild(lantern)
        }
        view.overlaySKScene = overlay
    }
}
