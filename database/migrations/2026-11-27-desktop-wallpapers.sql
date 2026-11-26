-- Wallora v1.7.8: separate desktop wallpaper catalogue from mobile wallpapers.
-- Mobile clients continue using public.wallpapers and its existing relation tables.

CREATE TABLE IF NOT EXISTS public.desktop_wallpapers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category varchar NOT NULL,
  title varchar NOT NULL,
  image text NOT NULL,
  download text NOT NULL,
  timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  likes_count integer NOT NULL DEFAULT 0,
  tags text[] NOT NULL DEFAULT '{}'::text[],
  width integer,
  height integer,
  resolution varchar,
  aspect_ratio numeric(8,4),
  file_size_bytes bigint,
  is_active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  CONSTRAINT desktop_wallpapers_dimensions_positive
    CHECK ((width IS NULL OR width > 0) AND (height IS NULL OR height > 0)),
  CONSTRAINT desktop_wallpapers_file_size_positive
    CHECK (file_size_bytes IS NULL OR file_size_bytes > 0)
);

CREATE INDEX IF NOT EXISTS desktop_wallpapers_timestamp_idx
  ON public.desktop_wallpapers (timestamp DESC);
CREATE INDEX IF NOT EXISTS desktop_wallpapers_category_idx
  ON public.desktop_wallpapers (category);
CREATE INDEX IF NOT EXISTS desktop_wallpapers_active_sort_idx
  ON public.desktop_wallpapers (is_active, sort_order, timestamp DESC);
CREATE INDEX IF NOT EXISTS desktop_wallpapers_tags_idx
  ON public.desktop_wallpapers USING GIN (tags);

CREATE TABLE IF NOT EXISTS public.desktop_wallpaper_likes (
  id bigserial PRIMARY KEY,
  user_id text NOT NULL,
  wallpaper_id uuid NOT NULL
    REFERENCES public.desktop_wallpapers(id) ON DELETE CASCADE,
  UNIQUE (user_id, wallpaper_id)
);
CREATE INDEX IF NOT EXISTS desktop_wallpaper_likes_wallpaper_idx
  ON public.desktop_wallpaper_likes (wallpaper_id);

CREATE TABLE IF NOT EXISTS public.desktop_wallpaper_saved (
  user_id varchar NOT NULL,
  wallpaper_id uuid NOT NULL
    REFERENCES public.desktop_wallpapers(id) ON DELETE CASCADE,
  saved_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, wallpaper_id)
);
CREATE INDEX IF NOT EXISTS desktop_wallpaper_saved_saved_at_idx
  ON public.desktop_wallpaper_saved (user_id, saved_at DESC);
