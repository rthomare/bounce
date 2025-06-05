import { useQuery } from "@tanstack/react-query";
import { matchSong } from "../handlers/song";

export const useFetchMatch = ({ songUrl }: { songUrl: string }) => {
  return useQuery({
    queryKey: ["songData", songUrl],
    queryFn: () => matchSong(null, { url: songUrl }),
    enabled: !!songUrl, // Only run the query if songId is truthy
  });
};
