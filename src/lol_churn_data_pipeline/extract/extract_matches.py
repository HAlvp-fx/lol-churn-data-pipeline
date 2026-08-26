import json

from datetime import datetime, timezone, date, timedelta
from pathlib import Path

from lol_churn_data_pipeline.extract.riot import riot_get
from lol_churn_data_pipeline.config import MATCH_BASE_URL,FEATURE_START, COHORT_DATE, FEATURE_START,FEATURE_WINDOW_DAYS,MATCHES_FOLDER, TARGET_BY_TIER, MATCH_QUEUE_ID

# MATCH-V5 FUNCTIONS

def get_match_ids(puuid, start_date, end_date, start=0, count=100):
    """
    Returns one page of ranked match IDs for a player within the specified period.
    `start` controls pagination and `count` controls how many match IDs are requested,
    with a maximum of 100 per request (one page).
    """

    start_time = int(datetime(start_date.year,start_date.month,start_date.day,tzinfo=timezone.utc).timestamp())
    end_time = int(datetime(end_date.year,end_date.month,end_date.day,tzinfo=timezone.utc).timestamp())

    url = (f"{MATCH_BASE_URL}/by-puuid/{puuid}/ids")

    params = {
    "startTime": start_time,
    "endTime": end_time,
    "queue": MATCH_QUEUE_ID,
    "start": start,
    "count": count,
    }
    return riot_get( url, params=params)


def get_all_match_ids(puuid, start_date, end_date):
    """
    Returns ALL ranked match IDs for a player within the specified period.
    Match-V5 returns at most 100 IDs per request, so this function automatically paginates
    until all match IDs have been retrieved.
    """

    all_match_ids = []

    start = 0
    count = 100

    while True:
        match_ids = get_match_ids(
            puuid=puuid,
            start_date=start_date,
            end_date=end_date,
            start=start,
            count=count,
        )

        all_match_ids.extend(match_ids)

        # if Riot returns < 100, there are no more pags
        if len(match_ids) < count:
            break

        start += count
    return all_match_ids


def get_match(match_id):
    """
    Returns the complete Match-V5 JSON for a given match ID.
    """
    url = f"{MATCH_BASE_URL}/{match_id}"
    return riot_get(url)


# ACTIVITY FUNCTIONS

def extract_match_history(candidate_file, feature_start, cohort_date):
    """
    Downloads the full 90 day raw history for the T0 candidate sample
    """

    with candidate_file.open("r", encoding="utf-8") as file:
        candidate_data = json.load(file)

    players = candidate_data["players"]
    print(f"Loaded {len(players)} candidate players.")

    # Save the player -> match IDs map before downloading all MatchDto files
    manifest_dir = Path("data") / "bronze" / "match_manifests"
    manifest_dir.mkdir(parents=True, exist_ok=True)
    manifest_file = (manifest_dir/ f"match_history_{cohort_date.strftime('%Y%m%d')}.json")

    # If manifest exists, reuse it
    if manifest_file.exists():
        print(f"Manifest already exists: {manifest_file}")
        print("Loading match IDs from manifest...")

        with manifest_file.open("r", encoding="utf-8") as file:
            manifest = json.load(file)

        player_matches = manifest["player_matches"]

        unique_match_ids = set()

        for match_ids in player_matches.values():
            unique_match_ids.update(match_ids)

        print(f"Loaded {len(unique_match_ids)} unique match IDs from manifest.")
    else: 
        print("No manifest found. Getting player histories from Riot...")

        player_matches = {}
        unique_match_ids = set()

        for i, player in enumerate(players, start=1):
            puuid = player["puuid"]
            tier = player["sampling_tier"]

            print(f"Getting history {i}/{len(players)} ({tier})..." )

            match_ids = get_all_match_ids(puuid=puuid,start_date=feature_start, end_date=cohort_date)

            player_matches[puuid] = match_ids
            unique_match_ids.update(match_ids)

            print(f" {len(match_ids)} matches found")

        print(f"\nUnique matches to download:{len(unique_match_ids)}")

        manifest = {
            "extracted_at": datetime.now(timezone.utc).isoformat(),
            "cohort_date": cohort_date.isoformat(),
            "feature_window_start": feature_start.isoformat(),
            "feature_window_end": cohort_date.isoformat(),
            "feature_window_days": (cohort_date - feature_start).days,
            "queue_id": MATCH_QUEUE_ID,
            "candidate_player_count": len(players),
            "unique_match_count": len(unique_match_ids),
            "player_matches": player_matches
        }

        with manifest_file.open("w", encoding="utf-8") as file:
            json.dump( manifest, file,ensure_ascii=False, indent=2)

        print(f"Manifest saved to {manifest_file}")

    # Raw MatchDto files
    match_output_dir = ( Path("data")/ "bronze"/ "matches"/ cohort_date.strftime("%Y%m%d"))
    match_output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Raw matches stored in {match_output_dir}")

    sorted_match_ids = sorted(unique_match_ids)

    for i, match_id in enumerate(sorted_match_ids, start=1):
        output_file = match_output_dir / f"{match_id}.json"

        # If it was already downloaded before, don't ask Riot again
        if output_file.exists():
            print(f"Match {i}/{len(sorted_match_ids)} {match_id} already exists: skip")
            continue

        print(f"Downloading match {i}/{len(sorted_match_ids)}{match_id}...")

        match = get_match(match_id)

        with output_file.open("w", encoding="utf-8") as file:
            json.dump( match, file, ensure_ascii=False, indent=2)

    return manifest_file, match_output_dir

if __name__ == "__main__":
 
    CANDIDATE_FILE = Path(
        "data/bronze/players/"
        "candidate_players_20260820_213216.json"
    )

    extract_match_history(
        candidate_file=CANDIDATE_FILE,
        feature_start=FEATURE_START,
        cohort_date=COHORT_DATE,
    )