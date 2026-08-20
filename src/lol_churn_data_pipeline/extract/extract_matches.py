import json

from datetime import datetime, timezone, date
from pathlib import Path

from lol_churn_data_pipeline.extract.riot import riot_get


# CONFIG

MATCH_BASE_URL = ("https://europe.api.riotgames.com/lol/match/v5/matches")


# MATCH-V5 FUNCTIONS

def get_match_ids(puuid, start_date, end_date, start=0, count=100):
    """
    Returns one page of ranked match IDs for a player within the specified period.
    `start` controls pagination and `count` controls how many match IDs are requested,
    with a maximum of 100 per request.
    """

    start_time = int(
        datetime(
            start_date.year,
            start_date.month,
            start_date.day,
            tzinfo=timezone.utc,
        ).timestamp()
    )

    end_time = int(
        datetime(
            end_date.year,
            end_date.month,
            end_date.day,
            tzinfo=timezone.utc,
        ).timestamp()
    )

    url = (f"{MATCH_BASE_URL}/by-puuid/{puuid}/ids")

    params = {
        "startTime": start_time,
        "endTime": end_time,
        "type": "ranked",
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

def has_recent_activity(puuid, start_date,end_date):
    """
    Checks whether a player has at least one ranked match in the specified period 
    (only one match ID is requested because I only need to know whether activity exists)
    """
    match_ids = get_match_ids(puuid=puuid,start_date=start_date, end_date=end_date,count=1)
    return len(match_ids) > 0


def filter_active_players(players,start_date,end_date):
    """
    Filters candidate players according to recent ranked activity and returns only players with at least 
    one ranked match inside the activity window.
    """

    active_players = []

    for i, player in enumerate(players,start=1):

        puuid = player["puuid"]

        print(f"Checking player {i}/{len(players)}{player['sampling_tier']})...")

        is_active = has_recent_activity(puuid=puuid, start_date=start_date, end_date=end_date)

        if is_active:
            player["recent_activity"] = True
            active_players.append(player)
            print(" ACTIVE")

        else:
            player["recent_activity"] = False
            print(" NO RECENT MATCHES")

    return active_players


# COHORT EXTRACTION
def create_active_cohort(input_file, activity_start, cohort_date):
    """
    Reads candidate players, checks whether they were recently active, and stores the valid
    players as a cohort snapshot.
    The cohort_date acts as T0 for the study.
    """
    # candidate players
    with input_file.open("r", encoding="utf-8") as file:
        candidate_file = json.load(file)
    players = candidate_file["players"]

    print(f"Loaded {len(players)} candidate players.")

    # Filter by recent activity
    active_players = filter_active_players(
        players=players,
        start_date=activity_start,
        end_date=cohort_date,
    )

    # Timestamp of cohort creation
    extracted_at = datetime.now(timezone.utc)

    # Out folder
    output_dir = (Path("data")/ "bronze"/ "cohorts")
    output_dir.mkdir(parents=True, exist_ok=True)

    # Out filename
    filename = (f"active_cohort_{cohort_date.strftime('%Y%m%d')}.json")

    output_file = output_dir / filename

    # Metadata + cohort
    output = {
        "extracted_at": extracted_at.isoformat(),
        "cohort_date": cohort_date.isoformat(),
        "activity_window_start": (
            activity_start.isoformat()
        ),
        "activity_window_end": (
            cohort_date.isoformat()
        ),
        "platform": candidate_file["platform"],
        "queue": candidate_file["queue"],
        "candidate_count": len(players),
        "active_player_count": len(active_players),
        "players": active_players,
    }

    #cohort snapshot
    with output_file.open("w", encoding="utf-8") as file:
        json.dump(output,file,ensure_ascii=False,indent=2)

    print(f"Active players: {len(active_players)}/{len(players)}")

    print(f"Cohort saved to {output_file}")

    return active_players


# RUN DIRECTLY
if __name__ == "__main__":

    # Candidate player file generated by extract_player.py
    CANDIDATES_PATH = Path(
        "data/bronze/players/"
        "candidate_players_20260820_140137.json"
    )

    # Temporary activity criterion for the pilot, I can compare 7 / 14 / 30 days before deciding
    # which definition to use for the final cohort.
    activity_start = date(2026,7,21)

    cohort_date = date(2026,8,20)

    cohort_players = create_active_cohort(
        input_file=CANDIDATES_PATH,
        activity_start=activity_start,
        cohort_date=cohort_date
    )