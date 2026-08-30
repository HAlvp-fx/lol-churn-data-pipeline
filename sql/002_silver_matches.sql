/*
I have decided to not add fields related to individual player configuration or actions 
into matches_silver when a team-level value would have limited analytical meaning.
This includes champion/summoner spell casts, summoner spell IDs and perks.Detailed multikill 
and killing-spree metrics are also kept only at participant level,as they describe individual 
performance rather than match context.

I'm also omitting redundant or highly outcome-dependent fields (such as nexus-related
 metrics) and poorly documented / very sparse fields are excluded as identified during profiling.

The match table therefore focuses on metrics that provide meaningful team context
for player comparison: combat, economy, farming, damage, support/CC, objectives,
vision and communication
*/

CREATE TABLE IF NOT EXISTS matches_silver (
    -- t100 and t200 represent the teams of the game

    match_id TEXT NOT NULL,
    game_version TEXT NOT NULL,
    tournament_code TEXT,
    time_played INTEGER,
    game_creation_at TIMESTAMP,
    game_start_at TIMESTAMP,
    game_end_at TIMESTAMP,
    game_ended_in_surrender BOOLEAN,
    game_ended_in_early_surrender BOOLEAN,
    winning_team INTEGER,
    afk_players INTEGER,

    t100_players_puuid TEXT[],
    t200_players_puuid TEXT[],
    t100_champions_id INTEGER[],
    t200_champions_id INTEGER[],
    avg_summoner_level FLOAT,
    t100_avg_summoner_lv FLOAT,
    t200_avg_summoner_lv FLOAT,

    --combat
    t100_kills INTEGER,
    t200_kills INTEGER,
    t100_deaths INTEGER,
    t200_deaths INTEGER,
    t100_assists INTEGER,
    t200_assists INTEGER,

    --economy
    t100_gold_earned BIGINT,
    t200_gold_earned BIGINT,
    t100_gold_spent BIGINT,
    t200_gold_spent BIGINT,
    t100_items_purchased INTEGER,
    t200_items_purchased INTEGER,
    t100_consumables_purchased INTEGER,
    t200_consumables_purchased INTEGER,

    --combat (use performance and aggro?)
    t100_total_minions_killed INTEGER,
    t200_total_minions_killed INTEGER,
    t100_neutral_minions_killed INTEGER,
    t200_neutral_minions_killed INTEGER,
    t100_total_ally_jungle_minions_killed INTEGER,
    t200_total_ally_jungle_minions_killed INTEGER,
    t100_total_enemy_jungle_minions_killed INTEGER,
    t200_total_enemy_jungle_minions_killed INTEGER,

    -- damage taken/support/CC
    t100_total_damage_taken BIGINT,
    t200_total_damage_taken BIGINT,
    t100_damage_self_mitigated BIGINT,
    t200_damage_self_mitigated BIGINT,
    t100_total_heal BIGINT,
    t200_total_heal BIGINT,
    t100_total_heals_on_teammates BIGINT,
    t200_total_heals_on_teammates BIGINT,
    t100_total_damage_shielded_on_teammates BIGINT,
    t200_total_damage_shielded_on_teammates BIGINT,
    t100_time_ccing_others BIGINT,
    t200_time_ccing_others BIGINT,
    t100_total_time_cc_dealt BIGINT,
    t200_total_time_cc_dealt BIGINT,

    -- Damages dealt (performance & objectives)
    t100_total_damage_dealt BIGINT,
    t200_total_damage_dealt BIGINT,
    t100_total_damage_dealt_to_champions BIGINT,
    t200_total_damage_dealt_to_champions BIGINT,
    t100_damage_dealt_to_turrets BIGINT,
    t200_damage_dealt_to_turrets BIGINT,
    t100_damage_dealt_to_objectives BIGINT,
    t200_damage_dealt_to_objectives BIGINT,
    t100_damage_dealt_to_epic_monsters BIGINT,
    t200_damage_dealt_to_epic_monsters BIGINT,
    t100_turret_takedowns INTEGER,
    t200_turret_takedowns INTEGER,
    t100_inhibitor_takedowns INTEGER,
    t200_inhibitor_takedowns INTEGER,
    t100_dragon_kills INTEGER,
    t200_dragon_kills INTEGER,
    t100_baron_kills INTEGER,
    t200_baron_kills INTEGER,
    t100_objectives_stolen_participation INTEGER,
    t200_objectives_stolen_participation INTEGER,

    -- Vision (game performance? control? teamplayer?)
    t100_vision_score INTEGER,
    t200_vision_score INTEGER,
    t100_wards_placed INTEGER,
    t200_wards_placed INTEGER,
    t100_wards_killed INTEGER,
    t200_wards_killed INTEGER,
    t100_detector_wards_placed INTEGER,
    t200_detector_wards_placed INTEGER,

    -- PINGS (comunication and engagement?)
    t100_total_pings INTEGER,
    t200_total_pings INTEGER,

    --BANS PER TEAM
    t100_banned_champions_id INTEGER[],
    t200_banned_champions_id INTEGER[],

    PRIMARY KEY (match_id)
);


INSERT INTO matches_silver (
    match_id ,
    game_version,
    tournament_code ,
    time_played ,
    game_creation_at,
    game_start_at ,
    game_end_at ,
    game_ended_in_surrender ,
    game_ended_in_early_surrender ,
    winning_team ,
    afk_players ,

    t100_players_puuid ,
    t200_players_puuid ,
    t100_champions_id ,
    t200_champions_id ,
    avg_summoner_level ,
    t100_avg_summoner_lv ,
    t200_avg_summoner_lv ,

    --combat
    t100_kills ,
    t200_kills ,
    t100_deaths ,
    t200_deaths ,
    t100_assists ,
    t200_assists ,

    --economy
    t100_gold_earned ,
    t200_gold_earned ,
    t100_gold_spent ,
    t200_gold_spent ,
    t100_items_purchased ,
    t200_items_purchased ,
    t100_consumables_purchased ,
    t200_consumables_purchased ,

    --combat (use performance and aggro?)
    t100_total_minions_killed ,
    t200_total_minions_killed ,
    t100_neutral_minions_killed ,
    t200_neutral_minions_killed ,
    t100_total_ally_jungle_minions_killed ,
    t200_total_ally_jungle_minions_killed ,
    t100_total_enemy_jungle_minions_killed ,
    t200_total_enemy_jungle_minions_killed ,

    -- damage taken/support/CC
    t100_total_damage_taken ,
    t200_total_damage_taken ,
    t100_damage_self_mitigated ,
    t200_damage_self_mitigated ,
    t100_total_heal ,
    t200_total_heal ,
    t100_total_heals_on_teammates ,
    t200_total_heals_on_teammates ,
    t100_total_damage_shielded_on_teammates ,
    t200_total_damage_shielded_on_teammates ,
    t100_time_ccing_others ,
    t200_time_ccing_others ,
    t100_total_time_cc_dealt ,
    t200_total_time_cc_dealt ,

    -- Damages dealt (performance & objectives)
    t100_total_damage_dealt ,
    t200_total_damage_dealt ,
    t100_total_damage_dealt_to_champions ,
    t200_total_damage_dealt_to_champions ,
    t100_damage_dealt_to_turrets ,
    t200_damage_dealt_to_turrets ,
    t100_damage_dealt_to_objectives ,
    t200_damage_dealt_to_objectives ,
    t100_damage_dealt_to_epic_monsters ,
    t200_damage_dealt_to_epic_monsters ,
    t100_turret_takedowns ,
    t200_turret_takedowns ,
    t100_inhibitor_takedowns ,
    t200_inhibitor_takedowns ,
    t100_dragon_kills ,
    t200_dragon_kills ,
    t100_baron_kills ,
    t200_baron_kills ,
    t100_objectives_stolen_participation ,
    t200_objectives_stolen_participation ,

    -- Vision (game performance? control? teamplayer?)
    t100_vision_score ,
    t200_vision_score ,
    t100_wards_placed ,
    t200_wards_placed ,
    t100_wards_killed ,
    t200_wards_killed ,
    t100_detector_wards_placed ,
    t200_detector_wards_placed ,

    -- PINGS (comunication and engagement?)
    t100_total_pings ,
    t200_total_pings ,

    --BANS PER TEAM
    t100_banned_champions_id ,
    t200_banned_champions_id
)

SELECT 
    pmbron.match_id,

    -- SAME VALUES (no dist from team 100 or 200)
    MAX(pmbron.game_version) AS game_version,
    MAX(pmbron.tournament_code) AS tournament_code,
    MAX(pmbron.time_played) AS time_played,

    TO_TIMESTAMP(MAX(pmbron.game_creation_timestamp) / 1000.0)
        AT TIME ZONE 'UTC' AS game_creation_at,

    TO_TIMESTAMP(MAX(pmbron.game_start_timestamp) / 1000.0)
        AT TIME ZONE 'UTC' AS game_start_at,

    TO_TIMESTAMP(MAX(pmbron.game_end_timestamp) / 1000.0)
        AT TIME ZONE 'UTC' AS game_end_at,

    --In theory this should return true if at least one of the surrender column in the table has value= true
    BOOL_OR(pmbron.game_ended_in_surrender) AS game_ended_in_surrender,
    BOOL_OR(pmbron.game_ended_in_early_surrender) AS game_ended_in_early_surrender,

    --Winning team-- max could be min too it is just to put the 5 vals in one
    MAX(pmbron.team_id) FILTER (WHERE pmbron.win = TRUE) AS winning_team,

    -- total number of AFK players in te match
    COUNT(*) FILTER (WHERE pmbron.was_afk = TRUE) AS afk_players,
    
     -- team composition
    ARRAY_AGG(pmbron.puuid ORDER BY pmbron.participant_id) FILTER (WHERE pmbron.team_id = 100) 
    AS t100_players_puuid,

    ARRAY_AGG(pmbron.puuid ORDER BY pmbron.participant_id) FILTER (WHERE pmbron.team_id = 200) 
    AS t200_players_puuid,

    ARRAY_AGG(pmbron.champion_id ORDER BY pmbron.participant_id) FILTER (WHERE pmbron.team_id = 100) 
    AS t100_champions_id,

    ARRAY_AGG(pmbron.champion_id ORDER BY pmbron.participant_id) FILTER (WHERE pmbron.team_id = 200)
    AS t200_champions_id,

    -- summoner lev
    AVG(pmbron.summoner_level) AS avg_summoner_level,
    AVG(pmbron.summoner_level) FILTER (WHERE pmbron.team_id = 100) AS t100_avg_summoner_lv,
    AVG(pmbron.summoner_level) FILTER (WHERE pmbron.team_id = 200) AS t200_avg_summoner_lv,

    --combat
    SUM(pmbron.kills) FILTER (WHERE pmbron.team_id=100) AS t100_kills ,
    SUM(pmbron.kills) FILTER (WHERE pmbron.team_id=200) AS t200_kills ,
    SUM(pmbron.deaths) FILTER (WHERE pmbron.team_id=100) AS t100_deaths ,
    SUM(pmbron.deaths) FILTER (WHERE pmbron.team_id=200) AS t200_deaths ,
    SUM(pmbron.assists) FILTER (WHERE pmbron.team_id=100) AS t100_assists ,
    SUM(pmbron.assists) FILTER (WHERE pmbron.team_id=200) AS t200_assists ,

    --econ
    SUM(pmbron.gold_earned) FILTER (WHERE pmbron.team_id=100) AS t100_gold_earned ,
    SUM(pmbron.gold_earned) FILTER (WHERE pmbron.team_id=200) AS t200_gold_earned ,
    SUM(pmbron.gold_spent) FILTER (WHERE pmbron.team_id=100) AS t100_gold_spent ,
    SUM(pmbron.gold_spent) FILTER (WHERE pmbron.team_id=200) AS t200_gold_spent ,
    SUM(pmbron.items_purchased) FILTER (WHERE pmbron.team_id=100) AS t100_items_purchased ,
    SUM(pmbron.items_purchased) FILTER (WHERE pmbron.team_id=200) AS t200_items_purchased ,
    SUM(pmbron.consumables_purchased) FILTER (WHERE pmbron.team_id=100) AS t100_consumables_purchased ,
    SUM(pmbron.consumables_purchased) FILTER (WHERE pmbron.team_id=200) AS t200_consumables_purchased ,

    --combat 
    SUM(pmbron.total_minions_killed) FILTER (WHERE pmbron.team_id=100) AS t100_total_minions_killed ,
    SUM(pmbron.total_minions_killed) FILTER (WHERE pmbron.team_id=200) AS t200_total_minions_killed ,
    SUM(pmbron.neutral_minions_killed) FILTER (WHERE pmbron.team_id=100) AS t100_neutral_minions_killed ,
    SUM(pmbron.neutral_minions_killed) FILTER (WHERE pmbron.team_id=200) AS t200_neutral_minions_killed ,
    SUM(pmbron.total_ally_jungle_minions_killed) FILTER (WHERE pmbron.team_id=100) AS t100_total_ally_jungle_minions_killed ,
    SUM(pmbron.total_ally_jungle_minions_killed) FILTER (WHERE pmbron.team_id=200) AS t200_total_ally_jungle_minions_killed ,
    SUM(pmbron.total_enemy_jungle_minions_killed) FILTER (WHERE pmbron.team_id=100) AS t100_total_enemy_jungle_minions_killed ,
    SUM(pmbron.total_enemy_jungle_minions_killed) FILTER (WHERE pmbron.team_id=200) AS t200_total_enemy_jungle_minions_killed ,

    -- damage taken/support/CC
    SUM(pmbron.total_damage_taken) FILTER (WHERE pmbron.team_id=100) AS t100_total_damage_taken ,
    SUM(pmbron.total_damage_taken) FILTER (WHERE pmbron.team_id=200) AS t200_total_damage_taken ,
    SUM(pmbron.damage_self_mitigated) FILTER (WHERE pmbron.team_id=100) AS t100_damage_self_mitigated ,
    SUM(pmbron.damage_self_mitigated) FILTER (WHERE pmbron.team_id=200) AS t200_damage_self_mitigated ,
    SUM(pmbron.total_heal) FILTER (WHERE pmbron.team_id=100) AS t100_total_heal ,
    SUM(pmbron.total_heal) FILTER (WHERE pmbron.team_id=200) AS t200_total_heal ,
    SUM(pmbron.total_heals_on_teammates) FILTER (WHERE pmbron.team_id=100) AS t100_total_heals_on_teammates ,
    SUM(pmbron.total_heals_on_teammates) FILTER (WHERE pmbron.team_id=200) AS t200_total_heals_on_teammates ,
    SUM(pmbron.total_damage_shielded_on_teammates) FILTER (WHERE pmbron.team_id=100) AS t100_total_damage_shielded_on_teammates ,
    SUM(pmbron.total_damage_shielded_on_teammates) FILTER (WHERE pmbron.team_id=200) AS t200_total_damage_shielded_on_teammates ,
    SUM(pmbron.time_ccing_others) FILTER (WHERE pmbron.team_id=100) AS t100_time_ccing_others ,
    SUM(pmbron.time_ccing_others) FILTER (WHERE pmbron.team_id=200) AS t200_time_ccing_others ,
    SUM(pmbron.total_time_cc_dealt) FILTER (WHERE pmbron.team_id=100) AS t100_total_time_cc_dealt ,
    SUM(pmbron.total_time_cc_dealt) FILTER (WHERE pmbron.team_id=200) AS t200_total_time_cc_dealt ,

    -- Damages dealt (performance & objectives)
    SUM(pmbron.total_damage_dealt) FILTER (WHERE pmbron.team_id = 100)
    AS t100_total_damage_dealt,

    SUM(pmbron.total_damage_dealt) FILTER (WHERE pmbron.team_id = 200) 
    AS t200_total_damage_dealt,

    SUM(pmbron.total_damage_dealt_to_champions) FILTER (WHERE pmbron.team_id = 100) 
    AS t100_total_damage_dealt_to_champions,

    SUM(pmbron.total_damage_dealt_to_champions) FILTER (WHERE pmbron.team_id = 200) 
    AS t200_total_damage_dealt_to_champions,

    SUM(pmbron.damage_dealt_to_turrets) FILTER (WHERE pmbron.team_id=100) AS t100_damage_dealt_to_turrets ,
    SUM(pmbron.damage_dealt_to_turrets) FILTER (WHERE pmbron.team_id=200) AS t200_damage_dealt_to_turrets ,
    SUM(pmbron.damage_dealt_to_objectives) FILTER (WHERE pmbron.team_id=100) AS t100_damage_dealt_to_objectives ,
    SUM(pmbron.damage_dealt_to_objectives) FILTER (WHERE pmbron.team_id=200) AS t200_damage_dealt_to_objectives ,
    SUM(pmbron.damage_dealt_to_epic_monsters) FILTER (WHERE pmbron.team_id=100) AS t100_damage_dealt_to_epic_monsters ,
    SUM(pmbron.damage_dealt_to_epic_monsters) FILTER (WHERE pmbron.team_id=200) AS t200_damage_dealt_to_epic_monsters ,
    SUM(pmbron.turret_takedowns) FILTER (WHERE pmbron.team_id=100) AS t100_turret_takedowns ,
    SUM(pmbron.turret_takedowns) FILTER (WHERE pmbron.team_id=200) AS t200_turret_takedowns ,
    SUM(pmbron.inhibitor_takedowns) FILTER (WHERE pmbron.team_id=100) AS t100_inhibitor_takedowns ,
    SUM(pmbron.inhibitor_takedowns) FILTER (WHERE pmbron.team_id=200) AS t200_inhibitor_takedowns ,
    SUM(pmbron.dragon_kills) FILTER (WHERE pmbron.team_id=100) AS t100_dragon_kills ,
    SUM(pmbron.dragon_kills) FILTER (WHERE pmbron.team_id=200) AS t200_dragon_kills ,
    SUM(pmbron.baron_kills) FILTER (WHERE pmbron.team_id=100) AS t100_baron_kills ,
    SUM(pmbron.baron_kills) FILTER (WHERE pmbron.team_id=200) AS t200_baron_kills ,

    SUM(COALESCE(pmbron.objectives_stolen, 0) + COALESCE(pmbron.objectives_stolen_assists, 0)) 
    FILTER (WHERE pmbron.team_id=100) AS t100_objectives_stolen_participation ,
    SUM(COALESCE(pmbron.objectives_stolen, 0) + COALESCE(pmbron.objectives_stolen_assists, 0))
    FILTER (WHERE pmbron.team_id=200) AS t200_objectives_stolen_participation ,

    
    SUM(pmbron.vision_score) FILTER (WHERE pmbron.team_id=100) AS t100_vision_score ,
    SUM(pmbron.vision_score) FILTER (WHERE pmbron.team_id=200) AS t200_vision_score ,
    SUM(pmbron.wards_placed) FILTER (WHERE pmbron.team_id=100) AS t100_wards_placed ,
    SUM(pmbron.wards_placed) FILTER (WHERE pmbron.team_id=200) AS t200_wards_placed ,
    SUM(pmbron.wards_killed) FILTER (WHERE pmbron.team_id=100) AS t100_wards_killed ,
    SUM(pmbron.wards_killed) FILTER (WHERE pmbron.team_id=200) AS t200_wards_killed ,
    SUM(pmbron.detector_wards_placed) FILTER (WHERE pmbron.team_id=100) AS t100_detector_wards_placed ,
    SUM(pmbron.detector_wards_placed) FILTER (WHERE pmbron.team_id=200) AS t200_detector_wards_placed ,

    -- PINGS 
    SUM(
        COALESCE(pmbron.all_in_pings, 0) +
        COALESCE(pmbron.assist_me_pings, 0) +
        COALESCE(pmbron.basic_pings, 0) +
        COALESCE(pmbron.command_pings, 0) +
        COALESCE(pmbron.danger_pings, 0) +
        COALESCE(pmbron.enemy_missing_pings, 0) +
        COALESCE(pmbron.enemy_vision_pings, 0) +
        COALESCE(pmbron.get_back_pings, 0) +
        COALESCE(pmbron.hold_pings, 0) +
        COALESCE(pmbron.need_vision_pings, 0) +
        COALESCE(pmbron.on_my_way_pings, 0) +
        COALESCE(pmbron.push_pings, 0) +
        COALESCE(pmbron.retreat_pings, 0) +
        COALESCE(pmbron.vision_cleared_pings, 0)
    ) FILTER (WHERE pmbron.team_id=100) AS t100_total_pings ,

    SUM(
        COALESCE(pmbron.all_in_pings, 0) +
        COALESCE(pmbron.assist_me_pings, 0) +
        COALESCE(pmbron.basic_pings, 0) +
        COALESCE(pmbron.command_pings, 0) +
        COALESCE(pmbron.danger_pings, 0) +
        COALESCE(pmbron.enemy_missing_pings, 0) +
        COALESCE(pmbron.enemy_vision_pings, 0) +
        COALESCE(pmbron.get_back_pings, 0) +
        COALESCE(pmbron.hold_pings, 0) +
        COALESCE(pmbron.need_vision_pings, 0) +
        COALESCE(pmbron.on_my_way_pings, 0) +
        COALESCE(pmbron.push_pings, 0) +
        COALESCE(pmbron.retreat_pings, 0) +
        COALESCE(pmbron.vision_cleared_pings, 0)
    ) FILTER (WHERE pmbron.team_id=200) AS t200_total_pings ,

    --BANS PER TEAM
    ARRAY(
        SELECT (ban ->> 'championId')::INTEGER
        FROM jsonb_array_elements(
            (ARRAY_AGG(pmbron.teams))[1] -> 0 -> 'bans'
        ) AS ban
        ORDER BY (ban ->> 'pickTurn')::INTEGER
    ) AS t100_banned_champions_id,

    ARRAY(
        SELECT (ban ->> 'championId')::INTEGER
        FROM jsonb_array_elements(
            (ARRAY_AGG(pmbron.teams))[1] -> 1 -> 'bans'
        ) AS ban
        ORDER BY (ban ->> 'pickTurn')::INTEGER
    ) AS t200_banned_champions_id

FROM player_matches_bronze AS pmbron
GROUP BY pmbron.match_id
ON CONFLICT (match_id) DO UPDATE SET

    game_version = EXCLUDED.game_version,
    tournament_code = EXCLUDED.tournament_code,
    time_played = EXCLUDED.time_played,
    game_creation_at = EXCLUDED.game_creation_at,
    game_start_at = EXCLUDED.game_start_at,
    game_end_at = EXCLUDED.game_end_at,

    game_ended_in_surrender = EXCLUDED.game_ended_in_surrender,
    game_ended_in_early_surrender = EXCLUDED.game_ended_in_early_surrender,
    winning_team = EXCLUDED.winning_team,
    afk_players = EXCLUDED.afk_players,

    t100_players_puuid = EXCLUDED.t100_players_puuid,
    t200_players_puuid = EXCLUDED.t200_players_puuid,
    t100_champions_id = EXCLUDED.t100_champions_id,
    t200_champions_id = EXCLUDED.t200_champions_id,

    avg_summoner_level = EXCLUDED.avg_summoner_level,
    t100_avg_summoner_lv = EXCLUDED.t100_avg_summoner_lv,
    t200_avg_summoner_lv = EXCLUDED.t200_avg_summoner_lv,

    --combat
    t100_kills = EXCLUDED.t100_kills,
    t200_kills = EXCLUDED.t200_kills,
    t100_deaths = EXCLUDED.t100_deaths,
    t200_deaths = EXCLUDED.t200_deaths,
    t100_assists = EXCLUDED.t100_assists,
    t200_assists = EXCLUDED.t200_assists,

    --economy
    t100_gold_earned = EXCLUDED.t100_gold_earned,
    t200_gold_earned = EXCLUDED.t200_gold_earned,
    t100_gold_spent = EXCLUDED.t100_gold_spent,
    t200_gold_spent = EXCLUDED.t200_gold_spent,
    t100_items_purchased = EXCLUDED.t100_items_purchased,
    t200_items_purchased = EXCLUDED.t200_items_purchased,
    t100_consumables_purchased = EXCLUDED.t100_consumables_purchased,
    t200_consumables_purchased = EXCLUDED.t200_consumables_purchased,

    --combat (use performance and aggro?)
    t100_total_minions_killed = EXCLUDED.t100_total_minions_killed,
    t200_total_minions_killed = EXCLUDED.t200_total_minions_killed,
    t100_neutral_minions_killed = EXCLUDED.t100_neutral_minions_killed,
    t200_neutral_minions_killed = EXCLUDED.t200_neutral_minions_killed,
    t100_total_ally_jungle_minions_killed = EXCLUDED.t100_total_ally_jungle_minions_killed,
    t200_total_ally_jungle_minions_killed = EXCLUDED.t200_total_ally_jungle_minions_killed,
    t100_total_enemy_jungle_minions_killed = EXCLUDED.t100_total_enemy_jungle_minions_killed,
    t200_total_enemy_jungle_minions_killed = EXCLUDED.t200_total_enemy_jungle_minions_killed,

    -- damage taken/support/CC
    t100_total_damage_taken = EXCLUDED.t100_total_damage_taken,
    t200_total_damage_taken = EXCLUDED.t200_total_damage_taken,
    t100_damage_self_mitigated = EXCLUDED.t100_damage_self_mitigated,
    t200_damage_self_mitigated = EXCLUDED.t200_damage_self_mitigated,
    t100_total_heal = EXCLUDED.t100_total_heal,
    t200_total_heal = EXCLUDED.t200_total_heal,
    t100_total_heals_on_teammates = EXCLUDED.t100_total_heals_on_teammates,
    t200_total_heals_on_teammates = EXCLUDED.t200_total_heals_on_teammates,
    t100_total_damage_shielded_on_teammates = EXCLUDED.t100_total_damage_shielded_on_teammates,
    t200_total_damage_shielded_on_teammates = EXCLUDED.t200_total_damage_shielded_on_teammates,
    t100_time_ccing_others = EXCLUDED.t100_time_ccing_others,
    t200_time_ccing_others = EXCLUDED.t200_time_ccing_others,
    t100_total_time_cc_dealt = EXCLUDED.t100_total_time_cc_dealt,
    t200_total_time_cc_dealt = EXCLUDED.t200_total_time_cc_dealt,

    -- Damages dealt (performance & objectives)
    t100_total_damage_dealt = EXCLUDED.t100_total_damage_dealt,
    t200_total_damage_dealt = EXCLUDED.t200_total_damage_dealt,
    t100_total_damage_dealt_to_champions = EXCLUDED.t100_total_damage_dealt_to_champions,
    t200_total_damage_dealt_to_champions = EXCLUDED.t200_total_damage_dealt_to_champions,
    t100_damage_dealt_to_turrets = EXCLUDED.t100_damage_dealt_to_turrets,
    t200_damage_dealt_to_turrets = EXCLUDED.t200_damage_dealt_to_turrets,
    t100_damage_dealt_to_objectives = EXCLUDED.t100_damage_dealt_to_objectives,
    t200_damage_dealt_to_objectives = EXCLUDED.t200_damage_dealt_to_objectives,
    t100_damage_dealt_to_epic_monsters = EXCLUDED.t100_damage_dealt_to_epic_monsters,
    t200_damage_dealt_to_epic_monsters = EXCLUDED.t200_damage_dealt_to_epic_monsters,
    t100_turret_takedowns = EXCLUDED.t100_turret_takedowns,
    t200_turret_takedowns = EXCLUDED.t200_turret_takedowns,
    t100_inhibitor_takedowns = EXCLUDED.t100_inhibitor_takedowns,
    t200_inhibitor_takedowns = EXCLUDED.t200_inhibitor_takedowns,
    t100_dragon_kills = EXCLUDED.t100_dragon_kills,
    t200_dragon_kills = EXCLUDED.t200_dragon_kills,
    t100_baron_kills = EXCLUDED.t100_baron_kills,
    t200_baron_kills = EXCLUDED.t200_baron_kills,
    t100_objectives_stolen_participation = EXCLUDED.t100_objectives_stolen_participation,
    t200_objectives_stolen_participation = EXCLUDED.t200_objectives_stolen_participation,

    -- Vision (game performance? control? teamplayer?)
    t100_vision_score = EXCLUDED.t100_vision_score,
    t200_vision_score = EXCLUDED.t200_vision_score,
    t100_wards_placed = EXCLUDED.t100_wards_placed,
    t200_wards_placed = EXCLUDED.t200_wards_placed,
    t100_wards_killed = EXCLUDED.t100_wards_killed,
    t200_wards_killed = EXCLUDED.t200_wards_killed,
    t100_detector_wards_placed = EXCLUDED.t100_detector_wards_placed,
    t200_detector_wards_placed = EXCLUDED.t200_detector_wards_placed,

    -- PINGS (comunication and engagement?)
    t100_total_pings = EXCLUDED.t100_total_pings,
    t200_total_pings = EXCLUDED.t200_total_pings,

    --BANS PER TEAM
    t100_banned_champions_id = EXCLUDED.t100_banned_champions_id,
    t200_banned_champions_id = EXCLUDED.t200_banned_champions_id;