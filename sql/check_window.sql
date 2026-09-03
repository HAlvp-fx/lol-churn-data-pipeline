-- historical time between matches
WITH player_matches AS (
    SELECT
        pm.puuid,
        m.game_creation_at,
        LAG(m.game_creation_at) OVER (
            PARTITION BY pm.puuid
            ORDER BY m.game_creation_at
        ) AS previous_match_at
    FROM player_matches_silver AS pm
    INNER JOIN matches_silver AS m
        ON pm.match_id = m.match_id
    WHERE m.game_creation_at < TIMESTAMP '2026-08-20'
),

gaps AS (
    SELECT
        puuid,
        EXTRACT(EPOCH FROM (game_creation_at - previous_match_at)) / 86400.0 
        AS gap_days
    FROM player_matches
    WHERE previous_match_at IS NOT NULL
),
/*
SELECT
    COUNT(*) AS total_gaps,
    ROUND(AVG(gap_days)::NUMERIC, 2) AS avg_gap_days,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY gap_days)::NUMERIC, 2) 
    AS p50,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY gap_days)::NUMERIC, 2) 
    AS p75,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY gap_days)::NUMERIC, 2)
     AS p90,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY gap_days)::NUMERIC, 2)
     AS p95,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY gap_days)::NUMERIC, 2)
     AS p99,
    MAX(gap_days) AS max_gap_days
FROM gaps;
*/

--con los pcts garndes apunta todo a q hay un grupo q no juega en mi ventana de 90
-- y q hay muchos q tienen un gap de menos de 1 semana entre juegos
player_gaps AS (
    SELECT
        puuid,
        MAX(gap_days) AS max_gap_days
    FROM gaps
    GROUP BY puuid
)

SELECT
    COUNT(*) AS total_gaps,
    COUNT(*) FILTER (WHERE gap_days >= 7) AS gaps_7d,
    ROUND(100.0 * COUNT(*) FILTER (WHERE gap_days >= 7) / COUNT(*),2) 
    AS pct_gaps_7d,

    COUNT(*) FILTER (WHERE gap_days >= 15) AS gaps_15d,
    ROUND( 100.0 * COUNT(*) FILTER (WHERE gap_days >= 15) / COUNT(*), 2) 
    AS pct_gaps_15d,

    COUNT(*) FILTER (WHERE gap_days >= 30) AS gaps_30d,
    ROUND(100.0 * COUNT(*) FILTER (WHERE gap_days >= 30) / COUNT(*), 2) 
    AS pct_gaps_30d

FROM gaps;

-- checking how many matches each cohort player has
WITH player_match_counts AS (
    SELECT
        p.puuid,
        COUNT(pm.match_id) AS matches_observed
    FROM players_silver AS p
    LEFT JOIN player_matches_silver AS pm
        ON p.puuid = pm.puuid
    GROUP BY p.puuid
)
-- para comprobar cnts jugadores sin matches o con un solo match tengo en la muestra
SELECT
    COUNT(*) AS players,

    COUNT(*) FILTER (WHERE matches_observed = 0) AS zero_matches,
    COUNT(*) FILTER (WHERE matches_observed = 1) AS one_match,
    COUNT(*) FILTER (WHERE matches_observed >= 2) AS two_or_more,

    MIN(matches_observed) AS min_matches,
    ROUND(AVG(matches_observed), 2) AS avg_matches,
    MAX(matches_observed) AS max_matches

FROM player_match_counts;
-- dist de la frecuenci de partidas de los jugadores por rango. METO LOS PERCENTILES Y LA MEDIANA PQ CON LA MEDIA ABIA COSAS RARAS
WITH player_match_counts AS (
    SELECT
        p.puuid,
        p.sampling_tier,
        COUNT(pm.match_id) AS matches_observed
    FROM players_silver AS p
    LEFT JOIN player_matches_silver AS pm
        ON p.puuid = pm.puuid
    GROUP BY
        p.puuid,
        p.sampling_tier
)

SELECT
    sampling_tier,
    COUNT(*) AS players,
    COUNT(*) FILTER (WHERE matches_observed = 0) AS zero_matches,
    COUNT(*) FILTER (WHERE matches_observed = 1) AS one_match,
    COUNT(*) FILTER (WHERE matches_observed >= 2) AS two_or_more,
    ROUND(AVG(matches_observed), 2) AS avg_matches,
    ROUND( PERCENTILE_CONT(0.25)WITHIN GROUP (ORDER BY matches_observed)::NUMERIC, 1) 
    AS p25,

    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY matches_observed)::NUMERIC,1) 
    AS median,

    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY matches_observed)::NUMERIC,1) 
    AS p75,

    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY matches_observed)::NUMERIC, 1) 
    AS p90,

    MAX(matches_observed) AS max_matches

FROM player_match_counts
GROUP BY sampling_tier
ORDER BY
    CASE sampling_tier
        WHEN 'IRON' THEN 1
        WHEN 'BRONZE' THEN 2
        WHEN 'SILVER' THEN 3
        WHEN 'GOLD' THEN 4
        WHEN 'PLATINUM' THEN 5
        WHEN 'EMERALD' THEN 6
        WHEN 'DIAMOND' THEN 7
    END;