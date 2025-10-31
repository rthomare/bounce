//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

let EXPANED_HEIGHT: CGFloat = 450

struct ReceieveLoadedView: View {
    @ObservedObject var controller: ReceiveController
    @State var isPreferred: Bool = false
    
    let song: Song
    
    var body: some View {
        GeometryReader { geometry in
            let expanded = geometry.size.height > EXPANED_HEIGHT
            VStack(spacing:0) {
                if (expanded) { Spacer () }
                SongEntityView(song: song).animation(.easeInOut, value: expanded)
                Text("choose your platform")
                    .foregroundColor(.secondary)
                    .font(expanded ? .title3 : .callout)
                    .padding(expanded ? 8 : 2)
                PlatformTray(song: song, expanded: expanded) { song, platform in
                    controller.selectPlatform(
                        song: song,
                        platform: platform,
                        preferred: isPreferred)
                }
                if (expanded) {
                    Spacer ()
                    HStack {
                        Button(action: {
                            isPreferred.toggle()
                        }) {
                            Image(systemName: isPreferred ? "checkmark.square" : "square")
                                .foregroundColor(.blue)
                                .font(.system(size: 24))
                        }
                        Text("Auto-select this platform")
                            .font(.headline)
                    }.padding()
                }
                
            }.frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    PreviewBounce()
}
