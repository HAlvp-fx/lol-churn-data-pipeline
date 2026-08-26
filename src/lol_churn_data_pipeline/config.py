from datetime import date, timedelta
from pathlib import Path

RANDOM_SEED = 3
# Project paths
PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = PROJECT_ROOT / "data"

BRONZE_DIR = DATA_DIR / "bronze"
DDRAGON_DIR = BRONZE_DIR / "ddragon"
MATCHES_DIR = BRONZE_DIR / "matches"


# Cohort dates
COHORT_DATE = date(2026, 8, 20)
FEATURE_WINDOW_DAYS = 90
FEATURE_START = COHORT_DATE - timedelta(days=FEATURE_WINDOW_DAYS)


# Existing Bronze data
MATCHES_FOLDER = MATCHES_DIR / COHORT_DATE.strftime("%Y%m%d")
DDRAGON_FOLDERS = Path("/workspaces/lol-churn-data-pipeline/data/bronze/ddragon/")
PLAYERS_FILE = Path("data/bronze/players/candidate_players_20260820_213216.json")

# Sampling
TARGET_BY_TIER = {
    "IRON": 200,
    "BRONZE": 200,
    "SILVER": 200,
    "GOLD": 200,
    "PLATINUM": 200,
    "EMERALD": 200,
    "DIAMOND": 200,
}
MATCH_QUEUE_ID = 420
PLATFORM = "euw1"
QUEUE = "RANKED_SOLO_5x5"
TIERS = [
    "IRON",
    "BRONZE",
    "SILVER",
    "GOLD",
    "PLATINUM",
    "EMERALD",
    "DIAMOND"
]
DIVISIONS = [
    "I",
    "II",
    "III",
    "IV"
]


#links to the api endpoints
MATCH_BASE_URL = "https://europe.api.riotgames.com/lol/match/v5/matches"
VERSION_PATH="https://ddragon.leagueoflegends.com/api/versions.json"

