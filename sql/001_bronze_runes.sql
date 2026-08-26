CREATE TABLE IF NOT EXISTS runes_bronze (
    --Rune
    id_rune INTEGER NOT NULL,
    key VARCHAR(30),
    name TEXT,
    short_desc TEXT,
    long_desc TEXT,
    slot INTEGER,
    

    -- Rune Style
    id_rune_style INTEGER NOT NULL,
    key_rune_style VARCHAR(30),
    name_rune_style TEXT,

    ddragon_version TEXT NOT NULL,

    PRIMARY KEY (id_rune, ddragon_version)
)