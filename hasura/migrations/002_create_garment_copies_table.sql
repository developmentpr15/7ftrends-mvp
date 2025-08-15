-- Create garment_copies table
CREATE TYPE copy_type AS ENUM ('avatar', 'real_me');

CREATE TABLE garment_copies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    garment_id UUID REFERENCES garments(id) ON DELETE CASCADE,
    target_user_id UUID NOT NULL,
    copy_type copy_type NOT NULL
);
