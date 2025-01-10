//  Created by Rohan Thomare on 12/27/24.

import UIKit
import SwiftUI

// A custom UIViewController for detecting shake gestures
class ShakeViewController: UIViewController {
    var onShake: (() -> Void)?
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
    }
}

struct ShakeDetector: UIViewControllerRepresentable {
    var onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let viewController = ShakeViewController()
        viewController.onShake = onShake
        return viewController
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {}
}
