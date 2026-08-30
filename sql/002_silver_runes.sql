CREATE TABLE IF NOT EXISTS runes_silver (
    --Rune
    id_rune INTEGER NOT NULL,
    ddragon_version TEXT NOT NULL,
    name_rune TEXT,
    slot_rune INTEGER,
    short_desc TEXT,
    long_desc TEXT,
    -- Rune Style
    id_rune_style INTEGER NOT NULL,
    name_rune_style TEXT,

    PRIMARY KEY (id_rune, ddragon_version)
);

INSERT INTO runes_silver (
    id_rune,
    ddragon_version,
    name_rune,
    slot_rune,
    short_desc,
    long_desc,
    id_rune_style,
    name_rune_style
)
SELECT
    runb.id_rune,
    runb.ddragon_version,
    runb.name AS name_rune,
    runb.slot AS slot_rune,
    runb.short_desc,
    runb.long_desc,
    runb.id_rune_style,
    runb.name_rune_style
FROM runes_bronze AS runb
ON CONFLICT (id_rune, ddragon_version)
DO UPDATE SET 
    name_rune  = EXCLUDED.name_rune,
    slot_rune  = EXCLUDED.slot_rune,
    short_desc = EXCLUDED.short_desc,
    long_desc = EXCLUDED.long_desc,
    id_rune_style  = EXCLUDED.id_rune_style,
    name_rune_style  = EXCLUDED.name_rune_style;
