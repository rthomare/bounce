//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct InitialView: View {
    let flowController: CreateFlowController
    
    var body: some View {
        VStack {
            Text("copy a song link")
                .font(.title)
                .foregroundColor(Color.primary)
                .fontWeight(.thin)
            Text("or shake to sample")
                .font(.footnote)
                .foregroundColor(Color.primary)
                .fontWeight(.medium)
        }.background(
            ShakeDetector {
                flowController.rotateRandomSong()
            }
        )
    }
}

#Preview {
    let flowController = CreateFlowController(MockSongLinkRequestFactory.self)
    InitialView(flowController: flowController)
}
