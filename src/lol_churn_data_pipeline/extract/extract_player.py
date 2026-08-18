import json
import os
import random
from datetime import datetime, timezone
from pathlib import Path

import requests
from dotenv import load_dotenv


# CONFIGURATION
RANDOM_SEED = 3
random.seed(RANDOM_SEED)

PLATFORM = "euw1"
QUEUE = "RANKED_SOLO_5x5"

TIERS = [
    "IRON",
    "BRONZE",
    "SILVER",
    "GOLD",
    "PLATINUM",
    "EMERALD",
    "DIAMOND",
]

DIVISIONS = [
    "I",
    "II",
    "III",
    "IV",
]

# API KEY

load_dotenv()

API_KEY = os.getenv("RIOT_API_KEY")

if not API_KEY:
    raise ValueError("RIOT_API_KEY not found in .env")



# GET PLAYERS FROM LEAGUE-V4 function

def get_league_entries(tier, division):
    """
    Returns the players stored at a given tier and rank at the time of execution
    """
    PLAYER_PATH = (
        f"https://{PLATFORM}.api.riotgames.com"
        f"/lol/league/v4/entries/"
        f"{QUEUE}/{tier}/{division}"
    )

    response = requests.get(PLAYER_PATH, headers={"X-Riot-Token": API_KEY})
    response.raise_for_status()     #In case there is a error response from server

    return response.json()          #json to pyton object


# SELECT RANDOM SEED

def get_random_seed(tier):
    """
    Returns a random player from the given tier and a random rank. 
    """
    divisions = DIVISIONS.copy()

    random.shuffle(divisions)

    for division in divisions:
        players = get_league_entries(
            tier=tier,
            division=division,
        )

        if players:                         #This will only work if there are players
            player = random.choice(players) #Picks one player

            #To keep a record of the tier and division at time of the sample
            player["sampling_tier"] = tier
            player["sampling_division"] = division

            return player

    raise ValueError(
        f"No players found for tier {tier}"
    )


# EXTRACT SEEDS FOR ALL TIERS

def extract_seed_players():

    """
    The function is the one that executes the previous ones. It stores the seed players that
    will be used to get historic matches and grow the database. After selecting a player from
    each tier and a random division the player dict gets stored  
    """
    seeds = []

    for tier in TIERS:
        print(f"Selecting random seed for {tier}...")

        player = get_random_seed(tier)

        seeds.append(player)

    extracted_at = datetime.now(timezone.utc)

    output_dir = (Path("data")/ "bronze"/ "players")

    output_dir.mkdir(parents=True, exist_ok=True)

    filename = (
        f"seed_players_"
        f"{extracted_at.strftime('%Y%m%d_%H%M%S')}.json"
    )

    output_file = output_dir / filename

    output = {
        "extracted_at": extracted_at.isoformat(),
        "platform": PLATFORM,
        "queue": QUEUE,
        "seeds": seeds
    }

    #to write the .json
    with output_file.open("w", encoding="utf-8") as file:
        json.dump(output, file, ensure_ascii=False, indent=2)
    print(
        f"Saved {len(seeds)} seed players "
        f"to {output_file}"
    )

    return seeds


# RUN DIRECTLY

#This is neccesary so the extraction doesn't occur everytime I call a function from this file.
if __name__ == "__main__":
    seed_players = extract_seed_players()

    for player in seed_players:
        print(
            player["sampling_tier"],
            player["sampling_division"],
            player["puuid"],
        )