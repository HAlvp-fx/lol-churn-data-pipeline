CREATE TABLE IF NOT EXISTS player_features_gold(
    puuid TEXT PRIMARY KEY,
    sampling_tier VARCHAR(15),
    sampling_division VARCHAR(5),
    tier TEXT,
    rank TEXT,
    league_points INTEGER,
    wins INTEGER,
    losses INTEGER,
    total_ranked_games INTEGER,
    -- rank context at T0
    veteran BOOLEAN,
    inactive BOOLEAN,
    fresh_blood BOOLEAN,
    hot_streak BOOLEAN,
    -- activ
    matches_15d INTEGER,
    matches_30d INTEGER,
    matches_60d INTEGER,
    matches_90d INTEGER,
    active_days_15d INTEGER,
    active_days_90d INTEGER,
    days_since_last_match INTEGER,
    avg_between_matches_15d FLOAT,
    avg_between_matches_90d FLOAT,
    activity_change FLOAT,
    gap_change FLOAT,
    -- match duration
    avg_match_duration_15d FLOAT,
    avg_match_duration_90d FLOAT,
    match_duration_change FLOAT,

    -- role/ champ
    main_role VARCHAR(21),
    main_role_share FLOAT,
    role_switch_rate FLOAT,
    main_champion_id INTEGER,
    unique_champions INTEGER,
    main_champion_share FLOAT,
    off_role_champion_rate FLOAT,

    -- performance,
    relative_damage FLOAT,
    relative_gold FLOAT,
    relative_farming FLOAT,
    relative_vision FLOAT,
    recent_performance_change FLOAT,
    objective_damage FLOAT,
    avg_time_dead_change FLOAT,

    -- social
    unique_teammates INTEGER,
    repeat_teammate_rate FLOAT,
    max_teammate_match_share FLOAT,
    repeat_teammate_rate_15d FLOAT,
    social_change FLOAT,

    -- patch meta
    patches_played INTEGER,
    meta_adoption_rate FLOAT,
    champion_switch_rate_between_patches FLOAT

);

INSERT INTO player_features_gold (
    puuid,
    sampling_tier,
    sampling_division,
    tier,
    rank,
    league_points,
    wins,
    losses,
    total_ranked_games,
    veteran,
    inactive,
    fresh_blood,
    hot_streak,
    matches_15d,
    matches_30d,
    matches_60d,
    matches_90d,
    active_days_15d,
    active_days_90d,
    days_since_last_match,
    avg_between_matches_15d,
    avg_between_matches_90d,
    activity_change,
    gap_change,
    avg_match_duration_15d,
    avg_match_duration_90d,
    match_duration_change,
    main_role,
    main_role_share,
    role_switch_rate,
    main_champion_id,
    avg_time_dead_change,
    unique_champions,
    main_champion_share,
    off_role_champion_rate,
    relative_damage,
    relative_gold,
    relative_farming,
    relative_vision,
    recent_performance_change,
    objective_damage,
    unique_teammates,
    repeat_teammate_rate,
    max_teammate_match_share,
    repeat_teammate_rate_15d,
    social_change,
    patches_played,
    meta_adoption_rate,
    champion_switch_rate_between_patches
)
--To avpid rep t0
WITH params AS (SELECT TIMESTAMP '2026-08-20 00:00:00' AS t0),
--Boque silver matches (unir con player matches)
historical_matches AS (
    SELECT pms.*,
    mas.game_creation_at
    FROM player_matches_silver AS pms
    INNER JOIN matches_silver as mas
        ON pms.match_id = mas.match_id
    CROSS JOIN params AS prm
    WHERE mas.game_creation_at < prm.t0),

-- to get the gaps in between matches (this is a cte just to be used in the next one)
--(I tried to do it all at once but it was messier...)
match_gaps AS (
    SELECT hstm.puuid,
        hstm.game_creation_at,

        LAG(hstm.game_creation_at) OVER (
            PARTITION BY hstm.puuid
            ORDER BY hstm.game_creation_at
        ) AS previous_match_at
    FROM historical_matches AS hstm
),

--cal matches number and gasp (I changed it to match gaps rather than historical matches bc I have the lag col in that one)
activity_features AS (
    SELECT mchgp.puuid,

    COUNT(*) FILTER(WHERE mchgp.game_creation_at >= (prm.t0 - INTERVAL '15 days'))
    AS matches_15d,
    COUNT(*) FILTER(WHERE mchgp.game_creation_at >= (prm.t0 - INTERVAL '30 days'))
    AS matches_30d,
    COUNT(*) FILTER(WHERE mchgp.game_creation_at >= (prm.t0 - INTERVAL '60 days'))
    AS matches_60d,
    COUNT(*) FILTER(WHERE mchgp.game_creation_at >= (prm.t0 - INTERVAL '90 days'))
    AS matches_90d,
    COUNT(DISTINCT DATE(mchgp.game_creation_at)) FILTER(WHERE mchgp.game_creation_at >= (prm.t0 - INTERVAL '15 days'))
    AS active_days_15d,
    COUNT(DISTINCT DATE(mchgp.game_creation_at)) FILTER(WHERE mchgp.game_creation_at >= (prm.t0 - INTERVAL '90 days'))
    AS active_days_90d,
    prm.t0:: date - MAX(mchgp.game_creation_at)::date AS days_since_last_match,
    
    --This part is a bit confusing but in theory it is correct? it looks more complex than what it is
    --from inside out: dif between the dates of current match and last one, then conversion to seconds and ten to days (fromdate)
    -- and  then the avg. The filter is the same as used in the counts to filter by a peirod of x days and the other is do discard the null values (first match recorded basically)
    AVG(EXTRACT(EPOCH FROM (mchgp.game_creation_at - mchgp.previous_match_at)) / 86400.0) 
        FILTER (WHERE mchgp.game_creation_at >= prm.t0 - INTERVAL '15 days'
              AND mchgp.previous_match_at IS NOT NULL) 
    AS avg_between_matches_15d,
    AVG( EXTRACT(EPOCH FROM (mchgp.game_creation_at - mchgp.previous_match_at)) / 86400.0)
        FILTER (WHERE mchgp.game_creation_at >= prm.t0 - INTERVAL '90 days'
              AND mchgp.previous_match_at IS NOT NULL) 
    AS avg_between_matches_90d
    FROM match_gaps AS mchgp
    CROSS JOIN params AS prm
    GROUP BY mchgp.puuid, prm.t0),

duration_features AS (
    SELECT hstm.puuid,
    AVG(hstm.time_played/ 60.0) FILTER (WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '15 days') 
    AS avg_match_duration_15d,
    AVG(hstm.time_played/ 60.0) FILTER (WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days') 
    AS avg_match_duration_90d
    FROM historical_matches AS hstm
    CROSS JOIN params AS prm
    GROUP BY hstm.puuid
)

SELECT
    psil.puuid,
    psil.sampling_tier,
    psil.sampling_division ,
    psil.tier ,
    psil.rank ,
    psil.league_points ,
    psil.wins ,
    psil.losses ,
    psil.total_ranked_games ,
    psil.veteran ,
    psil.inactive ,
    psil.fresh_blood ,
    psil.hot_streak ,
    -- activ
    matches_15d ,
    matches_30d ,
    matches_60d ,
    matches_90d ,
    active_days_15d ,
    active_days_90d ,
    days_since_last_match ,
    avg_between_matches_15d ,
    avg_between_matches_90d ,
    (matches_15d/15.0)- (matches_90d/90.0) AS activity_change,
    avg_between_matches_15d - avg_between_matches_90d AS gap_change ,
    -- Durat
    avg_match_duration_15d,
    avg_match_duration_90d,
    avg_match_duration_15d - avg_match_duration_90d AS  match_duration_change,


FROM players_silver AS psil
LEFT JOIN activity_features AS af
    ON psil.puuid = af.puuid
LEFT JOIN duration_features AS df
    ON psil.puuid = df.puuid;


CREATE TABLE IF NOT EXISTS player_target_gold (
    puuid TEXT PRIMARY KEY,
    matches_next_7d INTEGER,
    matches_next_15d INTEGER,
    inactive_7d BOOLEAN,
    disengaged_15d BOOLEAN,
    first_match_after_t0 TIMESTAMP,
    days_to_next_match DOUBLE PRECISION
);