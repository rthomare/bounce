//
//  SongEntityView.swift
//  bounce
//
//  Created by Rohan Thomare on 12/25/24.
//

import SwiftUI

struct SongEntityView: View {
    let song: Song
    
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            // Album Artwork
            Image(uiImage: song.thumbnail ?? UIImage())
                .resizable()
                .scaledToFill()
                .clipped()
            VStack {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("By \(song.artistName)")
                    .font(.subheadline)
                    .lineLimit(1)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .glassEffect(in: .rect(cornerRadius: 0))
        }
        .cornerRadius(16)
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
