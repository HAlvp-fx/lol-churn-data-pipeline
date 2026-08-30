-- PLAYER MATCHES PROFILING
-- Used to support Bronze to Silver field selection decisions
-- Mainly which ones are safe to colapse into a single category

--PLAYER POSITION AND ROLE EXPLORATION
/*
SELECT
    individual_position,
    team_position,
    lane,
    role,
    position_assigned_by_matchmaking,
    selected_role_preferences,
    COUNT(*) AS rows
FROM player_matches_bronze
GROUP BY
    individual_position,
    team_position,
    lane,
    role,
    selected_role_preferences,
    position_assigned_by_matchmaking
ORDER BY rows DESC;

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE individual_position = team_position
    ) AS same_position,

    COUNT(*) FILTER (
        WHERE individual_position IS DISTINCT FROM team_position
    ) AS different_position

FROM player_matches_bronze;
SELECT
    individual_position,
    team_position,
    COUNT(*) AS rows
FROM player_matches_bronze
WHERE individual_position IS DISTINCT FROM team_position
GROUP BY
    individual_position,
    team_position
ORDER BY rows DESC;

SELECT
    individual_position,
    team_position,
    lane,
    role,
    position_assigned_by_matchmaking,
    selected_role_preferences,
    COUNT(*) AS rows
FROM player_matches_bronze
WHERE individual_position IS DISTINCT FROM team_position
GROUP BY
    individual_position,
    team_position,
    lane,
    role,
    position_assigned_by_matchmaking,
    selected_role_preferences
ORDER BY rows DESC
LIMIT 30;
*/

-- DAMAGE KILLS ETC ANALYSIS
--SELECT
    --COUNT(*) AS total_rows,

    --COUNT(*) FILTER (WHERE double_kills > 0) AS with_double,

    --COUNT(*) FILTER (WHERE triple_kills > 0) AS with_triple,

    --COUNT(*) FILTER (WHERE quadra_kills > 0) AS with_quadra,

    --COUNT(*) FILTER (WHERE penta_kills > 0) AS with_penta,

    --COUNT(*) FILTER (WHERE unreal_kills > 0) AS with_unreal

--FROM player_matches_bronze;
--SELECT
    --largest_multi_kill,
    --COUNT(*) AS rows,
    --ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 3) AS percentage
--FROM player_matches_bronze
--GROUP BY largest_multi_kill
--ORDER BY largest_multi_kill;

-- largest multi kill somwhat is a good representation of the distribution of frecuency of the ones above
-- but I think on a player psique level it is different to have a game with 2+ pentakills or similar
-- and one with only one oenta, and reducing it could be too reductive? 
/*
SELECT 
    match_id ,
    participant_id ,
    team_id ,

    summoner_id ,
    summoner_level ,
    riot_id_game_name ,
    riot_id_tagline 
    FROM player_matches_bronze LIMIT 20;
*/


/*
SELECT     game_ended_in_early_surrender ,
    game_ended_in_ignb_surrender ,
    game_ended_in_surrender ,
    team_early_surrendered ,
    team_ignb_surrendered ,
    caused_game_end_from_ignb_surrender ,
    was_premade_with_ignb_game_end_causer ,
    was_premade_with_severe_transgressor ,
    was_severe_transgressor ,
    was_afk  FROM player_matches_bronze LIMIT 5;
*/
/*
SELECT     
    COUNT(*) FILTER (WHERE game_ended_in_early_surrender IS TRUE )/10 AS game_ended_in_early_sur,
    COUNT(*) FILTER (WHERE game_ended_in_ignb_surrender  IS TRUE )/10 AS game_ended_in_ignb_sur,
    COUNT(*) FILTER (WHERE game_ended_in_surrender  IS TRUE )/10 AS game_ended_in_sur,
    COUNT(*) FILTER (WHERE team_early_surrendered  IS TRUE )/5 AS team_early_sur,
    COUNT(*) FILTER (WHERE team_ignb_surrendered  IS TRUE )/5 AS team_ignb_sur,
    COUNT(*) FILTER (WHERE caused_game_end_from_ignb_surrender  IS TRUE )/5 AS caused_game_end_from_ignb_sur,
    COUNT(*) FILTER (WHERE was_premade_with_severe_transgressor IS TRUE )/10 AS was_premade_with_severe_transgrsr,
    COUNT(*) FILTER (WHERE was_severe_transgressor  IS TRUE ) AS was_severe_transgrsr,
    COUNT(*) FILTER (WHERE was_afk  IS TRUE ) AS was_afk
    FROM player_matches_bronze;

-- IGNB = in game neg behavoiur???? Nt sure what to do here -> ignb matches always the was severe transgressor
SELECT
    was_afk,
    was_severe_transgressor,
    game_ended_in_surrender,
    game_ended_in_early_surrender,
    team_ignb_surrendered,
    COUNT(*) AS players
FROM player_matches_bronze
WHERE caused_game_end_from_ignb_surrender IS TRUE
GROUP BY
    was_afk,
    was_severe_transgressor,
    game_ended_in_surrender,
    game_ended_in_early_surrender,
    team_ignb_surrendered
ORDER BY players DESC;
*/

/*
SELECT time_ccing_others, total_time_cc_dealt FROM player_matches_bronze LIMIT 5;

SELECT AVG(time_ccing_others) AS time_ccing_others, AVG(total_time_cc_dealt) AS total_time_cc_dealt FROM player_matches_bronze;
SELECT CORR(time_ccing_others, total_time_cc_dealt) AS cc_correlation
FROM player_matches_bronze
WHERE time_ccing_others IS NOT NULL
  AND total_time_cc_dealt IS NOT NULL; 
*/

/*
SELECT
    nexus_kills,
    nexus_takedowns,
    nexus_lost,
    win,
    COUNT(*) AS rows
FROM player_matches_bronze
GROUP BY
    nexus_kills,
    nexus_takedowns,
    nexus_lost,
    win
ORDER BY rows DESC;

SELECT
    COUNT(*) FILTER (WHERE first_tower_kill) AS first_tower_kill,
    COUNT(*) FILTER (WHERE first_tower_assist) AS first_tower_assist,
    COUNT(*) FILTER (
        WHERE first_tower_kill OR first_tower_assist
    ) AS first_tower_participation
FROM player_matches_bronze;
SELECT
    CORR(turret_kills, turret_takedowns) AS turret_corr,
    CORR(inhibitor_kills, inhibitor_takedowns) AS inhibitor_corr
FROM player_matches_bronze;
SELECT
    COUNT(*) FILTER (WHERE turret_kills > 0) AS turret_kill_rows,
    COUNT(*) FILTER (WHERE turret_takedowns > 0) AS turret_takedown_rows,
    COUNT(*) FILTER (
        WHERE turret_takedowns > 0 AND turret_kills = 0
    ) AS turret_takedown_only_rows
FROM player_matches_bronze;
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE objectives_stolen > 0
    ) AS stolen_rows,

    COUNT(*) FILTER (
        WHERE objectives_stolen_assists > 0
    ) AS stolen_assist_rows,

    COUNT(*) FILTER (
        WHERE objectives_stolen > 0
           OR objectives_stolen_assists > 0
    ) AS stolen_participation_rows,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE objectives_stolen > 0
               OR objectives_stolen_assists > 0
        ) / COUNT(*),
        4
    ) AS participation_pct

FROM player_matches_bronze;
*/
/*
SELECT
    COUNT(*) AS total_rows,

    ROUND(AVG(vision_score), 2) AS avg_vision_score,
    ROUND(AVG(wards_placed), 2) AS avg_wards_placed,
    ROUND(AVG(wards_killed), 2) AS avg_wards_killed,
    ROUND(AVG(detector_wards_placed), 2) AS avg_detector_wards_placed,
    ROUND(AVG(vision_wards_bought_in_game), 2) AS avg_vision_wards_bought,
    ROUND(AVG(sight_wards_bought_in_game), 2) AS avg_sight_wards_bought,

    COUNT(*) FILTER (WHERE vision_score = 0) AS zero_vision_score,
    COUNT(*) FILTER (WHERE wards_placed = 0) AS zero_wards_placed,
    COUNT(*) FILTER (WHERE wards_killed = 0) AS zero_wards_killed,
    COUNT(*) FILTER (WHERE detector_wards_placed = 0) AS zero_detector_wards,
    COUNT(*) FILTER (WHERE vision_wards_bought_in_game = 0) AS zero_vision_wards_bought,
    COUNT(*) FILTER (WHERE sight_wards_bought_in_game = 0) AS zero_sight_wards_bought

FROM player_matches_bronze;

SELECT
    CORR(vision_score, wards_placed) AS vision_wards_placed_corr,
    CORR(vision_score, wards_killed) AS vision_wards_killed_corr,
    CORR(detector_wards_placed, vision_wards_bought_in_game) AS detector_bought_corr,
    CORR(wards_placed, vision_wards_bought_in_game) AS wards_bought_corr
FROM player_matches_bronze;
*/

--PING
/*
SELECT
    COUNT(*) AS total_rows,

    ROUND(AVG(all_in_pings), 2) AS avg_all_in,
    ROUND(AVG(assist_me_pings), 2) AS avg_assist_me,
    ROUND(AVG(basic_pings), 2) AS avg_basic,
    ROUND(AVG(command_pings), 2) AS avg_command,
    ROUND(AVG(danger_pings), 2) AS avg_danger,
    ROUND(AVG(enemy_missing_pings), 2) AS avg_enemy_missing,
    ROUND(AVG(enemy_vision_pings), 2) AS avg_enemy_vision,
    ROUND(AVG(get_back_pings), 2) AS avg_get_back,
    ROUND(AVG(hold_pings), 2) AS avg_hold,
    ROUND(AVG(need_vision_pings), 2) AS avg_need_vision,
    ROUND(AVG(on_my_way_pings), 2) AS avg_on_my_way,
    ROUND(AVG(push_pings), 2) AS avg_push,
    ROUND(AVG(retreat_pings), 2) AS avg_retreat,
    ROUND(AVG(vision_cleared_pings), 2) AS avg_vision_cleared

FROM player_matches_bronze;
SELECT
    ROUND(100.0 * COUNT(*) FILTER (WHERE all_in_pings > 0) / COUNT(*), 2) AS all_in_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE assist_me_pings > 0) / COUNT(*), 2) AS assist_me_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE basic_pings > 0) / COUNT(*), 2) AS basic_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE command_pings > 0) / COUNT(*), 2) AS command_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE danger_pings > 0) / COUNT(*), 2) AS danger_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE enemy_missing_pings > 0) / COUNT(*), 2) AS enemy_missing_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE enemy_vision_pings > 0) / COUNT(*), 2) AS enemy_vision_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE get_back_pings > 0) / COUNT(*), 2) AS get_back_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE hold_pings > 0) / COUNT(*), 2) AS hold_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE need_vision_pings > 0) / COUNT(*), 2) AS need_vision_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE on_my_way_pings > 0) / COUNT(*), 2) AS on_my_way_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE push_pings > 0) / COUNT(*), 2) AS push_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE retreat_pings > 0) / COUNT(*), 2) AS retreat_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE vision_cleared_pings > 0) / COUNT(*), 2) AS vision_cleared_pct

FROM player_matches_bronze; */

/*
--SPELLS
--Esto es oslo para comprobar q esten poblados pq es complicado de ver si no al ser tanto cmapo
SELECT
    ROUND(AVG(spell_1_casts), 2) AS avg_spell_1,
    ROUND(AVG(spell_2_casts), 2) AS avg_spell_2,
    ROUND(AVG(spell_3_casts), 2) AS avg_spell_3,
    ROUND(AVG(spell_4_casts), 2) AS avg_spell_4,

    ROUND(AVG(summoner_1_casts), 2) AS avg_summoner_1,
    ROUND(AVG(summoner_2_casts), 2) AS avg_summoner_2,

    COUNT(*) FILTER (WHERE spell_1_casts = 0) AS zero_spell_1,
    COUNT(*) FILTER (WHERE spell_2_casts = 0) AS zero_spell_2,
    COUNT(*) FILTER (WHERE spell_3_casts = 0) AS zero_spell_3,
    COUNT(*) FILTER (WHERE spell_4_casts = 0) AS zero_spell_4

FROM player_matches_bronze;

SELECT
    summoner_1_id,
    COUNT(*) AS rows
FROM player_matches_bronze
GROUP BY summoner_1_id
ORDER BY rows DESC;

SELECT
    summoner_2_id,
    COUNT(*) AS rows
FROM player_matches_bronze
GROUP BY summoner_2_id
ORDER BY rows DESC;
*/

/*
-- player_behavior
SELECT
    jsonb_object_keys(player_behavior) AS key,
    COUNT(*) AS rows
FROM player_matches_bronze
WHERE player_behavior IS NOT NULL
GROUP BY key
ORDER BY rows DESC;


-- missions
SELECT
    jsonb_object_keys(missions) AS key,
    COUNT(*) AS rows
FROM player_matches_bronze
WHERE missions IS NOT NULL
GROUP BY key
ORDER BY rows DESC;


-- perks
SELECT
    jsonb_object_keys(perks) AS key,
    COUNT(*) AS rows
FROM player_matches_bronze
WHERE perks IS NOT NULL
GROUP BY key
ORDER BY rows DESC;
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE player_behavior IS NULL OR player_behavior = '{}'::jsonb
    ) AS empty_player_behavior,

    COUNT(*) FILTER (
        WHERE missions IS NULL OR missions = '{}'::jsonb
    ) AS empty_missions,

    COUNT(*) FILTER (
        WHERE perks IS NULL OR perks = '{}'::jsonb
    ) AS empty_perks

FROM player_matches_bronze;
*/
SELECT
    COUNT(*) FILTER ( WHERE dragon_kills > 1) AS dragon_kills_study,
    COUNT(*) FILTER ( WHERE baron_kills > 1) AS baron_kills_study
FROM player_matches_bronze ;