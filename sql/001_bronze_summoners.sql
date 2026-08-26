CREATE TABLE IF NOT EXISTS summoner_spells_bronze (
    -- Identifiers
    summoner_spell_id INTEGER NOT NULL,
    spell_code TEXT NOT NULL,
    ddragon_version TEXT NOT NULL,
    -- Basic information
    name TEXT,
    description TEXT,
    tooltip TEXT,

    -- Rank / availability
    max_rank INTEGER,
    summoner_level INTEGER,

    -- Cooldown
    cooldown JSONB,
    cooldown_burn TEXT,
    -- Cost
    cost JSONB,
    cost_burn TEXT,
    cost_type TEXT,
    resource TEXT,

    -- Range / ammo
    range_values JSONB,
    range_burn TEXT,
    max_ammo TEXT,

    -- Effects / variables
    data_values JSONB,
    effect JSONB,
    effect_burn JSONB,
    vars JSONB,

    -- Game modes
    modes JSONB,

    PRIMARY KEY (summoner_spell_id, ddragon_version)
);