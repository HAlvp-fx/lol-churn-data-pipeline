import time
import requests
from dotenv import load_dotenv
import os
# API KEY

load_dotenv()

API_KEY = os.getenv("RIOT_API_KEY")

if not API_KEY:
    raise ValueError("RIOT_API_KEY not found in .env")



def riot_get(url, params=None):
    """
    Sends a GET request to the Riot API and if the API rate limit is reached, waits for the amount of time
    indicated by Riot before retrying the request.
    """

    while True:
        response = requests.get(
            url,
            headers={"X-Riot-Token": API_KEY},
            params=params,
            timeout=30,
        )

        if response.status_code == 429:
            retry_after = int(
                response.headers.get("Retry-After", 1)
            )

            print(
                f"Rate limit reached. "
                f"Waiting {retry_after} seconds..."
            )

            time.sleep(retry_after)
            continue

        response.raise_for_status()

        return response.json()