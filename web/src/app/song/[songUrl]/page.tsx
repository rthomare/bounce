import SongDisplay from "./content";
import type { Metadata } from "next";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";

type Props = {
  params: Promise<{
    songUrl: string;
  }>;
  searchParams: Promise<{
    tn: string; // thumbnail
    t: string; // title
    a: string; // artrist
    al: string; // album
  }>;
};

export async function generateMetadata({
  params,
  searchParams,
}: Props): Promise<Metadata> {
  // read route params
  const { songUrl } = await params;
  const { tn: thumbnail, t: title, a: artist, al: album } = await searchParams;
  return {
    title: title,
    authors: [
      {
        name: artist,
        url: songUrl,
      },
    ],
    openGraph: {
      images: [
        {
          url: thumbnail,
          width: 1024,
          height: 1024,
          alt: album,
        },
      ],
      description: `You were bounced ${title}. Bounce back!`,
      title: `${title} - ${artist}`,
      type: "music.song",
      url: songUrl,
    },
    twitter: {
      card: "player",
      site: "@r0tiroll",
      title: `${title} - ${artist}`,
      description: `You were bounced ${title}. Bounce back!`,
      images: thumbnail,
    },
  };
}

export default async function Page({ params }: Props) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        // With SSR, we usually want to set some default staleTime
        // above 0 to avoid refetching immediately on the client
        staleTime: 60 * 1000,
      },
    },
  });

  const { songUrl } = await params;
  return (
    <QueryClientProvider client={queryClient}>
      <SongDisplay songUrl={songUrl} />
    </QueryClientProvider>
  );
}
