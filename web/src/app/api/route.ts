import { ApolloServer } from "@apollo/server";
import { startServerAndCreateNextHandler } from "@as-integrations/next";
import { readFileSync } from "fs";
import { matchSong } from "../lib/handlers/song";
import {
  getPlaylist as playlist,
  getPlaylists as playlists,
  createPlaylist,
  updatePlaylist,
  deletePlaylist,
  addSongToPlaylist,
  removeSongFromPlaylist,
} from "../lib/handlers/playlist";

// Define resolvers
const resolvers = {
  Query: {
    matchSong,
    playlist,
    playlists,
  },

  Mutation: {
    createPlaylist,
    updatePlaylist,
    deletePlaylist,
    addSongToPlaylist,
    removeSongFromPlaylist,
  },
};

// Create Apollo Server with explicit GraphiQL configuration
const typeDefs = readFileSync("./src/types/schema.graphql", {
  encoding: "utf-8",
});
const server = new ApolloServer({
  typeDefs,
  resolvers,
  introspection: true, // Enable schema introspection
  plugins: [],
});

// Create handler for Next.js API route
const handler = startServerAndCreateNextHandler(server, {
  context: async (req) => ({ req }),
});

const GET = function (req: Request) {
  return handler(req);
};

const POST = function (req: Request) {
  return handler(req);
};

export { GET, POST };
