//
//  SongEntityView.swift
//  bounce
//
//  Created by Rohan Thomare on 12/25/24.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // No updates needed
    }
}

struct SongEntityView: View {
    let song: Song
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) // Use the smaller dimension
            ZStack (alignment: .bottom) {
                // Album Artwork
                Image(uiImage: song.thumbnail ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .clipped()
                Rectangle()
                    .frame(width: size, height: size)
                    .background(Color.primary)
                    .opacity(0.01)
                HStack {
                    // Blur and Text Overlay
                    VStack(alignment:.leading, spacing: 4) {
                        Text(song.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("By \(song.artistName)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                    .padding(10)
                    Spacer()
                }.background(
                    BlurView()
                        .background(Color.black.opacity(0.5))
                )
            }
            .cornerRadius(16)
            .frame(width: size, height: size)
        }
        .cornerRadius(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Prevent GeometryReader from taking extra space
        .aspectRatio(1, contentMode: .fit) // Maintain a square layout
    }
}

struct PreviewSongEntity: View {
    @State var song: Song? = nil
    @State var isLoading = true
    @State var speed = 1.5
    @State var request = MockSongLinkRequestFactory.build(songLink: URL(filePath: "spotify:track:0Jcij1eWd5bDMU5iPbxe2i")!)
    
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
            SongEntityView(song: song!).padding(.all, 10)
        }
    }
}

#Preview {
    PreviewSongEntity()
}
