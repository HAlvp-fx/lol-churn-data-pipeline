-- Keeping only CLASSIC spells and del fields not needed for patch comparisons
CREATE TABLE IF NOT EXISTS summoner_spells_silver (
    -- Identifiers
    summoner_spell_id INTEGER NOT NULL,
    ddragon_version TEXT NOT NULL,
    name TEXT,

    -- Availability
    max_rank INTEGER,
    summoner_level INTEGER,

    -- Mechanical attributes
    cooldown JSONB,
    cost JSONB,
    cost_type TEXT,
    range_values JSONB,
    max_ammo TEXT,

    data_values JSONB,
    effect JSONB,

    PRIMARY KEY (summoner_spell_id, ddragon_version)
);

INSERT INTO summoner_spells_silver (
    summoner_spell_id,
    ddragon_version,
    name,
    max_rank,
    summoner_level,
    cooldown,
    cost,
    cost_type,
    range_values,
    max_ammo,
    data_values,
    effect
)
SELECT
    sumsb.summoner_spell_id,
    sumsb.ddragon_version,
    sumsb.name,
    sumsb.max_rank,
    sumsb.summoner_level,
    sumsb.cooldown,
    sumsb.cost,
    sumsb.cost_type,
    sumsb.range_values,
    sumsb.max_ammo,
    sumsb.data_values,
    sumsb.effect
FROM summoner_spells_bronze AS sumsb
WHERE sumsb.modes @> '["CLASSIC"]'::jsonb
-- Im keeping CLASSIC spells only (the one that uses SOLO 5X5), drop descriptions/tooltips and repeated burn fields
ON CONFLICT (summoner_spell_id, ddragon_version)
DO UPDATE SET
    name = EXCLUDED.name,
    max_rank = EXCLUDED.max_rank,
    summoner_level = EXCLUDED.summoner_level,
    cooldown = EXCLUDED.cooldown,
    cost = EXCLUDED.cost,
    cost_type = EXCLUDED.cost_type,
    range_values = EXCLUDED.range_values,
    max_ammo = EXCLUDED.max_ammo,
    data_values = EXCLUDED.data_values,
    effect = EXCLUDED.effect;