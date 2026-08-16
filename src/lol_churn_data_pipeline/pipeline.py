from lol_churn_data_pipeline.extract.extract_ddragon import (
    extract_champions,
    get_latest_version,
)
from lol_churn_data_pipeline.load.load_ddragon import load_champions

latest_version= get_latest_version()

bronze_file= extract_champions(latest_version)

load_champions(bronze_file)