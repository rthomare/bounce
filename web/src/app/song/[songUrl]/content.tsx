"use client";
import {
  Center,
  Heading,
  HStack,
  Image,
  Link,
  Spinner,
  Stack,
  VStack,
} from "@chakra-ui/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ClientUIProvider } from "@/components/ui/provider";
import { useFetchMatch } from "@/app/lib/hooks/useFetchMatch";
import { Platform } from "@/types/__generated__/resolvers-types";

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
  const { isPending, error, data: song } = useFetchMatch({ songUrl });
  if (isPending) return <Spinner />;
  if (error) return "An error has occurred: " + error.message;
  return (
    <Center w="100%" h="100vh">
      <VStack>
        <Stack
          shadow="textColor"
          borderRadius="20px"
          overflow="hidden"
          backgroundImage={`url(${song.coverArtUrl})`}
          backgroundSize="cover"
          backgroundPosition="center"
          gap={0}
        >
          <iframe
            style={{
              width: "100%",
              height: "100%",
            }}
            // src={`https://www.youtube.com/embed/${youtubeId}?autoplay=1&mute=1`}
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
              {song.artist}
            </Heading>
          </VStack>
        </Stack>
        <HStack w="100%" justifyContent="space-evenly" px={8} gap={8} mt={4}>
          <Link
            href={
              song.platformLinks?.find((a) => a?.platform === Platform.Spotify)
                ?.url
            }
          >
            <Image h="50px" src="/spotify.png" alt="spotify" />
          </Link>
          <Link
            href={
              song.platformLinks?.find(
                (a) => a?.platform === Platform.AppleMusic
              )?.url
            }
          >
            <Image h="50px" src="/am-white.svg" alt="apple music" />
          </Link>
        </HStack>
      </VStack>
    </Center>
  );
}
