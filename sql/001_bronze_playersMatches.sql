CREATE TABLE IF NOT EXISTS players_matches(
    -- Identifiers
    match_id TEXT NOT NULL,
    puuid TEXT NOT NULL,
    participant_id INTEGER NOT NULL,
    team_id INTEGER,

    -- Summoner information
    summoner_id TEXT,
    summoner_name TEXT,
    summoner_level INTEGER,
    profile_icon INTEGER,

    riot_id_game_name TEXT,
    riot_id_tagline TEXT,

    -- Time
    time_played INTEGER,
    longest_time_spent_living INTEGER,
    total_time_spent_dead INTEGER,

    -- Champion and position
    champion_id INTEGER,
    champion_name TEXT,
    champion_transform INTEGER,
    champ_level INTEGER,
    champ_experience INTEGER,

    individual_position TEXT,
    team_position TEXT,
    lane TEXT,
    role TEXT,

    position_assigned_by_matchmaking TEXT,
    selected_role_preferences TEXT,

    -- Match result and progr
    win BOOLEAN,
    eligible_for_progression BOOLEAN,

    game_ended_in_early_surrender BOOLEAN,
    game_ended_in_ignb_surrender BOOLEAN,
    game_ended_in_surrender BOOLEAN,

    team_early_surrendered BOOLEAN,
    team_ignb_surrendered BOOLEAN,

    caused_game_end_from_ignb_surrender BOOLEAN,
    was_premade_with_ignb_game_end_causer BOOLEAN,
    was_premade_with_severe_transgressor BOOLEAN,
    was_severe_transgressor BOOLEAN,
    was_afk BOOLEAN,

    -- Kills, deaths and assists
    kills INTEGER,
    deaths INTEGER,
    assists INTEGER,

    killing_sprees INTEGER,
    largest_killing_spree INTEGER,
    largest_multi_kill INTEGER,

    double_kills INTEGER,
    triple_kills INTEGER,
    quadra_kills INTEGER,
    penta_kills INTEGER,
    unreal_kills INTEGER,

    first_blood_kill BOOLEAN,
    first_blood_assist BOOLEAN,

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

    -- Damage dealt
    total_damage_dealt INTEGER,
    total_damage_dealt_to_champions INTEGER,

    physical_damage_dealt INTEGER,
    physical_damage_dealt_to_champions INTEGER,

    magic_damage_dealt INTEGER,
    magic_damage_dealt_to_champions INTEGER,

    true_damage_dealt INTEGER,
    true_damage_dealt_to_champions INTEGER,

    -- Damage taken and mitigated
    total_damage_taken INTEGER,

    physical_damage_taken INTEGER,
    magic_damage_taken INTEGER,
    true_damage_taken INTEGER,
    damage_self_mitigated INTEGER,

    -- Healing / shielding
    total_heal INTEGER,
    total_heals_on_teammates INTEGER,
    total_units_healed INTEGER,
    total_damage_shielded_on_teammates INTEGER,

    -- Crowd control
    time_ccing_others INTEGER,
    total_time_cc_dealt INTEGER,

    -- Objectives and structures
    damage_dealt_to_buildings INTEGER,
    damage_dealt_to_turrets INTEGER,
    damage_dealt_to_objectives INTEGER,
    damage_dealt_to_epic_monsters INTEGER,

    turret_kills INTEGER,
    turret_takedowns INTEGER,
    turrets_lost INTEGER,

    inhibitor_kills INTEGER,
    inhibitor_takedowns INTEGER,
    inhibitors_lost INTEGER,

    nexus_kills INTEGER,
    nexus_takedowns INTEGER,
    nexus_lost INTEGER,

    dragon_kills INTEGER,
    baron_kills INTEGER,

    objectives_stolen INTEGER,
    objectives_stolen_assists INTEGER,

    first_tower_kill BOOLEAN,
    first_tower_assist BOOLEAN,

    -- Vision
    vision_score INTEGER,

    wards_placed INTEGER,
    wards_killed INTEGER,

    detector_wards_placed INTEGER,
    vision_wards_bought_in_game INTEGER,
    sight_wards_bought_in_game INTEGER,

    -- Pings
    all_in_pings INTEGER,
    assist_me_pings INTEGER,
    basic_pings INTEGER,
    command_pings INTEGER,
    danger_pings INTEGER,
    enemy_missing_pings INTEGER,
    enemy_vision_pings INTEGER,
    get_back_pings INTEGER,
    hold_pings INTEGER,
    need_vision_pings INTEGER,
    on_my_way_pings INTEGER,
    push_pings INTEGER,
    retreat_pings INTEGER,
    vision_cleared_pings INTEGER,

    -- Champion spell casts
    spell_1_casts INTEGER,
    spell_2_casts INTEGER,
    spell_3_casts INTEGER,
    spell_4_casts INTEGER,

    -- Summoner spells
    summoner_1_id INTEGER,
    summoner_2_id INTEGER,
    summoner_1_casts INTEGER,
    summoner_2_casts INTEGER,



    -- Arena and other mode fields Riot still includes
    placement INTEGER,
    subteam_placement INTEGER,
    player_subteam_id INTEGER,

    player_augment_1 INTEGER,
    player_augment_2 INTEGER,
    player_augment_3 INTEGER,
    player_augment_4 INTEGER,
    player_augment_5 INTEGER,
    player_augment_6 INTEGER,

    -- Nested participant data kept raw in Bronze
    player_behavior JSONB,
    missions JSONB,
    perks JSONB,

    PRIMARY KEY (match_id, puuid),

    FOREIGN KEY (match_id)
        REFERENCES matches(match_id)