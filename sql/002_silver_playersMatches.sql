CREATE TABLE 
IF NOT EXISTS player_matches_silver (
    
    
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
    total_time_spent_dead FLOAT,
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

    game_ended_in_early_surrender BOOLEAN, ---> remake
    game_ended_in_surrender BOOLEAN,
    was_afk BOOLEAN,


    -- Kills, deaths and assists
    kills INTEGER,
    deaths INTEGER,
    assists INTEGER,

    killing_sprees INTEGER,
    largest_killing_spree INTEGER,
    largest_multi_kill INTEGER,
    multikill_count INTEGER,
    first_blood_kill BOOLEAN,           
    /*
    Individual multikill fields (double to penta/unreal kills) are collapsed into
    multikill_count while largest_multi_kill preserves the highest intensity event.
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

)
