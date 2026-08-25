CREATE TABLE IF NOT EXISTS champions (
    --champion info
    champion_id INTEGER NOT NULL,
    champion_code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    title TEXT,
    blurb TEXT,
    --characteristic
    primary_tag VARCHAR(50) NOT NULL,
    secondary_tag VARCHAR(50),
    partype VARCHAR(50),
    -- general stats 
    attack SMALLINT,
    defense SMALLINT,
    magic SMALLINT,
    difficulty SMALLINT,
    -- stats desglosadas
    hp REAL,
    hp_per_level REAL,
    mp REAL,
    mp_per_level REAL,
    move_speed REAL,
    armor REAL,
    armor_per_level REAL,
    spell_block REAL,
    spell_block_per_level REAL,
    attack_range REAL,
    hp_regen REAL,
    hp_regen_per_level REAL,
    mp_regen REAL,
    mp_regen_per_level REAL,
    crit REAL,
    crit_per_level REAL,
    attack_damage REAL,
    attack_damage_per_level REAL,
    attack_speed_per_level REAL,
    attack_speed REAL,
    --ddragon version
    ddragon_version VARCHAR(20) NOT NULL,
    --IMPORTANT PRIMARY KEY
    PRIMARY KEY (champion_id, ddragon_version)
)