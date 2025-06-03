import { query } from "@/app/lib/db";
import { matchSongFromUrl } from "@/app/lib/songlink";
import { ApolloServer } from "@apollo/server";
import { startServerAndCreateNextHandler } from "@as-integrations/next";
import { readFileSync } from "fs";
import { matchSong } from "../lib/handlers/query/song";

// Define resolvers
const resolvers = {
  Query: {
    matchSong,
    playlist: async (_: any, { id }: { id: string }) => {
      const result = await query(
        `SELECT p.*, 
          (SELECT json_agg(s.* ORDER BY ps.position) 
           FROM playlist_songs ps 
           JOIN songs s ON ps.song_id = s.id 
           WHERE ps.playlist_id = p.id) as songs
         FROM playlists p 
         WHERE p.id = $1`,
        [id]
      );

      return result.rows[0] || null;
    },

    playlists: async () => {
      const result = await query(
        `SELECT p.*, 
          (SELECT json_agg(s.* ORDER BY ps.position) 
           FROM playlist_songs ps 
           JOIN songs s ON ps.song_id = s.id 
           WHERE ps.playlist_id = p.id) as songs
         FROM playlists p`
      );

      return result.rows;
    },
  },

  Mutation: {
    createPlaylist: async (_: any, { input }: { input: any }) => {
      const {
        name,
        description = "",
        created_by = null,
        is_collaborative = true,
      } = input;

      const result = await query(
        `INSERT INTO playlists 
         (name, description, created_by, is_collaborative)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [name, description, created_by, is_collaborative]
      );

      const playlist = result.rows[0];

      // Return the playlist with empty songs array
      return {
        ...playlist,
        songs: [],
      };
    },

    updatePlaylist: async (
      _: any,
      { id, input }: { id: string; input: any }
    ) => {
      const { name, description = "", is_collaborative } = input;

      // Update fields that are provided
      let updateQuery = "UPDATE playlists SET ";
      const updateValues = [];
      const updateFields = [];

      if (name) {
        updateFields.push(`name = $${updateValues.length + 1}`);
        updateValues.push(name);
      }

      if (description !== undefined) {
        updateFields.push(`description = $${updateValues.length + 1}`);
        updateValues.push(description);
      }

      if (is_collaborative !== undefined) {
        updateFields.push(`is_collaborative = $${updateValues.length + 1}`);
        updateValues.push(is_collaborative);
      }

      updateFields.push(`updated_at = CURRENT_TIMESTAMP`);

      updateQuery += updateFields.join(", ");
      updateQuery += ` WHERE id = $${updateValues.length + 1} RETURNING *`;
      updateValues.push(id);

      const result = await query(updateQuery, updateValues);

      if (result.rows.length === 0) {
        throw new Error("Playlist not found");
      }

      // Get the updated playlist with songs
      const playlistResult = await query(
        `SELECT p.*, 
          (SELECT json_agg(s.* ORDER BY ps.position) 
           FROM playlist_songs ps 
           JOIN songs s ON ps.song_id = s.id 
           WHERE ps.playlist_id = p.id) as songs
         FROM playlists p 
         WHERE p.id = $1`,
        [id]
      );

      return playlistResult.rows[0];
    },

    deletePlaylist: async (_: any, { id }: { id: string }) => {
      const result = await query(
        "DELETE FROM playlists WHERE id = $1 RETURNING id",
        [id]
      );

      return result.rows.length > 0;
    },

    addSongToPlaylistByUrl: async (
      _: any,
      { playlistId, url }: { playlistId: string; url: string }
    ) => {
      // Start a transaction
      await query("BEGIN");

      try {
        // Check if playlist exists
        const playlistCheck = await query(
          "SELECT * FROM playlists WHERE id = $1",
          [playlistId]
        );

        if (playlistCheck.rows.length === 0) {
          throw new Error("Playlist not found");
        }

        // Check if playlist already has 10 songs (prototype limit)
        const countResult = await query(
          "SELECT COUNT(*) FROM playlist_songs WHERE playlist_id = $1",
          [playlistId]
        );

        if (Number.parseInt(countResult.rows[0].count) >= 10) {
          throw new Error("Playlist limit of 10 songs reached");
        }

        // Match song using SongLink API
        const songData = await matchSongFromUrl(url);

        if (!songData) {
          throw new Error("Could not match song from provided URL");
        }

        // Check if song already exists in database
        let songResult = await query("SELECT * FROM songs WHERE isrc = $1", [
          songData.isrc,
        ]);

        let song;

        if (songResult.rows.length > 0) {
          // Use existing song
          song = songResult.rows[0];
        } else {
          // Insert new song
          songResult = await query(
            `INSERT INTO songs 
             (title, artist, album, isrc, apple_music_url, spotify_url, cover_art_url)
             VALUES ($1, $2, $3, $4, $5, $6, $7)
             RETURNING *`,
            [
              songData.title,
              songData.artist,
              songData.album || null,
              songData.isrc,
              songData.appleMusicUrl || null,
              songData.spotifyUrl || null,
              songData.coverArtUrl || null,
            ]
          );

          song = songResult.rows[0];
        }

        // Check if song is already in the playlist
        const existingCheck = await query(
          "SELECT * FROM playlist_songs WHERE playlist_id = $1 AND song_id = $2",
          [playlistId, song.id]
        );

        if (existingCheck.rows.length > 0) {
          throw new Error("Song already exists in playlist");
        }

        // Get the next position
        const positionResult = await query(
          "SELECT COALESCE(MAX(position) + 1, 0) as next_position FROM playlist_songs WHERE playlist_id = $1",
          [playlistId]
        );

        const position = positionResult.rows[0].next_position;

        // Add song to playlist
        await query(
          `INSERT INTO playlist_songs 
           (playlist_id, song_id, position)
           VALUES ($1, $2, $3)`,
          [playlistId, song.id, position]
        );

        // Commit the transaction
        await query("COMMIT");

        // Get the updated playlist with songs
        const result = await query(
          `SELECT p.*, 
            (SELECT json_agg(s.* ORDER BY ps.position) 
             FROM playlist_songs ps 
             JOIN songs s ON ps.song_id = s.id 
             WHERE ps.playlist_id = p.id) as songs
           FROM playlists p 
           WHERE p.id = $1`,
          [playlistId]
        );

        return result.rows[0];
      } catch (error) {
        // Rollback transaction on error
        await query("ROLLBACK");
        throw error;
      }
    },

    removeSongFromPlaylist: async (
      _: any,
      { playlistId, songId }: { playlistId: string; songId: string }
    ) => {
      // Start a transaction
      await query("BEGIN");

      try {
        // Check if playlist exists
        const playlistCheck = await query(
          "SELECT * FROM playlists WHERE id = $1",
          [playlistId]
        );

        if (playlistCheck.rows.length === 0) {
          throw new Error("Playlist not found");
        }

        // Remove the song
        const removeResult = await query(
          "DELETE FROM playlist_songs WHERE playlist_id = $1 AND song_id = $2 RETURNING id",
          [playlistId, songId]
        );

        if (removeResult.rows.length === 0) {
          throw new Error("Song not found in playlist");
        }

        // Reorder remaining songs
        await query(
          `WITH ranked AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY position) - 1 as new_position
            FROM playlist_songs
            WHERE playlist_id = $1
          )
          UPDATE playlist_songs ps
          SET position = r.new_position
          FROM ranked r
          WHERE ps.id = r.id`,
          [playlistId]
        );

        // Commit the transaction
        await query("COMMIT");

        // Get the updated playlist with songs
        const result = await query(
          `SELECT p.*, 
            (SELECT json_agg(s.* ORDER BY ps.position) 
             FROM playlist_songs ps 
             JOIN songs s ON ps.song_id = s.id 
             WHERE ps.playlist_id = p.id) as songs
           FROM playlists p 
           WHERE p.id = $1`,
          [playlistId]
        );

        return result.rows[0];
      } catch (error) {
        // Rollback transaction on error
        await query("ROLLBACK");
        throw error;
      }
    },
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

export { handler as GET, handler as POST };
