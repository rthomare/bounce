import { Song, SongResponse } from "@/types/types";
import { useQuery } from "@tanstack/react-query";

// Assumes url encoded songUrl
const genRequestUrl = (songUrl: string) =>
  `https://api.song.link/v1-alpha.1/links?userCountry=US&songIfSingle=true&url=${songUrl}`;

export const useSongMatchData = ({ songUrl }: { songUrl: string | null }) => {
  return useQuery({
    queryKey: ["songData", songUrl],
    queryFn: () => {
      const requestUrl = genRequestUrl(songUrl!);
      return fetch(requestUrl).then(async (res) => {
        const songData = (await res.json()) as SongResponse;
        // Check if the response is valid
        if (!songData || !songData.entityUniqueId) {
          throw new Error("Invalid song data");
        }
        // Return the first song match, assuming the first match is the most relevant
        const entity = songData.entitiesByUniqueId[songData.entityUniqueId];
        return {
          title: entity.title,
          artistName: entity.artistName,
          thumbnailUrl: entity.thumbnailUrl,
          thumbnailWidth: entity.thumbnailWidth,
          thumbnailHeight: entity.thumbnailHeight,
          platform: entity.platforms[0], // Get the first platform
          platformEntityUrl: songUrl, // Use the original song URL as the platform entity URL
          rawData: songData,
        } as Song;
      });
    },
    enabled: !!songUrl, // Only run the query if songId is truthy
  });
};
