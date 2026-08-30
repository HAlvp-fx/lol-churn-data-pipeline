DROP TABLE IF EXISTS silver_validation_results;
CREATE TEMP TABLE silver_validation_results (
    section TEXT NOT NULL,
    severity TEXT NOT NULL,
    check_name TEXT NOT NULL,
    bad_rows BIGINT NOT NULL,
    status TEXT NOT NULL,
    notes TEXT
);

-- first I check that the tables and important columns are there

INSERT INTO silver_validation_results
SELECT
    '00_schema', 'BLOCKER', 'all expected Silver tables exist',
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
    'Expected: players, player_matches, matches, teammates, champions, items, runes, summoner_spells'
FROM (
    SELECT t.table_name
    FROM (VALUES
        ('players_silver'),
        ('player_matches_silver'),
        ('matches_silver'),
        ('teammates_silver'),
        ('champions_silver'),
        ('items_silver'),
        ('runes_silver'),
        ('summoner_spells_silver')
    ) AS t(table_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.tables i
        WHERE i.table_schema = 'public'
          AND i.table_name = t.table_name
    )
) missing;

-- checking I kept the useful historical ddragon fields
INSERT INTO silver_validation_results
SELECT
    '00_schema', 'BLOCKER', 'historical Data Dragon mechanical columns exist',
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
    'Rune descriptions are intentionally retained because rune mechanics may be encoded in text; structured item/spell/champion mechanics are also retained.'
FROM (
    SELECT x.table_name, x.column_name
    FROM (VALUES
        ('champions_silver','hp'),
        ('champions_silver','hp_per_level'),
        ('champions_silver','attack_damage'),
        ('champions_silver','attack_damage_per_level'),
        ('champions_silver','attack_speed'),
        ('champions_silver','attack_speed_per_level'),
        ('items_silver','stats'),
        ('items_silver','effect'),
        ('runes_silver','short_desc'),
        ('runes_silver','long_desc'),
        ('summoner_spells_silver','cooldown'),
        ('summoner_spells_silver','cost'),
        ('summoner_spells_silver','range_values'),
        ('summoner_spells_silver','data_values'),
        ('summoner_spells_silver','effect')
    ) AS x(table_name, column_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.columns c
        WHERE c.table_schema = 'public'
          AND c.table_name = x.table_name
          AND c.column_name = x.column_name
    )
) missing_columns;

-- every silver table should have a primary key
INSERT INTO silver_validation_results
SELECT
    '00_schema', 'BLOCKER', 'all Silver tables have a primary key',
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
    'Primary keys protect the declared grains of the Silver layer.'
FROM (
    SELECT t.table_name
    FROM (VALUES
        ('players_silver'),
        ('player_matches_silver'),
        ('matches_silver'),
        ('teammates_silver'),
        ('champions_silver'),
        ('items_silver'),
        ('runes_silver'),
        ('summoner_spells_silver')
    ) AS t(table_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints tc
        WHERE tc.table_schema = 'public'
          AND tc.table_name = t.table_name
          AND tc.constraint_type = 'PRIMARY KEY'
    )
) missing_pk;

-- checking row counts against bronze

INSERT INTO silver_validation_results
SELECT '01_counts', 'BLOCKER', 'players_silver has exactly the 1,400-player cohort',
       ABS((SELECT COUNT(*) FROM players_silver) - 1400)::BIGINT,
       CASE WHEN (SELECT COUNT(*) FROM players_silver) = 1400 THEN 'PASS' ELSE 'FAIL' END,
       'Expected fixed modelling cohort: 1,400 players.';

INSERT INTO silver_validation_results
SELECT '01_counts', 'BLOCKER', 'players_silver row count equals players_bronze',
       ABS((SELECT COUNT(*) FROM players_silver) - (SELECT COUNT(*) FROM players_bronze))::BIGINT,
       CASE WHEN (SELECT COUNT(*) FROM players_silver) = (SELECT COUNT(*) FROM players_bronze) THEN 'PASS' ELSE 'FAIL' END,
       'Silver players should preserve the full sampled cohort.';

INSERT INTO silver_validation_results
SELECT '01_counts', 'BLOCKER', 'player_matches_silver count equals tracked Bronze participant rows',
       ABS(
           (SELECT COUNT(*) FROM player_matches_silver)
           -
           (SELECT COUNT(*)
            FROM player_matches_bronze b
            INNER JOIN players_bronze p ON p.puuid = b.puuid)
       )::BIGINT,
       CASE WHEN
           (SELECT COUNT(*) FROM player_matches_silver)
           =
           (SELECT COUNT(*)
            FROM player_matches_bronze b
            INNER JOIN players_bronze p ON p.puuid = b.puuid)
       THEN 'PASS' ELSE 'FAIL' END,
       'Participant Silver must contain only tracked cohort participants, but all their recovered matches.';

INSERT INTO silver_validation_results
SELECT '01_counts', 'BLOCKER', 'matches_silver count equals distinct Bronze matches',
       ABS((SELECT COUNT(*) FROM matches_silver) - (SELECT COUNT(DISTINCT match_id) FROM player_matches_bronze))::BIGINT,
       CASE WHEN (SELECT COUNT(*) FROM matches_silver) = (SELECT COUNT(DISTINCT match_id) FROM player_matches_bronze)
            THEN 'PASS' ELSE 'FAIL' END,
       'matches_silver must aggregate ALL Bronze participants, not only tracked players.';

INSERT INTO silver_validation_results
SELECT '01_counts', 'BLOCKER', 'champions_silver count equals champions_bronze',
       ABS((SELECT COUNT(*) FROM champions_silver) - (SELECT COUNT(*) FROM champions_bronze))::BIGINT,
       CASE WHEN (SELECT COUNT(*) FROM champions_silver) = (SELECT COUNT(*) FROM champions_bronze)
            THEN 'PASS' ELSE 'FAIL' END,
       'No champion filter is expected in Silver.';

INSERT INTO silver_validation_results
SELECT '01_counts', 'BLOCKER', 'runes_silver count equals runes_bronze',
       ABS((SELECT COUNT(*) FROM runes_silver) - (SELECT COUNT(*) FROM runes_bronze))::BIGINT,
       CASE WHEN (SELECT COUNT(*) FROM runes_silver) = (SELECT COUNT(*) FROM runes_bronze)
            THEN 'PASS' ELSE 'FAIL' END,
       'No rune filter is expected in Silver.';

INSERT INTO silver_validation_results
SELECT '01_counts', 'BLOCKER', 'items_silver equals Bronze items available on map 11',
       ABS(
           (SELECT COUNT(*) FROM items_silver)
           -
           (SELECT COUNT(*) FROM items_bronze WHERE COALESCE((maps ->> '11')::BOOLEAN, FALSE))
       )::BIGINT,
       CASE WHEN
           (SELECT COUNT(*) FROM items_silver)
           =
           (SELECT COUNT(*) FROM items_bronze WHERE COALESCE((maps ->> '11')::BOOLEAN, FALSE))
       THEN 'PASS' ELSE 'FAIL' END,
       'Also catches stale rows left by a previous Silver filter.';

INSERT INTO silver_validation_results
SELECT '01_counts', 'BLOCKER', 'summoner_spells_silver equals Bronze CLASSIC spells',
       ABS(
           (SELECT COUNT(*) FROM summoner_spells_silver)
           -
           (SELECT COUNT(*) FROM summoner_spells_bronze WHERE modes @> '["CLASSIC"]'::jsonb)
       )::BIGINT,
       CASE WHEN
           (SELECT COUNT(*) FROM summoner_spells_silver)
           =
           (SELECT COUNT(*) FROM summoner_spells_bronze WHERE modes @> '["CLASSIC"]'::jsonb)
       THEN 'PASS' ELSE 'FAIL' END,
       'Also catches stale rows left by a previous Silver filter.';

-- checking grains and duplicates

INSERT INTO silver_validation_results
SELECT '02_grain', 'BLOCKER', 'players_silver has no duplicate puuid', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Grain: one tracked player.'
FROM (SELECT puuid FROM players_silver GROUP BY puuid HAVING COUNT(*) > 1) d;

INSERT INTO silver_validation_results
SELECT '02_grain', 'BLOCKER', 'player_matches_silver has no duplicate (match_id, puuid)', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Grain: one tracked player in one match.'
FROM (SELECT match_id, puuid FROM player_matches_silver GROUP BY match_id, puuid HAVING COUNT(*) > 1) d;

INSERT INTO silver_validation_results
SELECT '02_grain', 'BLOCKER', 'matches_silver has no duplicate match_id', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Grain: one match.'
FROM (SELECT match_id FROM matches_silver GROUP BY match_id HAVING COUNT(*) > 1) d;

INSERT INTO silver_validation_results
SELECT '02_grain', 'BLOCKER', 'teammates has no duplicate canonical pair', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Grain: one unordered teammate pair.'
FROM (
    SELECT player_1_puuid, player_2_puuid
    FROM teammates_silver
    GROUP BY player_1_puuid, player_2_puuid
    HAVING COUNT(*) > 1
) d;

-- checking the cohort stayed the same

INSERT INTO silver_validation_results
SELECT '03_cohort', 'BLOCKER', 'sampling tiers remain 200 players each', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Expected tiers: IRON, BRONZE, SILVER, GOLD, PLATINUM, EMERALD, DIAMOND; 200 each.'
FROM (
    SELECT expected.tier
    FROM (VALUES
        ('IRON'), ('BRONZE'), ('SILVER'), ('GOLD'), ('PLATINUM'), ('EMERALD'), ('DIAMOND')
    ) expected(tier)
    LEFT JOIN (
        SELECT sampling_tier, COUNT(*) AS n
        FROM players_silver
        GROUP BY sampling_tier
    ) actual ON actual.sampling_tier = expected.tier
    WHERE COALESCE(actual.n, 0) <> 200

    UNION ALL

    SELECT sampling_tier
    FROM players_silver
    WHERE sampling_tier NOT IN ('IRON','BRONZE','SILVER','GOLD','PLATINUM','EMERALD','DIAMOND')
    GROUP BY sampling_tier
) bad_tiers;

INSERT INTO silver_validation_results
SELECT '03_cohort', 'BLOCKER', 'every player_matches_silver puuid belongs to cohort', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'No non-cohort participant should leak into player_matches_silver.'
FROM player_matches_silver pm
LEFT JOIN players_silver p ON p.puuid = pm.puuid
WHERE p.puuid IS NULL;

INSERT INTO silver_validation_results
SELECT '03_cohort', 'BLOCKER', 'every player_matches_silver match exists in matches_silver', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Participant facts must have match context.'
FROM player_matches_silver pm
LEFT JOIN matches_silver m ON m.match_id = pm.match_id
WHERE m.match_id IS NULL;

INSERT INTO silver_validation_results
SELECT '03_cohort', 'BLOCKER', 'total_ranked_games = wins + losses', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'League-V4 snapshot consistency.'
FROM players_silver
WHERE total_ranked_games IS DISTINCT FROM (COALESCE(wins,0) + COALESCE(losses,0));

-- making sure I didnt change the original cohort info
INSERT INTO silver_validation_results
SELECT '03_cohort', 'BLOCKER', 'players_silver core snapshot fields match Bronze', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Checks that Silver did not alter cohort/rank snapshot values.'
FROM players_silver s
JOIN players_bronze b USING (puuid)
WHERE s.sampling_tier IS DISTINCT FROM b.sampling_tier
   OR s.sampling_division IS DISTINCT FROM b.sampling_division
   OR s.tier IS DISTINCT FROM b.tier
   OR s.rank IS DISTINCT FROM b.rank
   OR s.league_points IS DISTINCT FROM b.league_points
   OR s.wins IS DISTINCT FROM b.wins
   OR s.losses IS DISTINCT FROM b.losses
   OR s.veteran IS DISTINCT FROM b.veteran
   OR s.inactive IS DISTINCT FROM b.inactive
   OR s.fresh_blood IS DISTINCT FROM b.fresh_blood
   OR s.hot_streak IS DISTINCT FROM b.hot_streak
   OR s.queue IS DISTINCT FROM b.queue
   OR s.platform IS DISTINCT FROM b.platform
   OR s.extracted_at IS DISTINCT FROM b.extracted_at;

-- checking the player aggregates

INSERT INTO silver_validation_results
WITH expected AS (
    SELECT
        p.puuid,
        COUNT(b.match_id)::INTEGER AS matches_observed,
        TO_TIMESTAMP(MIN(b.game_start_timestamp) / 1000.0) AT TIME ZONE 'UTC' AS first_match_at,
        TO_TIMESTAMP(MAX(b.game_start_timestamp) / 1000.0) AT TIME ZONE 'UTC' AS last_match_at,
        COUNT(DISTINCT b.champion_id)::INTEGER AS distinct_champions_used
    FROM players_bronze p
    LEFT JOIN player_matches_bronze b ON b.puuid = p.puuid
    GROUP BY p.puuid
)
SELECT '04_player_aggregates', 'BLOCKER', 'player history aggregates match Bronze', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Checks matches_observed, first/last match and distinct champion count.'
FROM players_silver s
JOIN expected e USING (puuid)
WHERE s.matches_observed IS DISTINCT FROM e.matches_observed
   OR s.first_match_at IS DISTINCT FROM e.first_match_at
   OR s.last_match_at IS DISTINCT FROM e.last_match_at
   OR s.distinct_champions_used IS DISTINCT FROM e.distinct_champions_used;

INSERT INTO silver_validation_results
WITH champion_counts AS (
    SELECT
        p.puuid,
        b.champion_id,
        COUNT(*)::INTEGER AS champion_matches,
        ROW_NUMBER() OVER (
            PARTITION BY p.puuid
            ORDER BY COUNT(*) DESC, b.champion_id
        ) AS champion_rank
    FROM players_bronze p
    JOIN player_matches_bronze b ON b.puuid = p.puuid
    WHERE b.champion_id IS NOT NULL
    GROUP BY p.puuid, b.champion_id
), expected AS (
    SELECT p.puuid,
           c.champion_id AS most_used_champion_id,
           COALESCE(c.champion_matches,0) AS most_used_champion_matches
    FROM players_bronze p
    LEFT JOIN champion_counts c
      ON c.puuid = p.puuid AND c.champion_rank = 1
)
SELECT '04_player_aggregates', 'BLOCKER', 'most-used champion fields match Bronze tie-break logic', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Tie-break: champion_id ascending when counts tie.'
FROM players_silver s
JOIN expected e USING (puuid)
WHERE s.most_used_champion_id IS DISTINCT FROM e.most_used_champion_id
   OR s.most_used_champion_matches IS DISTINCT FROM e.most_used_champion_matches;

INSERT INTO silver_validation_results
SELECT '04_player_aggregates', 'BLOCKER', 'player aggregate values are logically possible', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'No negative counts; most-used count cannot exceed observed matches; first_match <= last_match.'
FROM players_silver
WHERE matches_observed < 0
   OR distinct_champions_used < 0
   OR most_used_champion_matches < 0
   OR most_used_champion_matches > matches_observed
   OR distinct_champions_used > matches_observed
   OR (first_match_at IS NOT NULL AND last_match_at IS NOT NULL AND first_match_at > last_match_at);

-- checking player matches

INSERT INTO silver_validation_results
SELECT '05_player_matches', 'BLOCKER', 'core participant fields match Bronze', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Checks identifiers/result/core values on the tracked participant rows.'
FROM player_matches_silver s
JOIN player_matches_bronze b USING (match_id, puuid)
WHERE s.team_id IS DISTINCT FROM b.team_id
   OR s.summoner_level IS DISTINCT FROM b.summoner_level
   OR s.time_played IS DISTINCT FROM b.time_played
   OR s.champion_id IS DISTINCT FROM b.champion_id
   OR s.win IS DISTINCT FROM b.win
   OR s.kills IS DISTINCT FROM b.kills
   OR s.deaths IS DISTINCT FROM b.deaths
   OR s.assists IS DISTINCT FROM b.assists;

INSERT INTO silver_validation_results
SELECT '05_player_matches', 'BLOCKER', 'derived objective fields match Bronze logic', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Validates first_tower_participation and objective steal participation count.'
FROM player_matches_silver s
JOIN player_matches_bronze b USING (match_id, puuid)
WHERE s.first_tower_participation IS DISTINCT FROM (
          COALESCE(b.first_tower_kill,FALSE) OR COALESCE(b.first_tower_assist,FALSE)
      )
   OR s.objectives_stolen_participation IS DISTINCT FROM (
          COALESCE(b.objectives_stolen,0) + COALESCE(b.objectives_stolen_assists,0)
      );

INSERT INTO silver_validation_results
SELECT '05_player_matches', 'BLOCKER', 'participant core fields are non-null / valid', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'team_id should be 100/200; champion, win and time are expected for Match-V5 participants.'
FROM player_matches_silver
WHERE match_id IS NULL
   OR puuid IS NULL
   OR team_id NOT IN (100,200)
   OR team_id IS NULL
   OR champion_id IS NULL
   OR win IS NULL
   OR time_played IS NULL
   OR time_played < 0;

INSERT INTO silver_validation_results
SELECT '05_player_matches', 'BLOCKER', 'selected non-negative participant metrics are not negative', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Negative values in these count/amount fields would indicate transformation or source issues.'
FROM player_matches_silver
WHERE COALESCE(kills,0) < 0
   OR COALESCE(deaths,0) < 0
   OR COALESCE(assists,0) < 0
   OR COALESCE(gold_earned,0) < 0
   OR COALESCE(gold_spent,0) < 0
   OR COALESCE(items_purchased,0) < 0
   OR COALESCE(consumables_purchased,0) < 0
   OR COALESCE(total_minions_killed,0) < 0
   OR COALESCE(neutral_minions_killed,0) < 0
   OR COALESCE(total_damage_dealt,0) < 0
   OR COALESCE(total_damage_dealt_to_champions,0) < 0
   OR COALESCE(total_damage_taken,0) < 0
   OR COALESCE(vision_score,0) < 0
   OR COALESCE(total_pings,0) < 0
   OR COALESCE(total_spell_casts,0) < 0
   OR COALESCE(summoner_spell_casts,0) < 0;

INSERT INTO silver_validation_results
SELECT '05_player_matches', 'WARN', 'team_position values are recognised', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Inspect blanks/unknown positions; do not silently coerce them.'
FROM player_matches_silver
WHERE team_position IS NULL
   OR team_position NOT IN ('TOP','JUNGLE','MIDDLE','BOTTOM','UTILITY');

-- checking matches

INSERT INTO silver_validation_results
SELECT '06_matches', 'BLOCKER', 'each match has 5 players per team in arrays', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Expected 5v5 Summoner''s Rift match structure.'
FROM matches_silver
WHERE COALESCE(cardinality(t100_players_puuid),0) <> 5
   OR COALESCE(cardinality(t200_players_puuid),0) <> 5
   OR COALESCE(cardinality(t100_champions_id),0) <> 5
   OR COALESCE(cardinality(t200_champions_id),0) <> 5;

INSERT INTO silver_validation_results
SELECT '06_matches', 'BLOCKER', 'team player arrays do not overlap', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'A player cannot belong to both teams in the same match.'
FROM matches_silver m
WHERE EXISTS (
    SELECT 1
    FROM unnest(m.t100_players_puuid) a(puuid)
    JOIN unnest(m.t200_players_puuid) b(puuid) USING (puuid)
);

INSERT INTO silver_validation_results
SELECT '06_matches', 'BLOCKER', 'match timestamps are ordered', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Expected creation <= start <= end and non-negative duration.'
FROM matches_silver
WHERE game_creation_at IS NULL
   OR game_start_at IS NULL
   OR game_end_at IS NULL
   OR game_creation_at > game_start_at
   OR game_start_at > game_end_at
   OR time_played < 0;

-- a null winner can happen in remakes/early terminations, but other values would be wrong
INSERT INTO silver_validation_results
SELECT '06_matches', 'BLOCKER', 'winning_team has no impossible values', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'If there is a winner it should only be team 100 or 200.'
FROM matches_silver
WHERE winning_team IS NOT NULL
  AND winning_team NOT IN (100, 200);

-- I keep null winners as a warning so I can inspect the weird matches
INSERT INTO silver_validation_results
SELECT '06_matches', 'WARN', 'matches with no winning_team are reviewed', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Possible remake or early termination. I review these instead of inventing a winner.'
FROM matches_silver
WHERE winning_team IS NULL;

INSERT INTO silver_validation_results
WITH expected AS (
    SELECT
        b.match_id,
        MAX(b.game_version) AS game_version,
        MAX(b.time_played) AS time_played,
        MAX(b.team_id) FILTER (WHERE b.win = TRUE) AS winning_team,
        COUNT(*) FILTER (WHERE b.was_afk = TRUE)::INTEGER AS afk_players,
        BOOL_OR(b.game_ended_in_surrender) AS game_ended_in_surrender,
        BOOL_OR(b.game_ended_in_early_surrender) AS game_ended_in_early_surrender
    FROM player_matches_bronze b
    GROUP BY b.match_id
)
SELECT '06_matches', 'BLOCKER', 'core match aggregates match Bronze', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Checks repeated match fields plus winner/AFK/surrender aggregation.'
FROM matches_silver s
JOIN expected e USING (match_id)
WHERE s.game_version IS DISTINCT FROM e.game_version
   OR s.time_played IS DISTINCT FROM e.time_played
   OR s.winning_team IS DISTINCT FROM e.winning_team
   OR s.afk_players IS DISTINCT FROM e.afk_players
   OR s.game_ended_in_surrender IS DISTINCT FROM e.game_ended_in_surrender
   OR s.game_ended_in_early_surrender IS DISTINCT FROM e.game_ended_in_early_surrender;

-- checking teams order because I use it for bans
INSERT INTO silver_validation_results
SELECT '06_matches', 'BLOCKER', 'Bronze teams JSON ordering is team 100 then team 200', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Required for the current ban extraction logic using teams[0] and teams[1].'
FROM (
    SELECT match_id
    FROM player_matches_bronze
    WHERE teams IS NULL
       OR teams -> 0 ->> 'teamId' IS DISTINCT FROM '100'
       OR teams -> 1 ->> 'teamId' IS DISTINCT FROM '200'
    GROUP BY match_id
) bad;

-- checking the 90 day window
INSERT INTO silver_validation_results
SELECT '06_matches', 'WARN', 'matches fall inside the intended 90-day historical window', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Expected dates: 2026-05-22 through 2026-08-20 inclusive. Inspect exact T0 timestamp if boundary rows appear.'
FROM matches_silver
WHERE game_start_at::date < DATE '2026-05-22'
   OR game_start_at::date > DATE '2026-08-20';

-- team metrics shouldnt be negative
INSERT INTO silver_validation_results
SELECT '06_matches', 'BLOCKER', 'selected team aggregates are non-negative', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Checks major team count/amount metrics.'
FROM matches_silver
WHERE COALESCE(t100_kills,0) < 0 OR COALESCE(t200_kills,0) < 0
   OR COALESCE(t100_deaths,0) < 0 OR COALESCE(t200_deaths,0) < 0
   OR COALESCE(t100_assists,0) < 0 OR COALESCE(t200_assists,0) < 0
   OR COALESCE(t100_gold_earned,0) < 0 OR COALESCE(t200_gold_earned,0) < 0
   OR COALESCE(t100_gold_spent,0) < 0 OR COALESCE(t200_gold_spent,0) < 0
   OR COALESCE(t100_total_damage_dealt,0) < 0 OR COALESCE(t200_total_damage_dealt,0) < 0
   OR COALESCE(t100_vision_score,0) < 0 OR COALESCE(t200_vision_score,0) < 0
   OR COALESCE(t100_total_pings,0) < 0 OR COALESCE(t200_total_pings,0) < 0;

-- checking teammate pairs

INSERT INTO silver_validation_results
SELECT '07_teammates', 'BLOCKER', 'teammate pairs use canonical orientation p1 < p2', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Guarantees no A-B / B-A duplication and no self-pairs.'
FROM teammates_silver
WHERE player_1_puuid >= player_2_puuid;

INSERT INTO silver_validation_results
SELECT '07_teammates', 'BLOCKER', 'every teammate pair contains at least one tracked player', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Non-cohort vs non-cohort relations should not be materialised.'
FROM teammates_silver t
WHERE NOT EXISTS (
    SELECT 1
    FROM players_silver p
    WHERE p.puuid = t.player_1_puuid
       OR p.puuid = t.player_2_puuid
);

INSERT INTO silver_validation_results
SELECT '07_teammates', 'BLOCKER', 'wins + losses = matches_together', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Every shared match should have one shared result.'
FROM teammates_silver
WHERE wins_together + losses_together <> matches_together
   OR matches_together <= 0
   OR wins_together < 0
   OR losses_together < 0;

INSERT INTO silver_validation_results
SELECT '07_teammates', 'BLOCKER', 'teammate role counts cannot exceed matches_together', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Role counts are per shared match.'
FROM teammates_silver
WHERE p1_top_matches > matches_together
   OR p1_jungle_matches > matches_together
   OR p1_middle_matches > matches_together
   OR p1_bottom_matches > matches_together
   OR p1_utility_matches > matches_together
   OR p2_top_matches > matches_together
   OR p2_jungle_matches > matches_together
   OR p2_middle_matches > matches_together
   OR p2_bottom_matches > matches_together
   OR p2_utility_matches > matches_together
   OR LEAST(
        p1_top_matches,p1_jungle_matches,p1_middle_matches,p1_bottom_matches,p1_utility_matches,
        p2_top_matches,p2_jungle_matches,p2_middle_matches,p2_bottom_matches,p2_utility_matches
      ) < 0;

-- rebuilding teammates from bronze to check the silver table
INSERT INTO silver_validation_results
WITH expected AS (
    SELECT
        p1.puuid AS player_1_puuid,
        p2.puuid AS player_2_puuid,
        COUNT(DISTINCT p1.match_id)::INTEGER AS matches_together,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.win = TRUE)::INTEGER AS wins_together,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.win = FALSE)::INTEGER AS losses_together,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.team_position = 'TOP')::INTEGER AS p1_top_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.team_position = 'JUNGLE')::INTEGER AS p1_jungle_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.team_position = 'MIDDLE')::INTEGER AS p1_middle_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.team_position = 'BOTTOM')::INTEGER AS p1_bottom_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.team_position = 'UTILITY')::INTEGER AS p1_utility_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p2.team_position = 'TOP')::INTEGER AS p2_top_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p2.team_position = 'JUNGLE')::INTEGER AS p2_jungle_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p2.team_position = 'MIDDLE')::INTEGER AS p2_middle_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p2.team_position = 'BOTTOM')::INTEGER AS p2_bottom_matches,
        COUNT(DISTINCT p1.match_id) FILTER (WHERE p2.team_position = 'UTILITY')::INTEGER AS p2_utility_matches
    FROM player_matches_bronze p1
    JOIN player_matches_bronze p2
      ON p1.match_id = p2.match_id
     AND p1.team_id = p2.team_id
     AND p1.puuid < p2.puuid
    WHERE EXISTS (
        SELECT 1
        FROM players_bronze cohort
        WHERE cohort.puuid = p1.puuid OR cohort.puuid = p2.puuid
    )
    GROUP BY p1.puuid, p2.puuid
), mismatches AS (
    SELECT COALESCE(e.player_1_puuid,s.player_1_puuid) AS p1,
           COALESCE(e.player_2_puuid,s.player_2_puuid) AS p2
    FROM expected e
    FULL OUTER JOIN teammates_silver s
      ON s.player_1_puuid = e.player_1_puuid
     AND s.player_2_puuid = e.player_2_puuid
    WHERE s.player_1_puuid IS NULL
       OR e.player_1_puuid IS NULL
       OR s.matches_together IS DISTINCT FROM e.matches_together
       OR s.wins_together IS DISTINCT FROM e.wins_together
       OR s.losses_together IS DISTINCT FROM e.losses_together
       OR s.p1_top_matches IS DISTINCT FROM e.p1_top_matches
       OR s.p1_jungle_matches IS DISTINCT FROM e.p1_jungle_matches
       OR s.p1_middle_matches IS DISTINCT FROM e.p1_middle_matches
       OR s.p1_bottom_matches IS DISTINCT FROM e.p1_bottom_matches
       OR s.p1_utility_matches IS DISTINCT FROM e.p1_utility_matches
       OR s.p2_top_matches IS DISTINCT FROM e.p2_top_matches
       OR s.p2_jungle_matches IS DISTINCT FROM e.p2_jungle_matches
       OR s.p2_middle_matches IS DISTINCT FROM e.p2_middle_matches
       OR s.p2_bottom_matches IS DISTINCT FROM e.p2_bottom_matches
       OR s.p2_utility_matches IS DISTINCT FROM e.p2_utility_matches
)
SELECT '07_teammates', 'BLOCKER', 'teammate Silver exactly reconstructs from Bronze', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Strong end-to-end check of pair orientation, cohort filter, results and role counts.'
FROM mismatches;

-- missing roles are not necessarily an error but I want to see them
INSERT INTO silver_validation_results
SELECT '07_teammates', 'WARN', 'both pair members have recognised role for every shared match', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'A failure is not automatically wrong; it means some Bronze team_position values were missing/unrecognised.'
FROM teammates_silver
WHERE (p1_top_matches + p1_jungle_matches + p1_middle_matches + p1_bottom_matches + p1_utility_matches) <> matches_together
   OR (p2_top_matches + p2_jungle_matches + p2_middle_matches + p2_bottom_matches + p2_utility_matches) <> matches_together;

-- checking ddragon versions and match patches

-- all historical versions should still be there
INSERT INTO silver_validation_results
SELECT '08_ddragon', 'BLOCKER', 'champion Data Dragon versions preserved', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Historical versions are needed for patch comparison.'
FROM (
    SELECT DISTINCT ddragon_version FROM champions_bronze
    EXCEPT
    SELECT DISTINCT ddragon_version FROM champions_silver
) x;

INSERT INTO silver_validation_results
SELECT '08_ddragon', 'BLOCKER', 'item Data Dragon versions preserved after map-11 filter', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Every downloaded version with map-11 items should remain represented.'
FROM (
    SELECT DISTINCT ddragon_version
    FROM items_bronze
    WHERE COALESCE((maps ->> '11')::BOOLEAN, FALSE)
    EXCEPT
    SELECT DISTINCT ddragon_version FROM items_silver
) x;

INSERT INTO silver_validation_results
SELECT '08_ddragon', 'BLOCKER', 'rune Data Dragon versions preserved', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Historical versions are needed for patch comparison.'
FROM (
    SELECT DISTINCT ddragon_version FROM runes_bronze
    EXCEPT
    SELECT DISTINCT ddragon_version FROM runes_silver
) x;

INSERT INTO silver_validation_results
SELECT '08_ddragon', 'BLOCKER', 'summoner spell Data Dragon versions preserved after CLASSIC filter', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Every downloaded version with CLASSIC spells should remain represented.'
FROM (
    SELECT DISTINCT ddragon_version
    FROM summoner_spells_bronze
    WHERE modes @> '["CLASSIC"]'::jsonb
    EXCEPT
    SELECT DISTINCT ddragon_version FROM summoner_spells_silver
) x;

-- match version is longer than ddragon version so I compare major.minor
INSERT INTO silver_validation_results
SELECT '08_ddragon', 'BLOCKER', 'every match major.minor has a Data Dragon version', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Needed before joining Match-V5 facts to patch-specific reference data.'
FROM (
    SELECT DISTINCT split_part(game_version,'.',1) || '.' || split_part(game_version,'.',2) AS patch_mm
    FROM matches_silver
    EXCEPT
    SELECT DISTINCT split_part(ddragon_version,'.',1) || '.' || split_part(ddragon_version,'.',2) AS patch_mm
    FROM champions_silver
) x;

-- if I have more than one ddragon version per major.minor the mapping is ambiguous
INSERT INTO silver_validation_results
SELECT '08_ddragon', 'WARN', 'Data Dragon major.minor mapping is unambiguous', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'If this fails, define an explicit Match-V5 gameVersion -> Data Dragon version mapping table.'
FROM (
    SELECT split_part(ddragon_version,'.',1) || '.' || split_part(ddragon_version,'.',2) AS patch_mm
    FROM champions_silver
    GROUP BY 1
    HAVING COUNT(DISTINCT ddragon_version) > 1
) x;

-- champion ids should exist in the matching patch
INSERT INTO silver_validation_results
SELECT '08_ddragon', 'BLOCKER', 'participant champion IDs resolve in patch-specific Data Dragon', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Join uses major.minor mapping; inspect failures before Gold.'
FROM player_matches_silver pm
JOIN matches_silver m ON m.match_id = pm.match_id
LEFT JOIN champions_silver c
  ON c.champion_id = pm.champion_id
 AND split_part(c.ddragon_version,'.',1) = split_part(m.game_version,'.',1)
 AND split_part(c.ddragon_version,'.',2) = split_part(m.game_version,'.',2)
WHERE c.champion_id IS NULL;

-- summoner spell ids should normally exist in the matching patch
INSERT INTO silver_validation_results
SELECT '08_ddragon', 'WARN', 'summoner spell IDs resolve in patch-specific CLASSIC Data Dragon', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Failures can expose non-CLASSIC matches, special spell IDs, or patch mapping gaps.'
FROM (
    SELECT pm.match_id, pm.puuid, pm.summoner_1_id AS spell_id, m.game_version
    FROM player_matches_silver pm JOIN matches_silver m USING (match_id)
    WHERE pm.summoner_1_id IS NOT NULL AND pm.summoner_1_id <> 0
    UNION ALL
    SELECT pm.match_id, pm.puuid, pm.summoner_2_id AS spell_id, m.game_version
    FROM player_matches_silver pm JOIN matches_silver m USING (match_id)
    WHERE pm.summoner_2_id IS NOT NULL AND pm.summoner_2_id <> 0
) x
LEFT JOIN summoner_spells_silver s
  ON s.summoner_spell_id = x.spell_id
 AND split_part(s.ddragon_version,'.',1) = split_part(x.game_version,'.',1)
 AND split_part(s.ddragon_version,'.',2) = split_part(x.game_version,'.',2)
WHERE s.summoner_spell_id IS NULL;

-- item ids can have some special cases so this is only a warning
INSERT INTO silver_validation_results
SELECT '08_ddragon', 'WARN', 'observed item IDs resolve in patch-specific map-11 Data Dragon', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate missing IDs; do not assume every special/transformed item must be present in Data Dragon.'
FROM (
    SELECT pm.match_id, pm.puuid, x.item_id, m.game_version
    FROM player_matches_silver pm
    JOIN matches_silver m USING (match_id)
    CROSS JOIN LATERAL unnest(ARRAY[
        pm.item_0, pm.item_1, pm.item_2, pm.item_3,
        pm.item_4, pm.item_5, pm.item_6, pm.role_bound_item
    ]) AS x(item_id)
    WHERE x.item_id IS NOT NULL AND x.item_id <> 0
) observed
LEFT JOIN items_silver i
  ON i.item_id = observed.item_id
 AND split_part(i.ddragon_version,'.',1) = split_part(observed.game_version,'.',1)
 AND split_part(i.ddragon_version,'.',2) = split_part(observed.game_version,'.',2)
WHERE i.item_id IS NULL;

-- basic ddragon checks

INSERT INTO silver_validation_results
SELECT '09_ddragon_quality', 'BLOCKER', 'champion identifiers/names/version are non-null', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       NULL
FROM champions_silver
WHERE champion_id IS NULL OR ddragon_version IS NULL OR name IS NULL;

INSERT INTO silver_validation_results
SELECT '09_ddragon_quality', 'BLOCKER', 'item identifiers/names/version are non-null', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       NULL
FROM items_silver
WHERE item_id IS NULL OR ddragon_version IS NULL OR name IS NULL;

INSERT INTO silver_validation_results
SELECT '09_ddragon_quality', 'BLOCKER', 'rune identifiers/style/version are non-null', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       NULL
FROM runes_silver
WHERE id_rune IS NULL OR ddragon_version IS NULL OR id_rune_style IS NULL;

INSERT INTO silver_validation_results
SELECT '09_ddragon_quality', 'BLOCKER', 'summoner spell identifiers/name/version are non-null', COUNT(*)::BIGINT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       NULL
FROM summoner_spells_silver
WHERE summoner_spell_id IS NULL OR ddragon_version IS NULL OR name IS NULL;

-- final results

SELECT
    section,
    severity,
    check_name,
    bad_rows,
    status,
    notes
FROM silver_validation_results
ORDER BY
    CASE status WHEN 'FAIL' THEN 0 ELSE 1 END,
    CASE severity WHEN 'BLOCKER' THEN 0 ELSE 1 END,
    section,
    check_name;

-- quick final decision
SELECT
    COUNT(*) FILTER (WHERE severity = 'BLOCKER' AND status = 'FAIL') AS blocker_failures,
    COUNT(*) FILTER (WHERE severity = 'WARN' AND status = 'FAIL') AS warnings_to_review,
    COUNT(*) FILTER (WHERE status = 'PASS') AS passed_checks,
    CASE
        WHEN COUNT(*) FILTER (WHERE severity = 'BLOCKER' AND status = 'FAIL') = 0
        THEN 'SILVER CAN BE CLOSED AFTER REVIEWING WARNINGS'
        ELSE 'DO NOT CLOSE SILVER YET'
    END AS silver_decision
FROM silver_validation_results;

-- some extra outputs I want to look at before closing silver

-- row counts
SELECT 'players_silver' AS table_name, COUNT(*) AS rows FROM players_silver
UNION ALL SELECT 'player_matches_silver', COUNT(*) FROM player_matches_silver
UNION ALL SELECT 'matches_silver', COUNT(*) FROM matches_silver
UNION ALL SELECT 'teammates_silver', COUNT(*) FROM teammates_silver
UNION ALL SELECT 'champions_silver', COUNT(*) FROM champions_silver
UNION ALL SELECT 'items_silver', COUNT(*) FROM items_silver
UNION ALL SELECT 'runes_silver', COUNT(*) FROM runes_silver
UNION ALL SELECT 'summoner_spells_silver', COUNT(*) FROM summoner_spells_silver
ORDER BY table_name;

-- players per tier
SELECT sampling_tier, COUNT(*) AS players
FROM players_silver
GROUP BY sampling_tier
ORDER BY CASE sampling_tier
    WHEN 'IRON' THEN 1 WHEN 'BRONZE' THEN 2 WHEN 'SILVER' THEN 3
    WHEN 'GOLD' THEN 4 WHEN 'PLATINUM' THEN 5 WHEN 'EMERALD' THEN 6
    WHEN 'DIAMOND' THEN 7 ELSE 99 END;

-- match dates and versions
SELECT
    MIN(game_start_at) AS min_game_start_at,
    MAX(game_start_at) AS max_game_start_at,
    COUNT(DISTINCT game_version) AS distinct_full_game_versions,
    COUNT(DISTINCT split_part(game_version,'.',1) || '.' || split_part(game_version,'.',2)) AS distinct_major_minor_patches
FROM matches_silver;

-- ddragon rows per version
SELECT 'champions' AS entity, ddragon_version, COUNT(*) AS rows
FROM champions_silver GROUP BY ddragon_version
UNION ALL
SELECT 'items', ddragon_version, COUNT(*) FROM items_silver GROUP BY ddragon_version
UNION ALL
SELECT 'runes', ddragon_version, COUNT(*) FROM runes_silver GROUP BY ddragon_version
UNION ALL
SELECT 'summoner_spells', ddragon_version, COUNT(*) FROM summoner_spells_silver GROUP BY ddragon_version
ORDER BY entity, ddragon_version;

-- teammate recurrence, useful later for gold
SELECT
    matches_together,
    COUNT(*) AS teammate_pairs
FROM teammates_silver
GROUP BY matches_together
ORDER BY matches_together;

-- top teammate pairs just to have a look
SELECT
    player_1_puuid,
    player_2_puuid,
    matches_together,
    wins_together,
    losses_together
FROM teammates_silver
ORDER BY matches_together DESC, player_1_puuid, player_2_puuid
LIMIT 20;

-- positions
SELECT
    COALESCE(team_position, '<NULL>') AS team_position,
    COUNT(*) AS rows
FROM player_matches_silver
GROUP BY team_position
ORDER BY rows DESC;

-- some important nulls
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE champion_id IS NULL) AS null_champion_id,
    COUNT(*) FILTER (WHERE team_position IS NULL) AS null_team_position,
    COUNT(*) FILTER (WHERE perks IS NULL) AS null_perks,
    COUNT(*) FILTER (WHERE summoner_1_id IS NULL) AS null_summoner_1_id,
    COUNT(*) FILTER (WHERE summoner_2_id IS NULL) AS null_summoner_2_id
FROM player_matches_silver;


-- first a quick summary of the matches without winner
SELECT
    game_ended_in_surrender,
    game_ended_in_early_surrender,
    COUNT(*) AS matches
FROM matches_silver
WHERE winning_team IS NULL
   OR winning_team NOT IN (100, 200)
GROUP BY
    game_ended_in_surrender,
    game_ended_in_early_surrender
ORDER BY matches DESC;

-- now I print every no-winner match with the surrender flags
SELECT
    match_id,
    winning_team,
    game_start_at,
    game_end_at,
    time_played,
    afk_players,
    game_ended_in_surrender,
    game_ended_in_early_surrender
FROM matches_silver
WHERE winning_team IS NULL
   OR winning_team NOT IN (100, 200)
ORDER BY
    game_ended_in_early_surrender DESC,
    game_ended_in_surrender DESC,
    time_played,
    game_start_at;


-- unresolved items grouped by slot, id and patch so I can see what is causing the warning
WITH observed AS (
    SELECT
        pm.match_id,
        pm.puuid,
        m.game_version,
        x.slot_name,
        x.item_id
    FROM player_matches_silver pm
    JOIN matches_silver m USING (match_id)
    CROSS JOIN LATERAL (
        VALUES
            ('item_0', pm.item_0),
            ('item_1', pm.item_1),
            ('item_2', pm.item_2),
            ('item_3', pm.item_3),
            ('item_4', pm.item_4),
            ('item_5', pm.item_5),
            ('item_6', pm.item_6),
            ('role_bound_item', pm.role_bound_item)
    ) AS x(slot_name, item_id)
    WHERE x.item_id IS NOT NULL
      AND x.item_id <> 0
)
SELECT
    observed.slot_name,
    observed.item_id,
    split_part(observed.game_version, '.', 1)
        || '.'
        || split_part(observed.game_version, '.', 2) AS patch,
    COUNT(*) AS appearances
FROM observed
LEFT JOIN items_silver i
    ON i.item_id = observed.item_id
   AND split_part(i.ddragon_version, '.', 1)
        = split_part(observed.game_version, '.', 1)
   AND split_part(i.ddragon_version, '.', 2)
        = split_part(observed.game_version, '.', 2)
WHERE i.item_id IS NULL
GROUP BY
    observed.slot_name,
    observed.item_id,
    patch
ORDER BY appearances DESC, observed.item_id
LIMIT 100;