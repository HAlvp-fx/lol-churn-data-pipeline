import json
from pathlib import Path
import requests
from lol_churn_data_pipeline.config import VERSION_PATH, FEATURE_START,MATCHES_FOLDER

DDRAGON_BASE_URL = "https://ddragon.leagueoflegends.com/cdn"
"""
def get_latest_version():
    response = requests.get(VERSION_PATH)
    response.raise_for_status()         #In case there is a error response from server

    versions = response.json()          # JSON response body -> Python object
    return versions[0]                  #Version for the download path     
"""

#Basically the following functions work together, one inside the next one to get the
#listas all the versions of the patch file that exists in the ddragon endpoint, checks what
# are the unique patch numbesr from the matches recorded and gets the latest build for each one in ddargon
#Extracts them and then store each separate element into a file to load to the tables
def get_available_versions():
    """
    Returns all valid Data Dragon versions, ordered newest -> oldest (I can't pick up only the latest bc there are patches every 2 weeks or so...)
    """
    response = requests.get(VERSION_PATH)
    response.raise_for_status()
    return response.json()

def get_patches_from_matches(matches_folder):
    """
    Reads the downloaded Match-V5 files and returns the unique patches represented in the dataset.
    Example:
        gameVersion = '16.14.693.1234'
        patch       = '16.14'
    """
    print("This will take a while, please be patient since it is running through all the recorded matches")
    patches = set()
    for file_path in matches_folder.glob("*.json"):
        with file_path.open("r", encoding="utf-8") as file:
            match = json.load(file)

        game_version = match["info"]["gameVersion"]
        version_parts = game_version.split(".")
        patch = ".".join(version_parts[:2])
        patches.add(patch)
    return sorted(patches)

def get_ddragon_versions_for_patches(patches):
    """
    Maps each patch present in the Match-V5 data to the newest available Data Dragon build for that patch.
    (bc according to the riot api  for devs there can be multiple builds for each patch (I'm picking the latest))
    """
    available_versions = get_available_versions()
    selected_versions = []
    for patch in patches:

        matching_versions = [version for version in available_versions
            if version.startswith(f"{patch}.")]
        if matching_versions:
            # versions.json is sorted from latest  oldest, so the first one is the latest build for the patch
            selected_versions.append(matching_versions[0])

    return selected_versions
def extract_ddragon_file(version, filename):
    """
    Downloads a versioned Data Dragon JSON file and stores it  in the Bronze layer
    """

    url = (f"{DDRAGON_BASE_URL}/{version}/data/en_US/{filename}")

    output_dir = (Path("data")/ "bronze"/ "ddragon"/ version)
    output_dir.mkdir(parents=True,exist_ok=True)
    output_file = output_dir / filename

    # Avoid downloading the same static file again
    if output_file.exists():
        return output_file

    response = requests.get(url)
    response.raise_for_status()
    data = response.json()

    with output_file.open("w",encoding="utf-8") as file:
        json.dump(data,file,ensure_ascii=False,indent=2)
    print(f"Saved {filename} for Data Dragon {version}")

    return output_file


def extract_historical_ddragon(matches_folder):
    """
    Downloads the Data Dragon assets required by the patchs represented in the historical matches dataset
    """

    patches = get_patches_from_matches(matches_folder)
    print(f"Patches found in match history: {patches}")

    versions = get_ddragon_versions_for_patches(patches)
    print(f"Data Dragon versions required: {versions}")

    for version in versions:
        extract_ddragon_file(version,"champion.json")
        extract_ddragon_file(version,"item.json")
        extract_ddragon_file(version,"summoner.json")
        extract_ddragon_file(version,"runesReforged.json")

if __name__ == "__main__":
    extract_historical_ddragon(MATCHES_FOLDER)