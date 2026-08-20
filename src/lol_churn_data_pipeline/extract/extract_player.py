import json
import os
import random
import time

from datetime import datetime, timezone
from pathlib import Path

import requests
from dotenv import load_dotenv

from lol_churn_data_pipeline.extract.riot import riot_get

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


# GET PLAYERS FROM LEAGUE-V4

def get_league_entries(tier, division):
    """
    Returns the ranked players available for a given
    tier and division at extraction time.
    """

    url = (
        f"https://{PLATFORM}.api.riotgames.com"
        f"/lol/league/v4/entries/"
        f"{QUEUE}/{tier}/{division}"
    )

    return riot_get(url)

def get_random_players(tier, n):
    """
    Returns n different random players from a randomly
    selected division within the given tier.
    """
    divisions = DIVISIONS.copy()
    random.shuffle(divisions)

    for division in divisions:
        players = get_league_entries(tier=tier, division=division)
        if len(players) >= n:

            sampled_players = random.sample(players,n)

            for player in sampled_players:
                player["sampling_tier"] = tier
                player["sampling_division"] = division

            return sampled_players

    raise ValueError(
        f"Could not find {n} players for tier {tier}"
    )

def extract_players(players_per_tier):
    """
    Extracts a stratified sample of ranked players
    across the configured tiers.
    """

    players = []

    for tier in TIERS:

        print(
            f"Selecting {players_per_tier} players from {tier}...")

        tier_players = get_random_players(tier=tier, n=players_per_tier)

        players.extend(tier_players)

    extracted_at = datetime.now(timezone.utc)

    output_dir = (Path("data")/ "bronze"/ "players")
    output_dir.mkdir(parents=True,exist_ok=True)

    filename = (f"candidate_players_{extracted_at.strftime('%Y%m%d_%H%M%S')}.json")

    output_file = output_dir / filename

    output = {"extracted_at": extracted_at.isoformat(),
        "platform": PLATFORM,
        "queue": QUEUE,
        "players_per_tier": players_per_tier,
        "players": players,
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
        f"Saved {len(players)} candidate players "
        f"to {output_file}"
    )

    return players



if __name__ == "__main__":

    players = extract_players(
        players_per_tier=5
    )

    for player in players:
        print(
            player["sampling_tier"],
            player["sampling_division"],
            player["puuid"]
        )