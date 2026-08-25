import json
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

def load_players(input_file):

    with input_file.open("r", encoding="utf-8") as file:
        players_file= json.load(file)

    #los metadatos de la descarag
    extracted_at = players_file["extracted_at"]
    platform = players_file["platform"]
    queue = players_file["queue"]

    rows=[]
    for player_data in players_file["players"]:
        row = {
            "puuid": player_data.get("puuid"),
            "league_points": player_data.get("leaguePoints"),
            "wins": player_data.get("wins"),
            "losses": player_data.get("losses"),
            "veteran": player_data.get("veteran"),
            "inactive": player_data.get("inactive"),
            "fresh_blood": player_data.get("freshBlood"),
            "hot_streak": player_data.get("hotStreak"),
            "sampling_tier": player_data.get("sampling_tier"),
            "sampling_division": player_data.get("sampling_division"),
            "tier": player_data.get("tier"),
            "rank": player_data.get("rank"),
            "queue": queue,
            "platform": platform,
            "extracted_at": extracted_at,
        }
        rows.append(row)

    #checks to see if things are loaded in the list of dicts
    print(rows[0])
    print(len(rows))

    #TABLE INSERt 
    load_dotenv()

    user = os.getenv("POSTGRES_USER")
    password = os.getenv("POSTGRES_PASSWORD")
    database = os.getenv("POSTGRES_DB")

    database_url = (f"postgresql+psycopg://{user}:{password}@localhost:5432/{database}")
    engine = create_engine(database_url)

    #Command to add the player characteristics into the player table
    insert_query = text(
         """
        INSERT INTO players_bronze (
            puuid,
            sampling_tier,
            sampling_division,
            tier,
            rank,
            league_points,
            wins,
            losses,
            veteran,
            inactive,
            fresh_blood,
            hot_streak,
            queue,
            platform,
            extracted_at
        )
        VALUES (
            :puuid,
            :sampling_tier,
            :sampling_division,
            :tier,
            :rank,
            :league_points,
            :wins,
            :losses,
            :veteran,
            :inactive,
            :fresh_blood,
            :hot_streak,
            :queue,
            :platform,
            :extracted_at
        )
        ON CONFLICT (puuid)
        DO UPDATE SET
            sampling_tier = EXCLUDED.sampling_tier,
            sampling_division = EXCLUDED.sampling_division,
            tier = EXCLUDED.tier,
            rank = EXCLUDED.rank,
            league_points = EXCLUDED.league_points,
            wins = EXCLUDED.wins,
            losses = EXCLUDED.losses,
            veteran = EXCLUDED.veteran,
            inactive = EXCLUDED.inactive,
            fresh_blood = EXCLUDED.fresh_blood,
            hot_streak = EXCLUDED.hot_streak,
            queue = EXCLUDED.queue,
            platform = EXCLUDED.platform,
            extracted_at = EXCLUDED.extracted_at
        """
    )

    
    #Execute the command
    with engine.begin() as connection:
            connection.execute(insert_query, rows)
    
    print(f"Loaded {len(rows)} players into PostgreSQL.")
