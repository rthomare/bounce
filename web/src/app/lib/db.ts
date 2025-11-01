import { Pool } from "pg";

// Create a singleton PostgreSQL connection pool
let pool: Pool | null = null;

export function getPool() {
  if (!pool) {
    pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl:
        process.env.NODE_ENV === "production"
          ? { rejectUnauthorized: false }
          : false,
    });
  }
  return pool;
}

// Helper function to execute SQL queries
export async function query(text: string, params: any[] = []) {
  const pool = getPool();
  try {
    const result = await pool.query(text, params);
    return result;
  } catch (error) {
    console.error("Database query error:", error);
    throw error;
  }
}

// Initialize database tables
export async function initializeDatabase() {
  const createSongsTable = `
    CREATE TABLE IF NOT EXISTS songs (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      artist VARCHAR(255) NOT NULL,
      album VARCHAR(255),
      isrc VARCHAR(50) UNIQUE NOT NULL,
      apple_music_url TEXT,
      spotify_url TEXT,
      cover_art_url TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createPlaylistsTable = `
    CREATE TABLE IF NOT EXISTS playlists (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      description TEXT,
      created_by VARCHAR(255),
      is_collaborative BOOLEAN DEFAULT TRUE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createPlaylistSongsTable = `
    CREATE TABLE IF NOT EXISTS playlist_songs (
      id SERIAL PRIMARY KEY,
      playlist_id INTEGER REFERENCES playlists(id) ON DELETE CASCADE,
      song_id INTEGER REFERENCES songs(id) ON DELETE CASCADE,
      position INTEGER NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(playlist_id, song_id)
    );
  `;

  try {
    await query(createSongsTable);
    await query(createPlaylistsTable);
    await query(createPlaylistSongsTable);
    console.log("Database tables initialized successfully");
  } catch (error) {
    console.error("Error initializing database tables:", error);
    throw error;
  }
}
