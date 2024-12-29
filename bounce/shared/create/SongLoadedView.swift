//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

let songPrompts: [String] = [
    "Look what we made you do...",
    "I am once again asking for your attention... to this song.",
    "In the multiverse of songs, this one chose you.",
    "It’s giving... new music vibes.",
    "This song understood the assignment.",
    "We understood the reference, and now we made this.",
    "Achievement unlocked: new banger created.",
    "Press F to pay respect to every other song.",
    "This track is now super effective.",
    "One does not simply create a song... but we did.",
    "A new sound? Bold of us to assume you’re ready.",
    "Shrek said, 'SomeBODY once told me...' and now it's this.",
    "Straight outta the algorithm, here’s your hit.",
    "Fresh beats, hot off the server.",
    "We just dropped this like it’s hot.",
    "a wild song just appeared...",
]

func djb2Hash(_ input: String) -> Int {
    var hash: UInt64 = 5381
    for char in input {
        hash = ((hash << 5) &+ hash) &+ UInt64(char.asciiValue ?? 0)
    }
    return Int(truncatingIfNeeded: hash)
}

struct CloseButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle().foregroundStyle(Color.black.opacity(0.01)).frame(width: 50, height: 50)
                Circle()
                    .stroke(Color.white, lineWidth: 3) // Outer circular border
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(Color.gray) // Inner lighter gray background
                    .frame(width: 20, height: 20)
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .heavy)) // Bold X icon
                    .foregroundColor(.white) // White color for the "X"
            }
        }
        .buttonStyle(.plain) // Removes default button style
    }
}

struct SongLoadedView: View {
    var song: Song
    let flowController: CreateFlowController
    @State private var isPressed: Bool = false
    
    var body: some View {
        // Map the hash value into the range of indices
        let index = abs(djb2Hash(String(song.rawData.entityUniqueId)) % songPrompts.count)
        VStack {
            Text(songPrompts[index]).font(.title3) // Set your initial font size
                .lineLimit(1) // Ensure the text stays on one line
                .minimumScaleFactor(0.1) // Scale down to 10% of the original size if needed
                .frame(maxWidth: .infinity, alignment: .center) // Limit the width of the text
                .foregroundColor(.primary)
                
            Text("tap to share, or copy another song").foregroundColor(.secondary)
            ZStack(alignment: .topTrailing) {
                    SongEntityView(song: song).padding(4).onTapGesture {
                        flowController.selectSong(song)
                    }
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                        isPressed = isPressing
                    }, perform: {})
                CloseButton {
                    flowController.reset()
                }
            }.scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.25), value: isPressed)
            .background(ShakeDetector {
                flowController.selectSong(song, selectionType: .shake)
            })
        }
    }
}

struct PreviewSongLoaded: View {
    @State var song: Song? = nil
    @State var isLoading = true
    @State var speed = 1.5
    @State var request = MockSongLinkRequestFactory.build(songLink: URL(filePath: "spotify:track:0Jcij1eWd5bDMU5iPbxe2i")!)
    let flowController = CreateFlowController(MockSongLinkRequestFactory.self)
    
    var body: some View {
        if (song == nil) {
            LoaderView(isLoading: isLoading, speed: speed).onAppear {
                request = request.onSuccess { mockedSong, _ in
                    isLoading = false
                    song = mockedSong
                }
                request.resume()
            }
        } else {
            SongLoadedView(song: song!, flowController: flowController).frame(width: 300, height: 300)
        }
    }
}

#Preview {
    PreviewSongLoaded()
}
