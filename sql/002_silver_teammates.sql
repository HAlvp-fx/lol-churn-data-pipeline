CREATE TABLE IF NOT EXISTS teammates_silver (
    -- Unique teammate pairs observed in the same team.
    -- I'm keeping all pairs here and recurrent teammate thresholds will be decided in Gold
    player_1_puuid TEXT NOT NULL,
    player_2_puuid TEXT NOT NULL,
    --stats
    matches_together INTEGER NOT NULL,
    wins_together INTEGER NOT NULL,
    losses_together INTEGER NOT NULL,

    -- Player 1 roles
    p1_top_matches INTEGER NOT NULL,
    p1_jungle_matches INTEGER NOT NULL,
    p1_middle_matches INTEGER NOT NULL,
    p1_bottom_matches INTEGER NOT NULL,
    p1_utility_matches INTEGER NOT NULL,

    -- Player 2 rols
    p2_top_matches INTEGER NOT NULL,
    p2_jungle_matches INTEGER NOT NULL,
    p2_middle_matches INTEGER NOT NULL,
    p2_bottom_matches INTEGER NOT NULL,
    p2_utility_matches INTEGER NOT NULL,

    PRIMARY KEY (player_1_puuid, player_2_puuid)
);
-- teh logic of this is a bit more tricky but I saw examples of it working
-- and it is better to fo it in sql than in python (it's jist more efficient)
INSERT INTO teammates_silver (
    player_1_puuid,
    player_2_puuid,
    matches_together,
    wins_together,
    losses_together,
    p1_top_matches,
    p1_jungle_matches,
    p1_middle_matches,
    p1_bottom_matches,
    p1_utility_matches,
    p2_top_matches,
    p2_jungle_matches,
    p2_middle_matches,
    p2_bottom_matches,
    p2_utility_matches
)
SELECT
    p1.puuid AS player_1_puuid,
    p2.puuid AS player_2_puuid,
    COUNT(DISTINCT p1.match_id)::INTEGER AS matches_together,
    COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.win = TRUE)::INTEGER AS wins_together,
    COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.win = FALSE)::INTEGER AS losses_together,

    -- Player 1 roles
    COUNT(DISTINCT p1.match_id) FILTER (WHERE p1.team_position = 'TOP')::INTEGER AS p1_top_matches,
    COUNT(DISTINCT p1.match_id) FILTER ( WHERE p1.team_position = 'JUNGLE')::INTEGER AS p1_jungle_matches,
    COUNT(DISTINCT p1.match_id) FILTER ( WHERE p1.team_position = 'MIDDLE')::INTEGER AS p1_middle_matches,
    COUNT(DISTINCT p1.match_id) FILTER ( WHERE p1.team_position = 'BOTTOM' )::INTEGER AS p1_bottom_matches,
    COUNT(DISTINCT p1.match_id) FILTER ( WHERE p1.team_position = 'UTILITY')::INTEGER AS p1_utility_matches,

    -- Player 2 roles
    COUNT(DISTINCT p1.match_id) FILTER (WHERE p2.team_position = 'TOP')::INTEGER AS p2_top_matches,
    COUNT(DISTINCT p1.match_id) FILTER ( WHERE p2.team_position = 'JUNGLE')::INTEGER AS p2_jungle_matches,
    COUNT(DISTINCT p1.match_id) FILTER (WHERE p2.team_position = 'MIDDLE')::INTEGER AS p2_middle_matches,
    COUNT(DISTINCT p1.match_id) FILTER ( WHERE p2.team_position = 'BOTTOM' )::INTEGER AS p2_bottom_matches,
    COUNT(DISTINCT p1.match_id) FILTER ( WHERE p2.team_position = 'UTILITY')::INTEGER AS p2_utility_matches

FROM player_matches_bronze AS p1--base table for the matches

INNER JOIN player_matches_bronze AS p2
    ON p1.match_id = p2.match_id
    AND p1.team_id = p2.team_id

    -- Thiseeps each pair only once: A-B yes B-A no A-A no
    AND p1.puuid < p2.puuid
WHERE EXISTS (SELECT 1 FROM players_bronze AS cohort
    WHERE cohort.puuid = p1.puuid
       OR cohort.puuid = p2.puuid)
       --This part here checks if at least one of the players is my tracked cohort (using the players in bronze as  filter (like silver player macthes))

GROUP BY p1.puuid, p2.puuid

ON CONFLICT (player_1_puuid, player_2_puuid)
DO UPDATE SET
    matches_together = EXCLUDED.matches_together,
    wins_together = EXCLUDED.wins_together,
    losses_together = EXCLUDED.losses_together,

    p1_top_matches = EXCLUDED.p1_top_matches,
    p1_jungle_matches = EXCLUDED.p1_jungle_matches,
    p1_middle_matches = EXCLUDED.p1_middle_matches,
    p1_bottom_matches = EXCLUDED.p1_bottom_matches,
    p1_utility_matches = EXCLUDED.p1_utility_matches,

    p2_top_matches = EXCLUDED.p2_top_matches,
    p2_jungle_matches = EXCLUDED.p2_jungle_matches,
    p2_middle_matches = EXCLUDED.p2_middle_matches,
    p2_bottom_matches = EXCLUDED.p2_bottom_matches,
    p2_utility_matches = EXCLUDED.p2_utility_matches;