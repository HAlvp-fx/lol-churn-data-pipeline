from lol_churn_data_pipeline.extract.extract_ddragon import extract_champions, get_latest_version
from lol_churn_data_pipeline.load.load_ddragon import load_champions

from lol_churn_data_pipeline.extract.extract_player import extract_candidate_players
from lol_churn_data_pipeline.load.load_players import load_players

from lol_churn_data_pipeline.extract.extract_matches import extract_match_history
from lol_churn_data_pipeline.load.load_playersMatches import load_match_participants
from datetime import date, timedelta
from pathlib import Path



def run_pipeline(stratification_method, 
                extract_ddragon=False,
                extract_players=False,
                extract_matches=False,
                do_load_ddragon=False,
                do_load_players=False,
                do_load_matches=False):

    
    #Data dragon stuff extraction & load
    if extract_ddragon:
        latest_version = get_latest_version()
        bronze_champions = extract_champions(latest_version)
    else:
        bronze_champions = CHAMPIONS_FILE
    if do_load_ddragon:
        load_champions(bronze_champions)

    # Players extraction & load
    if extract_players:
        players_file = extract_candidate_players(stratification_method)
    else:
        players_file = PLAYERS_FILE
    if do_load_players:
        load_players(players_file)

    #Matches extraction
    if extract_matches:
        matches_folder = extract_match_history(
            candidate_file=players_file,
            feature_start=FEATURE_START,
            cohort_date=COHORT_DATE,
        )
    else:
        matches_folder = MATCHES_FOLDER
    if do_load_matches:

        load_match_participants(matches_folder)



# executing it
#I have already downloaded the matches for the sample on the set day so I'll
# just use the looad functions
#For reference:
#extract_data=False = NO Riot request and NO re-extraction
#load_data=True = YES load existing Bronze into PostgreSQL


#Personal settings 

COHORT_DATE = date(2026, 8, 20)
FEATURE_START = COHORT_DATE - timedelta(days=90)
MATCHES_FOLDER = Path("/workspaces/lol-churn-data-pipeline/data/bronze/matches/20260820")
CHAMPIONS_FILE = Path("/workspaces/lol-churn-data-pipeline/data/bronze/ddragon/16.16.1/champion.json")
PLAYERS_FILE = Path("data/bronze/players/candidate_players_20260820_213216.json")
target_by_tier={
            "IRON": 200,
            "BRONZE": 200,
            "SILVER": 200,
            "GOLD": 200,
            "PLATINUM": 200,
            "EMERALD": 200,
            "DIAMOND": 200,
        }

if __name__ == "__main__":
    run_pipeline(
        stratification_method=target_by_tier,
        extract_ddragon=False,
        extract_players=False,
        extract_matches=False,
        do_load_ddragon=True,
        do_load_players=True,
        do_load_matches=True)
