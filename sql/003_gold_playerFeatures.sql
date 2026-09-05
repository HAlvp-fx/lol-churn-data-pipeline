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

    -- role / champion
    main_role VARCHAR(21),
    main_role_share FLOAT,
    role_switch_rate FLOAT,
    champion_switch_rate FLOAT,
    main_champion_id INTEGER,
    unique_champions INTEGER,
    main_champion_share FLOAT,

    -- performance,
    relative_damage_15d FLOAT,
    relative_damage_90d FLOAT,
    damage_change FLOAT,

    relative_gold_15d FLOAT,
    relative_gold_90d FLOAT,
    gold_change FLOAT,

    avg_dead_time_share_15d FLOAT,
    avg_dead_time_share_90d FLOAT,
    dead_time_share_change FLOAT,

    surrender_rate_15d FLOAT,
    surrender_rate_90d FLOAT,
    surrender_rate_change FLOAT,

    relative_lobby_level_change FLOAT,

    -- social
    unique_teammates INTEGER,
    repeat_teammate_rate FLOAT,
    max_teammate_match_share FLOAT,

    -- patch meta
    observed_meta_adoption_rate FLOAT

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
    champion_switch_rate,
    main_champion_id,
    unique_champions,
    main_champion_share,
    relative_damage_15d,
    relative_damage_90d,
    damage_change,
    relative_gold_15d,
    relative_gold_90d,
    gold_change,
    avg_dead_time_share_15d ,
    avg_dead_time_share_90d ,
    dead_time_share_change ,
    surrender_rate_15d ,
    surrender_rate_90d ,
    surrender_rate_change ,
    relative_lobby_level_change ,
    unique_teammates ,
    repeat_teammate_rate ,
    max_teammate_match_share ,
    observed_meta_adoption_rate
)
--To avpid rep t0
WITH params AS (SELECT TIMESTAMP '2026-08-20 00:00:00' AS t0),
--Boque silver matches (unir con player matches)
historical_matches AS (
    SELECT pms.*,
    mas.game_creation_at,
    mas.game_version
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
),

role_counts AS (
    SELECT hstm.puuid,
        hstm.team_position,
        COUNT(*) AS role_matches,
        ROW_NUMBER() OVER ( PARTITION BY hstm.puuid ORDER BY COUNT(*) DESC) 
        AS role_rank
    FROM historical_matches AS hstm
    CROSS JOIN params AS prm
    WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days'
      AND hstm.team_position <> ''
    GROUP BY hstm.puuid, hstm.team_position),
main_role_features AS (
    SELECT rlct.puuid,
        rlct.team_position AS main_role,
        rlct.role_matches
    FROM role_counts AS rlct
    WHERE rlct.role_rank = 1),

champion_counts AS (
    SELECT hstm.puuid,
        hstm.champion_id,
        COUNT(*) AS champion_matches,
        ROW_NUMBER() OVER ( PARTITION BY hstm.puuid ORDER BY COUNT(*) DESC) 
        AS champion_rank,
        COUNT(*) OVER ( PARTITION BY hstm.puuid) AS unique_champions
    FROM historical_matches AS hstm
    CROSS JOIN params AS prm
    WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days'
    GROUP BY hstm.puuid, hstm.champion_id),
main_champion_features AS (
    SELECT chct.puuid,
        chct.champion_id AS main_champion_id,
        chct.champion_matches,
        chct.unique_champions
    FROM champion_counts AS chct
    WHERE chct.champion_rank = 1),

role_champion_behavior AS (
    SELECT hstm.puuid,
        hstm.team_position,
        hstm.champion_id,
        LAG(hstm.team_position) OVER ( PARTITION BY hstm.puuid ORDER BY hstm.game_creation_at) 
        AS previous_role,
        LAG(hstm.champion_id) OVER ( PARTITION BY hstm.puuid ORDER BY hstm.game_creation_at) 
        AS previous_champion_id

    FROM historical_matches AS hstm
    CROSS JOIN params AS prm
    WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days'
      AND hstm.team_position <> ''
),
switch_features AS (
    SELECT rcb.puuid,

     AVG(CASE
             WHEN rcb.previous_role IS NULL THEN NULL
            WHEN rcb.team_position <> rcb.previous_role THEN 1.0
            ELSE 0.0
        END) 
    AS role_switch_rate,
    AVG(CASE
            WHEN rcb.previous_champion_id IS NULL THEN NULL
            WHEN rcb.champion_id <> rcb.previous_champion_id THEN 1.0
            ELSE 0.0
        END) 
    AS champion_switch_rate

    FROM role_champion_behavior AS rcb
    GROUP BY rcb.puuid),


performance_features AS (
    SELECT hstm.puuid,
    -- relative damage vs average of the other 4 teammates
    AVG(hstm.total_damage_dealt_to_champions/ NULLIF(
        ( CASE
            WHEN hstm.team_id = 100 THEN mas.t100_total_damage_dealt_to_champions
            WHEN hstm.team_id = 200 THEN mas.t200_total_damage_dealt_to_champions
            END
            - hstm.total_damage_dealt_to_champions
        ) / 4.0, 0))
        FILTER ( WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '15 days') 
        AS relative_damage_15d,
    AVG(hstm.total_damage_dealt_to_champions/ NULLIF(
        (CASE
            WHEN hstm.team_id = 100 THEN mas.t100_total_damage_dealt_to_champions
            WHEN hstm.team_id = 200 THEN mas.t200_total_damage_dealt_to_champions
            END
            - hstm.total_damage_dealt_to_champions ) / 4.0, 0))
        FILTER ( WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days') 
        AS relative_damage_90d,

    -- relative gold vs average of the other 4 teammates
    AVG(hstm.gold_earned / NULLIF(
                (CASE
                    WHEN hstm.team_id = 100 THEN mas.t100_gold_earned
                    WHEN hstm.team_id = 200 THEN mas.t200_gold_earned
                    END
                - hstm.gold_earned) / 4.0, 0))
        FILTER ( WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '15 days') 
        AS relative_gold_15d,
    AVG( hstm.gold_earned/ NULLIF(
                (CASE
                    WHEN hstm.team_id = 100 THEN mas.t100_gold_earned
                    WHEN hstm.team_id = 200 THEN mas.t200_gold_earned
                END - hstm.gold_earned ) / 4.0, 0 ))
        FILTER ( WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days') 
        AS relative_gold_90d,

    -- share of match time spent dead
    AVG( hstm.total_time_spent_dead/ NULLIF(hstm.time_played, 0)::FLOAT )
        FILTER ( WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '15 days') 
        AS avg_dead_time_share_15d,
    AVG( hstm.total_time_spent_dead/ NULLIF(hstm.time_played, 0)::FLOAT)
        FILTER ( WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days') 
        AS avg_dead_time_share_90d,

    -- proportion of matches ending in surrender
    AVG(CASE WHEN hstm.game_ended_in_surrender THEN 1.0 ELSE 0.0 END)
        FILTER (WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '15 days') 
        AS surrender_rate_15d,
    AVG(CASE  WHEN hstm.game_ended_in_surrender THEN 1.0 ELSE 0.0 END)
        FILTER (WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days') 
        AS surrender_rate_90d,

    -- change in player's level relative to lobby average
    AVG( hstm.summoner_level - mas.avg_summoner_level)
        FILTER ( WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '15 days')
    - AVG(hstm.summoner_level - mas.avg_summoner_level)
        FILTER ( WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days') 
    AS relative_lobby_level_change

    FROM historical_matches AS hstm
    INNER JOIN matches_silver AS mas
        ON hstm.match_id = mas.match_id
    CROSS JOIN params AS prm
    GROUP BY hstm.puuid
),
teammate_edges AS (
    SELECT player_1_puuid AS puuid,
        player_2_puuid AS teammate_puuid,
        matches_together
    FROM teammates_silver
    UNION ALL
    SELECT  player_2_puuid AS puuid,
        player_1_puuid AS teammate_puuid,
        matches_together
    FROM teammates_silver
),
social_features AS (
    SELECT te.puuid,
    COUNT(DISTINCT te.teammate_puuid) AS unique_teammates,
    AVG(CASE
            WHEN te.matches_together > 1 THEN 1.0
            ELSE 0.0
            END) 
        AS repeat_teammate_rate,
    MAX(te.matches_together)/ NULLIF(SUM(te.matches_together) / 4.0, 0)
        AS max_teammate_match_share
    FROM teammate_edges AS te
    INNER JOIN players_silver AS psil
        ON te.puuid = psil.puuid
    GROUP BY te.puuid
),
-- all player choices that can react to patch changes
meta_choices AS (
    -- champion
    SELECT
        hstm.match_id,
        hstm.puuid,
        split_part(hstm.game_version, '.', 1)::INTEGER AS patch_major,
        split_part(hstm.game_version, '.', 2)::INTEGER AS patch_minor,
        'CHAMPION' AS meta_type,
        hstm.champion_id AS meta_id
    FROM historical_matches AS hstm
    CROSS JOIN params AS prm
    WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days'
      AND hstm.champion_id IS NOT NULL
    UNION ALL

    -- items
    SELECT
        hstm.match_id,
        hstm.puuid,
        split_part(hstm.game_version, '.', 1)::INTEGER AS patch_major,
        split_part(hstm.game_version, '.', 2)::INTEGER AS patch_minor,
        'ITEM' AS meta_type,
        itm.item_id AS meta_id
    FROM historical_matches AS hstm
    CROSS JOIN LATERAL unnest(
        ARRAY[ hstm.item_0, hstm.item_1, hstm.item_2, hstm.item_3,
            hstm.item_4, hstm.item_5, hstm.item_6]) 
        AS itm(item_id)
    CROSS JOIN params AS prm
    WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days'
      AND itm.item_id IS NOT NULL
      AND itm.item_id <> 0
    UNION ALL

    -- summoner spells
    SELECT
        hstm.match_id,
        hstm.puuid,
        split_part(hstm.game_version, '.', 1)::INTEGER AS patch_major,
        split_part(hstm.game_version, '.', 2)::INTEGER AS patch_minor,
        'SUMMONER_SPELL' AS meta_type,
        spl.spell_id AS meta_id
    FROM historical_matches AS hstm
    CROSS JOIN LATERAL unnest(ARRAY[hstm.summoner_1_id, hstm.summoner_2_id]) 
    AS spl(spell_id)
    CROSS JOIN params AS prm
    WHERE hstm.game_creation_at >= prm.t0 - INTERVAL '90 days'
      AND spl.spell_id IS NOT NULL
),
-- popularity of each choice by patch (This is basically so I can create a pseudo meta)
meta_popularity AS (
    SELECT
        mp.*,
        LAG(mp.pick_rate) 
        OVER ( PARTITION BY mp.meta_type, mp.meta_id ORDER BY mp.patch_major, mp.patch_minor) 
        AS previous_pick_rate,

        LAG(mp.patch_major) 
        OVER (PARTITION BY mp.meta_type, mp.meta_id ORDER BY mp.patch_major, mp.patch_minor) 
        AS previous_patch_major,

        LAG(mp.patch_minor) 
        OVER ( PARTITION BY mp.meta_type, mp.meta_id ORDER BY mp.patch_major, mp.patch_minor) 
        AS previous_patch_minor

    FROM (
        SELECT mc.patch_major,
        mc.patch_minor,
        mc.meta_type,
        mc.meta_id,
        COUNT(DISTINCT (mc.match_id, mc.puuid))::FLOAT
        / NULLIF(SUM(COUNT(DISTINCT (mc.match_id, mc.puuid))
            ) FILTER (WHERE mc.meta_type = 'CHAMPION') 
            OVER ( PARTITION BY mc.patch_major, mc.patch_minor), 0) 
            AS pick_rate
        FROM meta_choices AS mc
        GROUP BY mc.patch_major, mc.patch_minor, mc.meta_type, mc.meta_id) 
        AS mp
),
-- player alignment with rising patch choices
meta_features AS (
    SELECT
        player_meta.puuid,
        AVG(player_meta.meta_adoption_rate)
            AS observed_meta_adoption_rate

    FROM ( SELECT
            mc.puuid,
            mc.meta_type,
            AVG(CASE
                -- In case there is no prev observation
                WHEN mp.previous_pick_rate IS NULL THEN NULL

                -- to not compare non-consecutive patches
                WHEN NOT (
                    mp.patch_major = mp.previous_patch_major
                    AND mp.patch_minor = mp.previous_patch_minor + 1) 
                THEN NULL
                -- choice became more popular in the atch
                WHEN mp.pick_rate > mp.previous_pick_rate THEN 1.0
                ELSE 0.0
                END) 
            AS meta_adoption_rate
        FROM meta_choices AS mc
        INNER JOIN meta_popularity AS mp
            ON mc.patch_major = mp.patch_major
            AND mc.patch_minor = mp.patch_minor
            AND mc.meta_type = mp.meta_type
            AND mc.meta_id = mp.meta_id
        GROUP BY mc.puuid, mc.meta_type) 
    AS player_meta
    GROUP BY player_meta.puuid
),


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
    --roles and champ
    mrf.main_role,
    mrf.role_matches/ NULLIF(af.matches_90d, 0)::FLOAT AS main_role_share,
    swf.role_switch_rate,
    swf.champion_switch_rate,
    mcf.main_champion_id,
    mcf.unique_champions,
    mcf.champion_matches/ NULLIF(af.matches_90d, 0)::FLOAT AS main_champion_share,
    --performance
    perf.relative_damage_15d,
    perf.relative_damage_90d,
    perf.relative_damage_15d - perf.relative_damage_90d AS damage_change,
    perf.relative_gold_15d,
    perf.relative_gold_90d,
    perf.relative_gold_15d- perf.relative_gold_90d AS gold_change,
    perf.avg_dead_time_share_15d,
    perf.avg_dead_time_share_90d,
    perf.avg_dead_time_share_15d- perf.avg_dead_time_share_90d AS dead_time_share_change,
    perf.surrender_rate_15d,
    perf.surrender_rate_90d,
    perf.surrender_rate_15d- perf.surrender_rate_90d AS surrender_rate_change,
    perf.relative_lobby_level_change,
    -- social
    socf.unique_teammates,
    socf.repeat_teammate_rate,
    socf.max_teammate_match_share,
    --meta
    metf.observed_meta_adoption_rate


FROM players_silver AS psil
LEFT JOIN activity_features AS af
    ON psil.puuid = af.puuid
LEFT JOIN duration_features AS df
    ON psil.puuid = df.puuid
LEFT JOIN main_role_features AS mrf
    ON psil.puuid = mrf.puuid
LEFT JOIN main_champion_features AS mcf
    ON psil.puuid = mcf.puuid 
LEFT JOIN switch_features AS swf
    ON psil.puuid = swf.puuid
LEFT JOIN performance_features AS perf
    ON psil.puuid = perf.puuid 
LEFT JOIN social_features AS socf
    ON psil.puuid = socf.puuid
LEFT JOIN meta_features AS metf
    ON psil.puuid = metf.puuid;


CREATE TABLE IF NOT EXISTS player_target_gold (
    puuid TEXT PRIMARY KEY,
    matches_next_7d INTEGER,
    matches_next_15d INTEGER,
    inactive_7d BOOLEAN,
    disengaged_15d BOOLEAN,
    first_match_after_t0 TIMESTAMP,
    days_to_next_match DOUBLE PRECISION
);