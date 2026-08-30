from lol_churn_data_pipeline.extract.extract_ddragon import extract_historical_ddragon
from lol_churn_data_pipeline.load.load_ddragon import load_historical_ddragon

from lol_churn_data_pipeline.extract.extract_player import extract_candidate_players
from lol_churn_data_pipeline.load.load_players import load_players

from lol_churn_data_pipeline.extract.extract_matches import extract_match_history
from lol_churn_data_pipeline.load.load_playersMatches import load_match_participants

from lol_churn_data_pipeline.config import TARGET_BY_TIER, DDRAGON_FOLDERS, COHORT_DATE,FEATURE_START, MATCHES_FOLDER, PLAYERS_FILE

from pathlib import Path
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

def create_sql_tables(sql_files):
    load_dotenv()

    user = os.getenv("POSTGRES_USER")
    password = os.getenv("POSTGRES_PASSWORD")
    database = os.getenv("POSTGRES_DB")

    database_url = (f"postgresql+psycopg://{user}:{password}@localhost:5432/{database}")

    engine = create_engine(database_url)

    with engine.begin() as connection:
        for sql_file in sql_files:
            with sql_file.open("r", encoding="utf-8") as file:
                sql_command = file.read()
            connection.execute(text(sql_command))


def run_pipeline (stratification_method, 
                extract_ddragon=False,
                extract_players=False,
                extract_matches=False,
                do_load_ddragon=False,
                do_load_players=False,
                do_load_matches=False,
                create_bronze_tabs=False,
                do_silver_matches=False,
                do_silver_players=False,
                do_silver_playersMatches=False,
                do_silver_ddragon=False,
                do_silver_teammates=False):

    if create_bronze_tabs:
        create_sql_tables([
        Path("sql/001_bronze_champions.sql"),
        Path("sql/001_bronze_players.sql"),
        Path("sql/001_bronze_playersMatches.sql"),
        Path("sql/001_bronze_items.sql"),
        Path("sql/001_bronze_runes.sql"),
        Path("sql/001_bronze_summoners.sql"),
    ])
    

    # Players extraction & load
    if extract_players:
        players_file = extract_candidate_players(stratification_method)
    else:
        players_file = PLAYERS_FILE
    if do_load_players:
        load_players(players_file)

    #Matches extraction
    if extract_matches:
        manifest_file, matches_folder = extract_match_history(
            candidate_file=players_file,
            feature_start=FEATURE_START,
            cohort_date=COHORT_DATE
            )
    else:
        matches_folder = MATCHES_FOLDER
    if do_load_matches:
        load_match_participants(matches_folder)

    #Data dragon stuff extraction & load
    if extract_ddragon:
        extract_historical_ddragon(matches_folder)
        print("Extraction of ddragon done!")
    if do_load_ddragon:
        load_historical_ddragon(DDRAGON_FOLDERS)
        print("Load of ddragon done!")
    if do_silver_matches :
        create_sql_tables([Path("sql/002_silver_matches.sql")])
        print("Creation and transform of matches in silver done!")
    if do_silver_players :
        create_sql_tables([Path("sql/002_silver_players.sql")])
        print("Creation and transform of players in silver done!")
    if do_silver_playersMatches :
        create_sql_tables([Path("sql/002_silver_playersMatches.sql")])
        print("Creation and transform of players' matches in silver done!")
    if do_silver_ddragon :
            create_sql_tables([Path("sql/002_silver_champions.sql"),
                               Path("sql/002_silver_runes.sql"),
                               Path("sql/002_silver_summoners.sql"),
                               Path("sql/002_silver_items.sql")])
            print("Creation and transform& insert of ddragon data in silver done!")
    if do_silver_teammates :
            create_sql_tables([Path("sql/002_silver_teammates.sql")])
            print("Creation and insert data into table teammates in silver done!")




# executing it
#I have already downloaded the matches for the sample on the set day so I'll
# just use the looad functions
#For reference:
#extract_ddragon=False -> no request to riot api
#extract_players=False -> no request to riot api
# extract_matches=False -> no request to riot api
#do_load_ddragon=False -> no load the extracted champion and maybe item data in the tables
#do_load_players=False -> no load the extracted player data in the tables
#do_load_matches=False -> no load the extracted matches data in the tables
#create_bronze_tables=True -> creates the sql tables in the specified db, docker needs to be up


#Personal settings 
target_by_tier=TARGET_BY_TIER
if __name__ == "__main__":
    run_pipeline(
        stratification_method=target_by_tier,
        create_bronze_tabs=True,
        extract_ddragon=False,
        extract_players=False,
        extract_matches=False,
        do_load_ddragon=True,
        do_load_players=False,
        do_load_matches=False,
        do_silver_matches=False,
        do_silver_players=False,
        do_silver_playersMatches=False,
        do_silver_ddragon=True,
        do_silver_teammates=True)
