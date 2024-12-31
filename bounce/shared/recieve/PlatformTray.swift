//  Created by Rohan Thomare on 12/31/24.

import SwiftUI

struct PlatformButton: View {
    let platform: PlatformIdentifier
    let url: URL
    let expanded: Bool
    
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed: Bool = false
    
    var imageExpanded: String {
        switch platform {
            case .appleMusic: return colorScheme == .dark ? "apple-music-listen-dark" : "apple-music-listen-light"
            case .spotify: return colorScheme == .dark ? "spotify-dark" : "spotify-light"
            case .youtube: return colorScheme == .dark ? "youtube-dark" : "youtube-light"
        }
    }
    
    var imageCompact: String {
        switch platform {
            case .appleMusic: return "apple-music-compact"
            case .spotify: return "spotify-compact"
            case .youtube: return "youtube-compact"
        }
    }
    
    var imageHeight: CGFloat {
        switch platform {
            case .appleMusic: return 40
            case .spotify: return 40
            case .youtube: return 35
        }
    }
    
    var imageVerticalPadding: CGFloat {
        switch platform {
            case .appleMusic: return expanded ? 8 : 0
            case .spotify: return expanded ? 8 : 0
            case .youtube: return expanded ? 10.5 : 0
        }
    }
    
    var body: some View {
        Button(action: {
            openURL(url)
        }) {
            Image(expanded ? imageExpanded : imageCompact)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: imageHeight)
                .animation(.easeInOut(duration: 0.4), value: expanded)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .frame(maxHeight: imageHeight + 2 * imageVerticalPadding)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.25), value: isPressed)
    }
}

struct RoutedPlatformButton: View {
    let song: Song
    let expanded: Bool
    let platform: PlatformIdentifier
    
    var body: some View {
        if let item = song.rawData.linksByPlatform.first(where: {
            $0.key == platform.rawValue
        }), let url = URL(string: item.value.nativeAppUriMobile ?? item.value.url) {
            PlatformButton(
                platform: platform,
                url: url,
                expanded: expanded
            )
        }
    }
}

struct PlatformTray: View {
    let song: Song
    let expanded: Bool
    
    var content: some View {
        Group {
            RoutedPlatformButton(song: song, expanded: expanded, platform: .appleMusic)
            RoutedPlatformButton(song: song, expanded: expanded, platform: .spotify)
            RoutedPlatformButton(song: song, expanded: expanded, platform: .youtube)
        }
    }
    
    var body: some View {
        Group {
            if expanded {
                VStack(alignment: .center, spacing: 10) {
                    content
                }
            } else {
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    content
                    Spacer()
                }
            }
        }.animation(.easeInOut, value: expanded) // Smooth transition
    }
    
}

struct PreviewPlatformTray: View {
    @State var song: Song? = nil
    @State var expanded = false
    @State var isLoading = true
    @State var speed = 1.5
    var request = MockSongLinkRequestFactory.build(songLink: URL(filePath: "spotify:track:0Jcij1eWd5bDMU5iPbxe2i")!)
    
    var body: some View {
        if let song {
            Button("switch style to \(expanded ? "compact" : "expanded")") { expanded.toggle()
            }
            PlatformTray(song: song, expanded: expanded).frame(maxHeight: expanded ? .infinity : 100)
        } else {
            LoaderView(isLoading: true, speed: 1.5).onAppear {
                request.onSuccess { _song, _ in
                    song = _song
                }
                request.resume()
            }
            
        }
    }
}


#Preview {
    PreviewPlatformTray()
    .padding()
    .preferredColorScheme(.dark) // Preview in Dark Mode
}
