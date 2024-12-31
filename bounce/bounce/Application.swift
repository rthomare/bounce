//  Created by Rohan Thomare on 12/23/24.

import SwiftUI
import UIKit

@main
struct Application: App {
    let appController = AppController.defaultFactory(
        onSongSelected: Application._handleSongGeneration,
        openURL: { url in
            UIApplication.shared.open(url)
        }
    )

    var body: some Scene {
        WindowGroup {
            BounceApp(appController).onAppear {
                appController.handle(action: .startCreation)
            }
        }
    }
    
    // MARK: Private Functions
    
    static private func _handleSongGeneration(_ song: Song, _ selectionType: SongSelectionType) {
        print("Song generation triggered")
    }
}
