// SongLink API integration for song matching across platforms

export interface SongLinkResponse {
  entityUniqueId: string
  userCountry: string
  pageUrl: string
  linksByPlatform: {
    [platform: string]: {
      entityUniqueId: string
      url: string
      nativeAppUriMobile?: string
      nativeAppUriDesktop?: string
    }
  }
  entitiesByUniqueId: {
    [id: string]: {
      id: string
      type: string
      title: string
      artistName: string
      thumbnailUrl: string
      thumbnailWidth: number
      thumbnailHeight: number
      apiProvider: string
      platforms: string[]
    }
  }
}

export interface SongData {
  title: string
  artist: string
  album?: string
  isrc: string
  appleMusicUrl?: string
  spotifyUrl?: string
  coverArtUrl?: string
}

export async function matchSongFromUrl(url: string): Promise<SongData | null> {
  try {
    // Call the SongLink API to get song information across platforms
    const response = await fetch(`https://api.song.link/v1-alpha.1/links?url=${encodeURIComponent(url)}`)

    if (!response.ok) {
      throw new Error(`SongLink API error: ${response.status} ${response.statusText}`)
    }

    const data: SongLinkResponse = await response.json()

    // Extract the first entity (song) from the response
    const entityIds = Object.keys(data.entitiesByUniqueId)
    if (entityIds.length === 0) {
      return null
    }

    const entity = data.entitiesByUniqueId[entityIds[0]]

    // Extract platform-specific URLs
    let appleMusicUrl: string | undefined
    let spotifyUrl: string | undefined

    if (data.linksByPlatform.appleMusic) {
      appleMusicUrl = data.linksByPlatform.appleMusic.url
    }

    if (data.linksByPlatform.spotify) {
      spotifyUrl = data.linksByPlatform.spotify.url
    }

    // For the prototype, we're using a placeholder for ISRC since SongLink API
    // doesn't directly provide it in the free tier
    // In a production app, we would extract this from the Apple Music API
    const isrc = `PLACEHOLDER_${Date.now()}`

    return {
      title: entity.title,
      artist: entity.artistName,
      isrc,
      appleMusicUrl,
      spotifyUrl,
      coverArtUrl: entity.thumbnailUrl,
    }
  } catch (error) {
    console.error("Error matching song:", error)
    return null
  }
}
