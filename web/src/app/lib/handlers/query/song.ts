import { Platform, Song } from "@/types/__generated__/resolvers-types";
import { songLinkRequestUrl, SongResponse } from "./songLinkHandler";

export const matchSong = async (
  _: any,
  { url }: { url: string }
): Promise<Song> => {
  const fetchUrl = songLinkRequestUrl(url!);
  return fetch(fetchUrl).then(async (res) => {
    if (!res.ok) throw new Error("Failed to fetch song data");
    const songData = (await res.json()) as SongResponse;
    // Check if the response is valid
    if (!songData || !songData.entityUniqueId) {
      throw new Error("Invalid song data");
    }
    // Return the first song match, assuming the first match is the most relevant
    const entity = songData.entitiesByUniqueId[songData.entityUniqueId];
    const spotify = songData.linksByPlatform["spotify"];
    const appleMusic = songData.linksByPlatform["appleMusic"];
    return {
      title: entity.title,
      artist: entity.artistName,
      isrc: songData.entityUniqueId,
      coverArtUrl: entity.thumbnailUrl,
      platformLinks: [
        {
          __typename: "PlatformLink",
          country: spotify.country,
          desktopAppURI: spotify.nativeAppUriDesktop,
          mobileAppURI: spotify.nativeAppUriMobile,
          platform: Platform.Spotify,
          url: spotify.url,
        },
        {
          __typename: "PlatformLink",
          country: appleMusic.country,
          desktopAppURI: appleMusic.nativeAppUriDesktop,
          mobileAppURI: appleMusic.nativeAppUriMobile,
          platform: Platform.AppleMusic,
          url: appleMusic.url,
        },
      ],
    };
  });
};
