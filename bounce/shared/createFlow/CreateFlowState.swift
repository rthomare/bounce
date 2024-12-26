//  Created by Rohan Thomare on 12/23/24.

import UIKit

enum CreateFlowState {
    case initial
    case loadingSong(link: URL, request: any SongLinkRequest)
    case songLoaded(song: SongModel, request: any SongLinkRequest)
    case loadError(error: Error, request: any SongLinkRequest)
}
