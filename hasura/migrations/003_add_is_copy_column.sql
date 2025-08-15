-- Add is_copy column to garments table
ALTER TABLE garments
ADD COLUMN is_copy BOOLEAN NOT NULL DEFAULT FALSE;

-- Add index on (seed_user_id, is_copy)
CREATE INDEX idx_seed_user_id_is_copy ON garments (seed_user_id, is_copy);
