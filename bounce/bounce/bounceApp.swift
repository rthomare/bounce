//  Created by Rohan Thomare on 12/23/24.

import SwiftUI
import UIKit

@main
struct bounceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
        }
    }
}
