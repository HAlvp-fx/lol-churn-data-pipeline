CREATE TABLE IF NOT EXISTS players_bronze(
    puuid TEXT PRIMARY KEY,
    sampling_tier VARCHAR(15),
    sampling_division VARCHAR(5),
    tier TEXT,
    rank TEXT,
    leaguePoints INTEGER,
    wins INTEGER,
    losses INTEGER,
    veteran BOOLEAN ,
    inactive BOOLEAN,
    freshBlood BOOLEAN,
    hotStreak BOOLEAN,
    queue VARCHAR(50) NOT NULL,
    platform VARCHAR (15) NOT NULL,
    extracted_at TIMESTAMP NOT NULL
)