//  Created by Rohan Thomare on 12/23/24.

import SwiftUI
import MediaPlayer

struct ContentView: View {
    let flowController = CreateFlowController(DefaultSongLinkRequestFactory.self)

    var body: some View {
        VStack(alignment: .center) {
            CreateView(flowController: flowController)
        }
    }
}

#Preview {
    let flowController = CreateFlowController(MockSongLinkRequestFactory.self)
    CreateView(flowController: flowController)
}
