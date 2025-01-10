//  Created by Rohan Thomare on 12/23/24.

import SwiftUI
import MediaPlayer

struct ContentView: View {
    let controller = CreateController(DefaultSongLinkRequestFactory.self)

    var body: some View {
        VStack(alignment: .center) {
            CreateView(controller: controller)
        }
    }
}

#Preview {
    let controller = CreateController(MockSongLinkRequestFactory.self)
    CreateView(controller: controller)
}
