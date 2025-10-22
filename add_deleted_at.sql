ALTER TABLE load_forecasts_beam_types ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;
CREATE INDEX IF NOT EXISTS index_load_forecasts_beam_types_on_deleted_at ON load_forecasts_beam_types(deleted_at);
