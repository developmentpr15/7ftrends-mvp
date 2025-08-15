-- Create garments table
CREATE TABLE garments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seed_user_id UUID NOT NULL,
    mask_url TEXT NOT NULL,
    texture_url TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
