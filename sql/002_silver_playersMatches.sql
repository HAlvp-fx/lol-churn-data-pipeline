CREATE TABLE IF NOT EXISTS player_matches_silver (
    
    
    -- Identifiers
    match_id TEXT NOT NULL,
    puuid TEXT NOT NULL,
    team_id INTEGER,
    summoner_level INTEGER,
    /*
    participant_id, summoner_id, riot_id_game_name and riot_id_tagline are dropped in Silver.
    participant_id only identifies the player within a specific match while puuid is already
    used as the canonical player identifier. summoner_id is redundant with puuid, and Riot
    game name/tagline are display identifiers with no relevant analytical value for churn.
    */
    

    -- Time
    time_played INTEGER,
    total_time_spent_dead INTEGER,
    -- Dropped: longest_time_spent_living because it adds limited behavioural information beyond deaths, time_played and total_time_spent_dead.    
    
    
    -- Champion 
    champion_id INTEGER,
    -- Dropped: champion_name and champion_transform , name bc it's redundant to ddragon and transform seems relevant to very few champions
    champ_level INTEGER,
    champ_experience INTEGER,


    -- Position
    /*
    lane and role are dropped in Silver because they represent an older,
    coarser position classification and showed ambiguous/inconsistent values
    during profiling. team_position provides a more reliable representation
    of the player's position within the team.
    */  
    individual_position TEXT,               -- Riot's best position estimate considering the player in isolation
    team_position TEXT,                     -- Riot's best position estimate considering the full team composition
    position_assigned_by_matchmaking TEXT,  -- position assigned by matchmaking
    selected_role_preferences TEXT,         -- preference format is not fully documented

    
    -- Match result and progr

    /*
    IGNB, severe-transgressor and team-level surrender flags are dropped due to
    their very low frequency, limited public documentation or redundancy with
    other retained fields. Particularly there is no public info on what ignb stands for?
    Due to all ignb surrenders having severe transgressor players I believe it might be
    in game bad behaviour but since I'm not sure and it's not that common I'll omit them
    */

    win BOOLEAN,
    eligible_for_progression BOOLEAN,

    game_ended_in_early_surrender BOOLEAN, -- -> remake
    game_ended_in_surrender BOOLEAN,
    was_afk BOOLEAN,


    -- Kills, deaths and assists
    kills INTEGER,
    deaths INTEGER,
    assists INTEGER,

    killing_sprees INTEGER,
    largest_killing_spree INTEGER,
    largest_multi_kill INTEGER,
    largest_multi_kill_count INTEGER,
    first_blood_kill BOOLEAN,           
    /*
    Individual multikill fields (double, triple, quadra, penta and unreal kills)
    are dropped in Silver due to their highly imbalanced distributions and
    overlapping interpretation but I decided to keep record of the number
    of ocurrencs of the largest multikill.
    
    first_blood_kill is retained as a direct early-game performance/economic event.
    first_blood_assist is dropped because it overlaps with the same event and adds
    limited additional information.
    */


    -- Gold and purchases
    gold_earned INTEGER,
    gold_spent INTEGER,
    items_purchased INTEGER,
    consumables_purchased INTEGER,

    -- Items
    item_0 INTEGER,
    item_1 INTEGER,
    item_2 INTEGER,
    item_3 INTEGER,
    item_4 INTEGER,
    item_5 INTEGER,
    item_6 INTEGER,

    role_bound_item INTEGER,

    -- Minions
    total_minions_killed INTEGER,
    neutral_minions_killed INTEGER,
    total_ally_jungle_minions_killed INTEGER,
    total_enemy_jungle_minions_killed INTEGER,

    -- Damage 
    /*
    Damage type breakdown (magic / physical / true) is dropped to reduce redundancy.
    Total damage dealt, champion damage and damage taken are retained as broader
    behavioural/performance measures.
    */
    
    total_damage_dealt INTEGER,
    total_damage_dealt_to_champions INTEGER,
    total_damage_taken INTEGER,
    damage_self_mitigated INTEGER,

    -- Healing / shielding
    total_heal INTEGER,
    total_heals_on_teammates INTEGER,
    total_units_healed INTEGER,
    total_damage_shielded_on_teammates INTEGER,

    -- Crowd control
    /*Both crowd-control metrics are retained bc profiling showed only moderate
    correlation (~0.43), suggesting that they capture different aspects of
    crowd-control (altgh I'm not suer what is the difference )*/
    time_ccing_others INTEGER,
    total_time_cc_dealt INTEGER,

    -- Objectives and structures
    /*
    Nexus-related fields are dropped in profiling showed they are very correlated with the final match outcome
    so -> very limited new information (surrender affects this metric for example)
    Objective fields were simplified to reduce redundancy.Kills were replaced by takedowns where broader 
    participation was more useful, team-level and nexus fields were removed and related
     kill/assist fields were combined into participation features.
    */
    damage_dealt_to_turrets INTEGER,
    damage_dealt_to_objectives INTEGER,
    damage_dealt_to_epic_monsters INTEGER,

    turret_takedowns INTEGER,
    inhibitor_takedowns INTEGER,

    dragon_kills INTEGER,
    baron_kills INTEGER,

    objectives_stolen_participation INTEGER,
    first_tower_participation BOOLEAN,

    -- Vision
    /*
    Vision fields were simplified after profiling. Ward purchase fields were removed due 
    to high redundancy with ward placement metrics (vision score and direct ward interactions retained)
    */
    vision_score INTEGER,
    wards_placed INTEGER,
    wards_killed INTEGER,
    detector_wards_placed INTEGER,

    -- Pings
    /*
Individual ping types were condensed into total_pings to represent overall
player communication activity (but unused or nearly unused ping fields will 
be discarded in the insert)*/
    total_pings INTEGER,


    -- Champion spell casts
    /*
    Individual champion and summoner spell casts were aggregated to represent
    overall spell activity, while summoner spell IDs were retained to preserve
    information about player spell selection.
    */
    total_spell_casts INTEGER,
    -- Summoner spells
    summoner_1_id INTEGER,
    summoner_2_id INTEGER,
    summoner_spell_casts INTEGER,
    --DELETED:  Arena and other mode fields Riot still includes in classic

    -- Nested participant data kept raw in Bronze
    /*
    player_behavior and missions were removed due to limited analytical
    interpretability. Perks were retained as meaningful player configuration data.
    */
    perks JSONB,

    PRIMARY KEY (match_id, puuid)
    );

INSERT INTO player_matches_silver(
    match_id ,
    puuid ,
    team_id ,
    summoner_level ,
    time_played ,
    total_time_spent_dead ,
    champion_id ,
    champ_level ,
    champ_experience ,
    individual_position,
    team_position ,                     
    position_assigned_by_matchmaking , 
    selected_role_preferences ,         
    win ,
    eligible_for_progression ,
    game_ended_in_early_surrender ,
    game_ended_in_surrender ,
    was_afk ,
    kills ,
    deaths ,
    assists ,
    killing_sprees ,
    largest_killing_spree ,
    largest_multi_kill ,
    largest_multi_kill_count,
    first_blood_kill ,           
    gold_earned ,
    gold_spent ,
    items_purchased ,
    consumables_purchased ,
    item_0 ,
    item_1 ,
    item_2 ,
    item_3 ,
    item_4 ,
    item_5 ,
    item_6 ,
    role_bound_item ,
    total_minions_killed ,
    neutral_minions_killed ,
    total_ally_jungle_minions_killed ,
    total_enemy_jungle_minions_killed ,
    total_damage_dealt ,
    total_damage_dealt_to_champions ,
    total_damage_taken ,
    damage_self_mitigated ,
    total_heal ,
    total_heals_on_teammates ,
    total_units_healed ,
    total_damage_shielded_on_teammates ,
    time_ccing_others ,
    total_time_cc_dealt ,
    damage_dealt_to_turrets ,
    damage_dealt_to_objectives ,
    damage_dealt_to_epic_monsters ,
    turret_takedowns ,
    inhibitor_takedowns ,
    dragon_kills ,
    baron_kills ,
    objectives_stolen_participation ,
    first_tower_participation ,
    vision_score ,
    wards_placed ,
    wards_killed ,
    detector_wards_placed ,
    total_pings ,
    total_spell_casts ,
    summoner_1_id ,
    summoner_2_id ,
    summoner_spell_casts ,
    perks 
)
SELECT 
--COALESCE IS VERY IMPORTANT--> some fields might have null as value and when adding that can give errors
    pmbron.match_id,
    pmbron.puuid,
    pmbron.team_id,
    pmbron.summoner_level,
    pmbron.time_played,
    pmbron.total_time_spent_dead,
    pmbron.champion_id,
    pmbron.champ_level,
    pmbron.champ_experience,
    pmbron.individual_position,
    pmbron.team_position,
    pmbron.position_assigned_by_matchmaking,
    pmbron.selected_role_preferences,
    pmbron.win,
    pmbron.eligible_for_progression,
    pmbron.game_ended_in_early_surrender,
    pmbron.game_ended_in_surrender,
    pmbron.was_afk,
    pmbron.kills,
    pmbron.deaths,
    pmbron.assists,
    pmbron.killing_sprees,
    pmbron.largest_killing_spree,
    pmbron.largest_multi_kill,
    CASE
    WHEN pmbron.largest_multi_kill = 5 THEN COALESCE(pmbron.penta_kills, 0)
    WHEN pmbron.largest_multi_kill = 4 THEN COALESCE(pmbron.quadra_kills, 0)
    WHEN pmbron.largest_multi_kill = 3 THEN COALESCE(pmbron.triple_kills, 0)
    WHEN pmbron.largest_multi_kill = 2 THEN COALESCE(pmbron.double_kills, 0)
    ELSE 0
    END AS largest_multi_kill_count,
    pmbron.first_blood_kill,
    pmbron.gold_earned,
    pmbron.gold_spent,
    pmbron.items_purchased,
    pmbron.consumables_purchased,
    pmbron.item_0,
    pmbron.item_1,
    pmbron.item_2,
    pmbron.item_3,
    pmbron.item_4,
    pmbron.item_5,
    pmbron.item_6,
    pmbron.role_bound_item,
    pmbron.total_minions_killed,
    pmbron.neutral_minions_killed,
    pmbron.total_ally_jungle_minions_killed,
    pmbron.total_enemy_jungle_minions_killed,
    pmbron.total_damage_dealt,
    pmbron.total_damage_dealt_to_champions,
    pmbron.total_damage_taken,
    pmbron.damage_self_mitigated,
    pmbron.total_heal,
    pmbron.total_heals_on_teammates,
    pmbron.total_units_healed,
    pmbron.total_damage_shielded_on_teammates,
    pmbron.time_ccing_others,
    pmbron.total_time_cc_dealt,
    pmbron.damage_dealt_to_turrets,
    pmbron.damage_dealt_to_objectives,
    pmbron.damage_dealt_to_epic_monsters,
    pmbron.turret_takedowns,
    pmbron.inhibitor_takedowns,
    pmbron.dragon_kills,
    pmbron.baron_kills,
    COALESCE(pmbron.objectives_stolen, 0) + COALESCE(pmbron.objectives_stolen_assists, 0)
    AS objectives_stolen_participation,
    COALESCE(pmbron.first_tower_kill, FALSE) OR COALESCE(pmbron.first_tower_assist, FALSE)
    AS first_tower_participation,
    pmbron.vision_score,
    pmbron.wards_placed,
    pmbron.wards_killed,
    pmbron.detector_wards_placed,
    COALESCE(pmbron.all_in_pings, 0) + COALESCE(pmbron.assist_me_pings, 0)
    + COALESCE(pmbron.basic_pings, 0)  + COALESCE(pmbron.command_pings, 0)
    + COALESCE(pmbron.danger_pings, 0)  + COALESCE(pmbron.enemy_missing_pings, 0)
    + COALESCE(pmbron.enemy_vision_pings, 0) + COALESCE(pmbron.get_back_pings, 0)
    + COALESCE(pmbron.hold_pings, 0) + COALESCE(pmbron.need_vision_pings, 0)
    + COALESCE(pmbron.on_my_way_pings, 0) + COALESCE(pmbron.push_pings, 0)
    + COALESCE(pmbron.retreat_pings, 0) + COALESCE(pmbron.vision_cleared_pings, 0)
    AS total_pings,
    COALESCE(pmbron.spell_1_casts, 0)  + COALESCE(pmbron.spell_2_casts, 0)
    + COALESCE(pmbron.spell_3_casts, 0) + COALESCE(pmbron.spell_4_casts, 0)
    AS total_spell_casts,
    pmbron.summoner_1_id,
    pmbron.summoner_2_id,
    COALESCE(pmbron.summoner_1_casts, 0) + COALESCE(pmbron.summoner_2_casts, 0)
    AS summoner_spell_casts,
    pmbron.perks
FROM player_matches_bronze AS pmbron
    INNER JOIN players_bronze AS pbron ON pmbron.puuid = pbron.puuid
ON CONFLICT (match_id, puuid) DO UPDATE SET 
    team_id = EXCLUDED.team_id,
    summoner_level = EXCLUDED.summoner_level,
    time_played = EXCLUDED.time_played,
    total_time_spent_dead = EXCLUDED.total_time_spent_dead,
    champion_id = EXCLUDED.champion_id,
    champ_level = EXCLUDED.champ_level,
    champ_experience = EXCLUDED.champ_experience,
    individual_position = EXCLUDED.individual_position,
    team_position = EXCLUDED.team_position,
    position_assigned_by_matchmaking = EXCLUDED.position_assigned_by_matchmaking,
    selected_role_preferences = EXCLUDED.selected_role_preferences,

    win = EXCLUDED.win,
    eligible_for_progression = EXCLUDED.eligible_for_progression,
    game_ended_in_early_surrender = EXCLUDED.game_ended_in_early_surrender,
    game_ended_in_surrender = EXCLUDED.game_ended_in_surrender,
    was_afk = EXCLUDED.was_afk,

    kills = EXCLUDED.kills,
    deaths = EXCLUDED.deaths,
    assists = EXCLUDED.assists,
    killing_sprees = EXCLUDED.killing_sprees,
    largest_killing_spree = EXCLUDED.largest_killing_spree,
    largest_multi_kill = EXCLUDED.largest_multi_kill,
    largest_multi_kill_count = EXCLUDED.largest_multi_kill_count,
    first_blood_kill = EXCLUDED.first_blood_kill,

    gold_earned = EXCLUDED.gold_earned,
    gold_spent = EXCLUDED.gold_spent,
    items_purchased = EXCLUDED.items_purchased,
    consumables_purchased = EXCLUDED.consumables_purchased,

    item_0 = EXCLUDED.item_0,
    item_1 = EXCLUDED.item_1,
    item_2 = EXCLUDED.item_2,
    item_3 = EXCLUDED.item_3,
    item_4 = EXCLUDED.item_4,
    item_5 = EXCLUDED.item_5,
    item_6 = EXCLUDED.item_6,
    role_bound_item = EXCLUDED.role_bound_item,

    total_minions_killed = EXCLUDED.total_minions_killed,
    neutral_minions_killed = EXCLUDED.neutral_minions_killed,
    total_ally_jungle_minions_killed = EXCLUDED.total_ally_jungle_minions_killed,
    total_enemy_jungle_minions_killed = EXCLUDED.total_enemy_jungle_minions_killed,

    total_damage_dealt = EXCLUDED.total_damage_dealt,
    total_damage_dealt_to_champions = EXCLUDED.total_damage_dealt_to_champions,
    total_damage_taken = EXCLUDED.total_damage_taken,
    damage_self_mitigated = EXCLUDED.damage_self_mitigated,

    total_heal = EXCLUDED.total_heal,
    total_heals_on_teammates = EXCLUDED.total_heals_on_teammates,
    total_units_healed = EXCLUDED.total_units_healed,
    total_damage_shielded_on_teammates = EXCLUDED.total_damage_shielded_on_teammates,

    time_ccing_others = EXCLUDED.time_ccing_others,
    total_time_cc_dealt = EXCLUDED.total_time_cc_dealt,

    damage_dealt_to_turrets = EXCLUDED.damage_dealt_to_turrets,
    damage_dealt_to_objectives = EXCLUDED.damage_dealt_to_objectives,
    damage_dealt_to_epic_monsters = EXCLUDED.damage_dealt_to_epic_monsters,
    turret_takedowns = EXCLUDED.turret_takedowns,
    inhibitor_takedowns = EXCLUDED.inhibitor_takedowns,
    dragon_kills = EXCLUDED.dragon_kills,
    baron_kills = EXCLUDED.baron_kills,
    objectives_stolen_participation = EXCLUDED.objectives_stolen_participation,
    first_tower_participation = EXCLUDED.first_tower_participation,

    vision_score = EXCLUDED.vision_score,
    wards_placed = EXCLUDED.wards_placed,
    wards_killed = EXCLUDED.wards_killed,
    detector_wards_placed = EXCLUDED.detector_wards_placed,

    total_pings = EXCLUDED.total_pings,
    total_spell_casts = EXCLUDED.total_spell_casts,
    summoner_1_id = EXCLUDED.summoner_1_id,
    summoner_2_id = EXCLUDED.summoner_2_id,
    summoner_spell_casts = EXCLUDED.summoner_spell_casts,

    perks = EXCLUDED.perks;

