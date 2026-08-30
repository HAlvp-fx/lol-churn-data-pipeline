CREATE TABLE IF NOT EXISTS items_silver (
    -- Identifiers
    item_id INTEGER NOT NULL,
    ddragon_version TEXT NOT NULL,
    name TEXT,

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
    in_store BOOLEAN,
    required_champion TEXT,
    required_ally TEXT,

    -- Stats
    stats JSONB,
    effect JSONB,

    PRIMARY KEY (item_id, ddragon_version)
);

INSERT INTO items_silver (
    item_id,
    ddragon_version,
    name,
    from_items,
    into_items,
    depth,
    gold_base,
    gold_total,
    gold_sell,
    gold_purchasable,
    consumed,
    in_store,
    required_champion,
    required_ally,
    stats,
    effect
)
SELECT
    itmb.item_id::INTEGER AS item_id,
    itmb.ddragon_version,
    itmb.name,
    itmb.from_items,
    itmb.into_items,
    itmb.depth,
    itmb.gold_base,
    itmb.gold_total,
    itmb.gold_sell,
    itmb.gold_purchasable,
    itmb.consumed,
    itmb.in_store,
    itmb.required_champion,
    itmb.required_ally,
    itmb.stats,
    itmb.effect
FROM items_bronze AS itmb
-- I'mm only keeping the ones matching map 11 (the one used in all ranked matches according to documentation)
WHERE COALESCE((maps ->> '11')::BOOLEAN, FALSE) = TRUE 
ON CONFLICT (item_id, ddragon_version)
DO UPDATE SET
    name= EXCLUDED.name,
    from_items= EXCLUDED.from_items,
    into_items= EXCLUDED.into_items,
    depth= EXCLUDED.depth,
    gold_base= EXCLUDED.gold_base,
    gold_total= EXCLUDED.gold_total,
    gold_sell= EXCLUDED.gold_sell,
    gold_purchasable= EXCLUDED.gold_purchasable,
    consumed= EXCLUDED.consumed,
    in_store= EXCLUDED.in_store,
    required_champion= EXCLUDED.required_champion,
    required_ally= EXCLUDED.required_ally,
    stats= EXCLUDED.stats,
    effect= EXCLUDED.effect
;

