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
    Returns the ranked players available for a given tier and division at extraction time.
    """
    url = (f"https://{PLATFORM}.api.riotgames.com/lol/league/v4/entries/{QUEUE}/{tier}/{division}")
    return riot_get(url)

def get_random_players(tier, n):
    """
    Returns n different random players from a division within the given tier
    """
    candidates = []

    for division in DIVISIONS:
        print(f"Loading {tier} {division}...")
        players = get_league_entries(tier=tier, division=division)


        for player in players:
        # Copy it so we don't mess with the original response object
            candidate = player.copy()
            candidate["sampling_tier"] = tier
            candidate["sampling_division"] = division

            candidates.append(candidate)

    if len(candidates) < n:
        raise ValueError(
            f"Only {len(candidates)} candidates found for {tier} but {n} were requested"
        )

    return random.sample(candidates, n)

def extract_candidate_players(target_by_tier):
    """
    Create the T0 stratified League-V4 player sample.
    """

    players = []
    selected_puuids = set()

    for tier in TIERS:
        target = target_by_tier[tier]

        print(f"\nSelecting {target} players from {tier}...")

        tier_players = get_random_players( tier=tier, n=target)

        # This should normally be unnecessary, but it protects us from duplicates
        for player in tier_players:
            puuid = player["puuid"]

            if puuid not in selected_puuids:
                players.append(player)
                selected_puuids.add(puuid)

    extracted_at = datetime.now(timezone.utc)

    output_dir = Path("data") / "bronze" / "players"
    output_dir.mkdir(parents=True, exist_ok=True)

    filename = (f"candidate_players_{extracted_at.strftime('%Y%m%d_%H%M%S')}.json")

    output_file = output_dir / filename
    output = {
        "extracted_at": extracted_at.isoformat(),
        "platform": PLATFORM,
        "queue": QUEUE,
        "sampling_method": "stratified_random_by_current_tier",
        "random_seed": RANDOM_SEED,
        "target_by_tier": target_by_tier,
        "player_count": len(players),
        "players": players,
    }

    with output_file.open("w", encoding="utf-8") as file:
        json.dump(output, file, ensure_ascii=False, indent=2)

    print(f"\nSaved {len(players)} candidate players to {output_file}")
    return output_file

TARGET_BY_TIER = {
    "IRON": 200,
    "BRONZE": 200,
    "SILVER": 200,
    "GOLD": 200,
    "PLATINUM": 200,
    "EMERALD": 200,
    "DIAMOND": 200,
}
if __name__ == "__main__":
    extract_candidate_players(
        target_by_tier=TARGET_BY_TIER,
    )