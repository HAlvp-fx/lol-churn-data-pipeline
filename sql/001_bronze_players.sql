CREATE TABLE IF NOT EXISTS players_bronze(
    puuid TEXT PRIMARY KEY,
    sampling_tier VARCHAR(15),
    sampling_division VARCHAR(5),
    tier TEXT,
    rank TEXT,
    league_points INTEGER,
    wins INTEGER,
    losses INTEGER,
    veteran BOOLEAN ,
    inactive BOOLEAN,
    fresh_blood BOOLEAN,
    hot_streak BOOLEAN,
    queue VARCHAR(50) NOT NULL,
    platform VARCHAR (15) NOT NULL,
    extracted_at TIMESTAMP NOT NULL
)