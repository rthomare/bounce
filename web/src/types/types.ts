interface SongEntity {
  id: string;
  type: string;
  title: string;
  artistName: string;
  thumbnailUrl: string;
  thumbnailWidth: number;
  thumbnailHeight: number;
  apiProvider: string;
  platforms: string[]; // Updated to use PlatformIdentifier;
}

export enum SupportedPlatforms {
  YOUTUBE = "youtube",
  SPOTIFY = "spotify",
  APPLEMUSIC = "appleMusic",
}

export interface PlatformLink {
  country: string;
  url: string;
  nativeAppUriMobile?: string;
  nativeAppUriDesktop?: string;
  entityUniqueId: string;
}

export interface SongResponse {
  entityUniqueId: string;
  userCountry: string;
  pageUrl: string;
  entitiesByUniqueId: { [key: string]: SongEntity };
  linksByPlatform: { [key in SupportedPlatforms]: PlatformLink };
}

export interface Song {
  title: string;
  artistName: string;
  thumbnailUrl: string;
  thumbnailWidth: number;
  thumbnailHeight: number;
  platform: string;
  platformEntityUrl: string;
  rawData: SongResponse;
}
