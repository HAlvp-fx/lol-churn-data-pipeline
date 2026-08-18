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
    Every time this function is executed it returns a list of all 
    the players in the tier and division specified
    """
    url = (
        f"https://{PLATFORM}.api.riotgames.com"
        f"/lol/league/v4/entries/"
        f"{QUEUE}/{tier}/{division}"
    )

    response = requests.get(url, headers={"X-Riot-Token": API_KEY})
    response.raise_for_status()

    return response.json()


# SELECT RANDOM SEED

def get_random_seed(tier):

    divisions = DIVISIONS.copy()

    random.shuffle(divisions)

    for division in divisions:
        players = get_league_entries(
            tier=tier,
            division=division,
        )

        if players:
            player = random.choice(players)

            #To keep a record of the tier and division at time of the sample
            player["sampling_tier"] = tier
            player["sampling_division"] = division

            return player

    raise ValueError(
        f"No players found for tier {tier}"
    )


# -----------------------------
# EXTRACT SEEDS FOR ALL TIERS
# -----------------------------

def extract_seed_players():
    seeds = []

    for tier in TIERS:
        print(f"Selecting random seed for {tier}...")

        player = get_random_seed(tier)

        seeds.append(player)

    extracted_at = datetime.now(timezone.utc)

    output_dir = (Path("data")/ "bronze"/ "riot"/ "players")

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
        "seeds": seeds,
    }

    with output_file.open(
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            output,
            file,
            ensure_ascii=False,
            indent=2,
        )

    print(
        f"Saved {len(seeds)} seed players "
        f"to {output_file}"
    )

    return seeds


# -----------------------------
# RUN DIRECTLY
# -----------------------------

if __name__ == "__main__":
    seed_players = extract_seed_players()

    for player in seed_players:
        print(
            player["sampling_tier"],
            player["sampling_division"],
            player["puuid"],
        )