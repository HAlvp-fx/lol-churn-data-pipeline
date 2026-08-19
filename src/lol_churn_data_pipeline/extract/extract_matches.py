import os
import json
from datetime import datetime, timezone, date
import requests
from dotenv import load_dotenv
from pathlib import Path

# API KEY
load_dotenv()
API_KEY = os.getenv("RIOT_API_KEY")
if not API_KEY:
    raise ValueError("RIOT_API_KEY not found in .env")


MATCH_BASE_URL = "https://europe.api.riotgames.com/lol/match/v5/matches"
SEEDS_PATH = Path("/workspaces/lol-churn-data-pipeline/data/bronze/players/seed_players_20260818_220020.json")

#Getting matches by period function (with puuid)
def get_match_ids(puuid, start_date, end_date, count=100):
    """
    Returns a list of match ids by a player in a time window 
    """
    start_time =int(datetime(start_date.year, start_date.month, start_date.day, tzinfo=timezone.utc).timestamp())

    end_time =int(datetime(end_date.year, end_date.month, end_date.day,tzinfo=timezone.utc).timestamp())

    URL = f"{MATCH_BASE_URL}/by-puuid/{puuid}/ids"

    response = requests.get(
        URL,
        headers={"X-Riot-Token": API_KEY},
        params={"startTime": start_time, "endTime": end_time,  "type": "ranked", "count": count},
    )

    response.raise_for_status()
    return response.json()

def get_match(match_id):
    """
    Returns the json for a specified match having its id
    """
    URL = f"{MATCH_BASE_URL}/{match_id}"

    response = requests.get(
        URL,
        headers={"X-Riot-Token": API_KEY},
    )

    response.raise_for_status()
    return response.json()


#EXTRACTION------------------------------------------------------------------------------

#Time window
start_date = date(2026, 6, 1)
end_date = date(2026, 7, 1)

#
with SEEDS_PATH.open("r", encoding="utf-8") as file:
    seeds_data = json.load(file)

for seed in seeds_data["seeds"]:
    puuid = seed["puuid"]
    tier = seed["sampling_tier"]

    match_ids = get_match_ids(
        puuid,
        start_date,
        end_date,
    )

    if not match_ids:
        print(f"No matches found for {tier}")
        continue

    match = get_match(match_ids[0])

    participants = match["metadata"]["participants"]

    print(
        f"{tier}: "
        f"{len(match_ids)} matches found, "
        f"{len(participants)} participants"
    )