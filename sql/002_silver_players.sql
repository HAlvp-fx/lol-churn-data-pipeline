CREATE TABLE IF NOT EXISTS players_silver (

    -- identifier
    puuid TEXT PRIMARY KEY,

    -- cohort / rank at T0
    sampling_tier VARCHAR(15),
    sampling_division VARCHAR(5),
    tier TEXT,
    rank TEXT,
    league_points INTEGER,

    -- ranked history at extraction
    wins INTEGER,
    losses INTEGER,
    total_ranked_games INTEGER,

    veteran BOOLEAN,
    inactive BOOLEAN,
    fresh_blood BOOLEAN,
    hot_streak BOOLEAN,

    queue VARCHAR(50),
    platform VARCHAR(15),
    extracted_at TIMESTAMP,

    -- observed match history
    matches_observed INTEGER,
    first_match_at TIMESTAMP,
    last_match_at TIMESTAMP,

    -- champion usage
    distinct_champions_used INTEGER,
    most_used_champion_id INTEGER,
    most_used_champion_matches INTEGER
);
INSERT INTO players_silver (
    puuid,
    sampling_tier ,
    sampling_division,
    tier ,
    rank ,
    league_points ,
    wins ,
    losses ,
    total_ranked_games ,
    veteran ,
    inactive ,
    fresh_blood ,
    hot_streak ,
    queue ,
    platform ,
    extracted_at ,
    matches_observed ,
    first_match_at ,
    last_match_at ,
    distinct_champions_used ,
    most_used_champion_id ,
    most_used_champion_matches
)
WITH match_stats AS (

    SELECT pmbron.puuid, COUNT(pmbron.match_id) AS matches_observed,
        TO_TIMESTAMP(
            MIN(pmbron.game_start_timestamp) / 1000.0
        ) AT TIME ZONE 'UTC' AS first_match_at,
        TO_TIMESTAMP(
            MAX(pmbron.game_start_timestamp) / 1000.0
        ) AT TIME ZONE 'UTC' AS last_match_at,
        COUNT(DISTINCT pmbron.champion_id) AS distinct_champions_used
    FROM player_matches_bronze AS pmbron
    GROUP BY pmbron.puuid
),

champion_counts AS (
    SELECT pmbron.puuid,  pmbron.champion_id, COUNT(*) AS champion_matches,
        ROW_NUMBER() OVER (
            PARTITION BY pmbron.puuid
            ORDER BY COUNT(*) DESC, pmbron.champion_id
        ) AS champion_rank
    FROM player_matches_bronze AS pmbron
    WHERE pmbron.champion_id IS NOT NULL
    GROUP BY
        pmbron.puuid, pmbron.champion_id
)
SELECT
    pbron.puuid,
    pbron.sampling_tier,
    pbron.sampling_division,
    pbron.tier,
    pbron.rank,
    pbron.league_points,
    pbron.wins,
    pbron.losses,
    COALESCE(pbron.wins, 0) + COALESCE(pbron.losses, 0) AS total_ranked_games,
    pbron.veteran,
    pbron.inactive,
    pbron.fresh_blood,
    pbron.hot_streak,
    pbron.queue,
    pbron.platform,
    pbron.extracted_at,
    COALESCE(ms.matches_observed, 0) AS matches_observed,
    ms.first_match_at,
    ms.last_match_at,
    COALESCE(ms.distinct_champions_used, 0)  AS distinct_champions_used,
    cc.champion_id  AS most_used_champion_id,
    COALESCE(cc.champion_matches, 0) AS most_used_champion_matches

FROM players_bronze AS pbron

LEFT JOIN match_stats AS ms
    ON pbron.puuid = ms.puuid

LEFT JOIN champion_counts AS cc
    ON pbron.puuid = cc.puuid
    AND cc.champion_rank = 1

ON CONFLICT (puuid)
DO UPDATE SET
    sampling_tier = EXCLUDED.sampling_tier,
    sampling_division = EXCLUDED.sampling_division,
    tier = EXCLUDED.tier,
    rank = EXCLUDED.rank,
    league_points = EXCLUDED.league_points,
    wins = EXCLUDED.wins,
    losses = EXCLUDED.losses,
    total_ranked_games = EXCLUDED.total_ranked_games,
    veteran = EXCLUDED.veteran,
    inactive = EXCLUDED.inactive,
    fresh_blood = EXCLUDED.fresh_blood,
    hot_streak = EXCLUDED.hot_streak,
    queue = EXCLUDED.queue,
    platform = EXCLUDED.platform,
    extracted_at = EXCLUDED.extracted_at,
    matches_observed = EXCLUDED.matches_observed,
    first_match_at = EXCLUDED.first_match_at,
    last_match_at = EXCLUDED.last_match_at,
    distinct_champions_used = EXCLUDED.distinct_champions_used,
    most_used_champion_id = EXCLUDED.most_used_champion_id,
    most_used_champion_matches = EXCLUDED.most_used_champion_matches;