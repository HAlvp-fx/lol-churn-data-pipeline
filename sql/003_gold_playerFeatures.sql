IF TABLE NOT EXISTS CREATE player_features_gold(
    puuid TEXT PRIMARY KEY,
    sampling_tier VARCHAR(15),
    sampling_division VARCHAR(5),
    tier TEXT,
    rank TEXT,
    
    -- activ
    matches_15d INTEGER,
    matches_30d INTEGER,
    matches_60d INTEGER,
    matches_90d INTEGER,
    active_days_15d INTEGER,
    active_days_90d INTEGER,
    days_since_last_match INTEGER,
    avg_days_between_matches_15d FLOAT,
    avg_days_between_matches_90d FLOAT,
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
    -- social
    unique_teammates INTEGER,
    repeat_teammate_rate FLOAT,
    max_teammate_match_share FLOAT,
    repeat_teammate_rate_15d FLOAT,
    social_change FLOAT,

    -- patch meta
    patches_played INTEGER,
    meta_adoption_rate FLOAT,
    champion_switch_rate_between_patches FLOAT,

    -- target y (when observation window closes )
    disengaged_15d BOOLEAN,
    inactive_7d BOOLEAN,

);

INSERT INTO player_features_gold (
    puuid,
    sampling_tier,
    sampling_division ,
    tier ,
    rank ,
    matches_15d ,
    matches_30d ,
    matches_60d ,
    matches_90d ,
    active_days_15d ,
    active_days_90d ,
    days_since_last_match ,
    avg_days_between_matches_15d ,
    avg_days_between_matches_90d ,
    activity_change ,
    gap_change ,
    
    -- match duration
    avg_match_duration_15d ,
    avg_match_duration_90d ,
    match_duration_change ,

    -- role/ champ
    main_role ,
    main_role_share ,
    role_switch_rate ,
    unique_champions ,
    main_champion_share ,
    off_role_champion_rate ,

    -- performance,
    relative_damage ,
    relative_gold ,
    relative_farming ,
    relative_vision ,
    recent_performance_change ,
    objective_damage ,
    -- social
    unique_teammates ,
    repeat_teammate_rate ,
    max_teammate_match_share ,
    repeat_teammate_rate_15d ,
    social_change ,

    -- patch meta
    patches_played ,
    meta_adoption_rate ,
    champion_switch_rate_between_patches ,
    disengaged_15d ,
    inactive_7d,
)