-- Seed data for testing the Song Mirror Service

-- Insert sample songs
INSERT INTO songs (title, artist, album, isrc, apple_music_url, spotify_url, cover_art_url)
VALUES
  ('Blinding Lights', 'The Weeknd', 'After Hours', 'USUG12000678', 
   'https://music.apple.com/us/album/blinding-lights/1499378108?i=1499378615', 
   'https://open.spotify.com/track/0VjIjW4GlUZAMYd2vXMi3b', 
   'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/73/6d/7c/736d7cfb-c79d-c9a9-4170-5e71d008dea1/20UMGIM03639.rgb.jpg/400x400bb.jpg')
ON CONFLICT (isrc) DO NOTHING;

INSERT INTO songs (title, artist, album, isrc, apple_music_url, spotify_url, cover_art_url)
VALUES
  ('As It Was', 'Harry Styles', 'Harry''s House', 'USSM12200345', 
   'https://music.apple.com/us/album/as-it-was/1615584999?i=1615585008', 
   'https://open.spotify.com/track/4LRPiXqCikLlN15c3yImP7', 
   'https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/2a/19/fb/2a19fb85-2f70-9e44-f2a9-82abe679b88e/886449990061.jpg/400x400bb.jpg')
ON CONFLICT (isrc) DO NOTHING;

INSERT INTO songs (title, artist, album, isrc, apple_music_url, spotify_url, cover_art_url)
VALUES
  ('Bad Habit', 'Steve Lacy', 'Gemini Rights', 'USRC12204584', 
   'https://music.apple.com/us/album/bad-habit/1623677456?i=1623677457', 
   'https://open.spotify.com/track/4k6Uh1HXdhtusDfuklvtH0', 
   'https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/2a/cb/e3/2acbe3f1-7a65-e2c1-8f12-ba04c6ee05dc/196589099631.jpg/400x400bb.jpg')
ON CONFLICT (isrc) DO NOTHING;

-- Insert sample playlist
INSERT INTO playlists (name, description, created_by, is_collaborative)
VALUES
  ('Summer Hits', 'Top songs for summer vibes', 'demo_user', TRUE)
ON CONFLICT DO NOTHING
RETURNING id;

-- Get the playlist ID (this is for demonstration - in a real script we'd handle this differently)
DO $$
DECLARE
  playlist_id INTEGER;
BEGIN
  SELECT id INTO playlist_id FROM playlists WHERE name = 'Summer Hits' LIMIT 1;
  
  -- Add songs to the playlist
  INSERT INTO playlist_songs (playlist_id, song_id, position)
  SELECT playlist_id, id, 0
  FROM songs
  WHERE title = 'Blinding Lights'
  ON CONFLICT DO NOTHING;
  
  INSERT INTO playlist_songs (playlist_id, song_id, position)
  SELECT playlist_id, id, 1
  FROM songs
  WHERE title = 'As It Was'
  ON CONFLICT DO NOTHING;
  
  INSERT INTO playlist_songs (playlist_id, song_id, position)
  SELECT playlist_id, id, 2
  FROM songs
  WHERE title = 'Bad Habit'
  ON CONFLICT DO NOTHING;
END $$;
