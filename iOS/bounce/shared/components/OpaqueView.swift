//
//  OpaqueView.swift
//  bounce
//
//  Created by Rohan Thomare on 10/26/25.
//

import SwiftUI

struct OpaqueView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let opaqueEffect = UIGlassEffect(style: .regular)
        let opaqueView = UIVisualEffectView(effect: opaqueEffect)
        return opaqueView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // No updates needed
    }
}
