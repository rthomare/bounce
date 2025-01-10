//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct InitialView: View {
    let controller: CreateController
    
    var body: some View {
        VStack {
            Text("copy a song link")
                .font(.title)
                .foregroundColor(Color.primary)
                .fontWeight(.thin)
            HStack(spacing:4) {
                Button("tap here to check", action: {
                    controller.detectSong()
                })
                    .font(.footnote)
                    .fontWeight(.medium)
                Text("or shake to sample")
                    .font(.footnote)
                    .foregroundColor(Color.primary)
                    .fontWeight(.medium)
            }
        }.background(
            ShakeDetector {
                controller.rotateRandomSong()
            }
        )
    }
}

#Preview {
    let controller = CreateController(MockSongLinkRequestFactory.self)
    InitialView(controller: controller)
}
