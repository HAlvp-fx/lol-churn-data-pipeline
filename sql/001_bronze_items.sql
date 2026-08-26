CREATE TABLE IF NOT EXISTS items_bronze (
    -- Identifiers
    item_id VARCHAR NOT NULL,
    ddragon_version TEXT NOT NULL,

    -- Basic information
    name TEXT,
    description TEXT,
    colloq TEXT,
    plaintext TEXT,
    -- Build tree
    from_items JSONB,
    into_items JSONB,
    depth INTEGER,

    -- Gold
    gold_base INTEGER,
    gold_total INTEGER,
    gold_sell INTEGER,
    gold_purchasable BOOLEAN,

    -- Item properties
    consumed BOOLEAN,
    stacks INTEGER,
    consume_on_full BOOLEAN,
    special_recipe INTEGER,
    in_store BOOLEAN,
    hide_from_all BOOLEAN,

    -- Restrictions
    required_champion TEXT,
    required_ally TEXT,

    -- Classification / availability
    tags JSONB,
    maps JSONB,
    -- Stats
    stats JSONB,

    -- Rune metadata when present
    rune JSONB,
    PRIMARY KEY (item_id, ddragon_version)
);