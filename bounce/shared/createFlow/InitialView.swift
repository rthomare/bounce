//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct InitialView: View {
    var body: some View {
        VStack {
            Text("copy a song link")
                .font(.title)
                .foregroundColor(Color.primary)
                .fontWeight(.thin)
            Button("or try a sample here") {
                UIPasteboard.general.string = "https://open.spotify.com/track/0Jcij1eWd5bDMU5iPbxe2i"
            }.font(.footnote)
        }
        
    }
}

#Preview {
    InitialView()
}
