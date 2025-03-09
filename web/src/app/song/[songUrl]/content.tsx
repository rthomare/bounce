"use client";
import {
  Button,
  Center,
  Heading,
  HStack,
  Link,
  Spinner,
  Stack,
  VStack,
} from "@chakra-ui/react";
import { useSongMatchData } from "@/hooks/fetchSongData";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ClientUIProvider } from "@/components/ui/provider";

const queryClient = new QueryClient();

export default function Content({ songUrl }: { songUrl: string }) {
  return (
    <QueryClientProvider client={queryClient}>
      <ClientUIProvider>
        <SongMatchInner songUrl={songUrl} />
      </ClientUIProvider>
    </QueryClientProvider>
  );
}

function SongMatchInner({ songUrl }: { songUrl: string }) {
  const { isPending, error, data: song } = useSongMatchData({ songUrl });
  if (isPending) return <Spinner />;
  if (error) return "An error has occurred: " + error.message;
  const songLinks = song.rawData.linksByPlatform;
  const youtubeId =
    song.rawData.linksByPlatform.youtube.entityUniqueId.split("::")[1];
  return (
    <Center w="100%" h="100vh">
      <VStack>
        <Stack
          shadow="textColor"
          borderRadius="20px"
          overflow="hidden"
          backgroundImage={`url(${song.thumbnailUrl})`}
          backgroundSize="cover"
          backgroundPosition="center"
          w={song.thumbnailWidth}
          h={song.thumbnailHeight}
          gap={0}
        >
          <iframe
            style={{
              width: "100%",
              height: "100%",
            }}
            src={`https://www.youtube.com/embed/${youtubeId}?autoplay=1&mute=1`}
          />
          <VStack
            zIndex={1}
            alignItems="start"
            gap={0}
            p={4}
            backdropFilter={"blur(10px)"}
            backgroundColor="rgba(120, 120, 120, 0.25)"
          >
            <Heading zIndex={1}>{song.title}</Heading>
            <Heading zIndex={1} size="sm">
              {song.artistName}
            </Heading>
          </VStack>
        </Stack>
        <HStack w="100%" justifyContent="center" m={2}>
          <Link href={songLinks.spotify.url}>
            <Button>Listen on Spotify</Button>
          </Link>
          <Link href={songLinks.appleMusic.url}>
            <Button>Listen on Apple Music</Button>
          </Link>
        </HStack>
      </VStack>
    </Center>
  );
}
