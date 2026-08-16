import json
from pathlib import Path
import requests

# VERSION RETRIEVAL
VERSION_PATH="https://ddragon.leagueoflegends.com/api/versions.json"

def get_latest_version():
    response = requests.get(VERSION_PATH)
    response.raise_for_status()         #In case there is a error response from server

    versions = response.json()          # JSON response body -> Python object
    return versions[0]                  #Version for the download path     

#CHAMPIONS REQUEST
#Code will always get the latest version
def extract_champions(version):
    CHAMPIONS_URL = (
    f"https://ddragon.leagueoflegends.com/cdn/{version}/data/en_US/champion.json"
    )

    response_champions= requests.get(CHAMPIONS_URL)

    response_champions.raise_for_status()   #In case there is a error response from server
    champions=response_champions.json()     # JSON response body -> Python object

    #checkpoint
    #print(type(champions))
    #print(champions.keys())
    #print(type(champions["data"]))
    #print(champions["data"].keys())

    #Path creation for the folder where the data will be stored
    output_dir = Path("data") / "bronze" / "ddragon" / version   #path defining
    output_dir.mkdir(parents=True, exist_ok=True)                       #folder creation-creates parents if not there & cont if folder exists

    #exporting to a json file
    output_file = output_dir / "champion.json"
    with output_file.open("w", encoding="utf-8") as file:
        json.dump(champions, file, ensure_ascii=False, indent=2)    #writting iin the file
    return output_file

#With this the files won't get redownloaded very time I want to access the version
if __name__ == "__main__":
    latest_version = get_latest_version()
    output_file = extract_champions(latest_version)

    print(f"Saved Data Dragon {latest_version} to {output_file}")