# League of Legends Churn Data Pipeline

End-to-end data engineering and machine learning project designed to study player behaviour and predict player churn in League of Legends.

## Project overview

The project builds a reproducible data pipeline using data from the Riot Games API and Data Dragon.

The pipeline is designed around a Bronze / Silver / Gold architecture:

- **Bronze:** raw data extracted from Riot APIs and Data Dragon.
- **Silver:** cleaned, validated and normalized relational data.
- **Gold:** player-level features for churn analysis and machine learning.

- The final objective is to identify behavioural patterns associated with players reducing or stopping their activity.

## Architecture
```
Riot Games API / Data Dragon
        ↓
     Extract
        ↓
     Bronze
        ↓
    Transform
        ↓
     Silver
        ↓
 Feature Engineering
        ↓
      Gold
        ↓
 Churn Modelling
```

PostgreSQL is used as the analytical database and runs in Docker.

## Current data sources

- **Data Dragon** — champion metadata and base statistics.
- **League-V4** — ranked player sampling.
- **Match-V5** — historical match and player activity data.

## Historical player sampling

The modelling cohort is constructed from a stratified sample of ranked players
from the EUW server.

At the cohort date (T0), I sample players across ranked tiers from Iron to Diamond, selecting a fixed number of players from each tier. I decided to exclude Master, Grandmaster and Challenger because these tiers are subject to specific activity requirements and LP decay mechanics (players at these ranks must remain sufficiently active to maintain their position, which could systematically underrepresent disengaging players and introduce bias into a churn analysis). I use stratified sampling across the remaining tiers to obtain representation across different levels of competitive play rather than allowing the sample to be dominated by the most common ranks.

For each sampled player, I retrieve their ranked match history from the 90 days preceding T0 and to reduce the number of request to the api (the are limits to how many I can do and since I wanted a large sample I needed to optimize a bit), I deduplicate match IDs across players before downloading the corresponding Match-V5 data.

I retain the complete participant data from these matches in the Bronze layer, rather than filtering the matches to include only the originally sampled players. The sampled players define my modelling cohort and historical extraction window, while keeping all participants allows me to preserve the full raw context of each match.

This process produces a reproducible historical snapshot containing:

- the sampled player cohort at T0;
- their rank and sampling information at T0;
- up to 90 days of ranked match history before T0;
- the complete participant-level records for the retrieved matches.

In later transformation stages, I will use this Bronze data to construct the features required for modelling and to define the churn target, while preserving the riginal extracted data in the Bronze layer.


## Bronze layer

The Bronze layer preserves the extracted data with minimal transformation while storing it in PostgreSQL for use by later stages of the pipeline. Fields related exclusively to Data Dragon visual assets, such as image and sprite metadata, are intentionally excluded from the relational Bronze tables, as they are not relevant to the behavioural analysis or churn modelling objectives of the project.

The current Bronze dataset contains:

- **1,400 sampled players** defining the modelling cohort;
- **78,685 historical match files** retrieved through Match-V5;
- **786,800 participant-level match records** loaded into PostgreSQL;
- versioned champion metadata;
- versioned item metadata;
- versioned rune metadata;
- versioned summoner spell metadata.

Historical Data Dragon data is stored by version, allowing later transformation stages to enrich matches using metadata corresponding to the patch in which each match was played.

The current historical Data Dragon coverage includes **7 versions, from 16.10.1 to 16.16.1**.

Nested structures that are not yet normalized are preserved as JSONB in the Bronze layer to avoid discarding source information before the Silver transformation stage.


## Tech stack

- Python
- PostgreSQL
- Docker Compose
- Riot Games API
- Data Dragon
- SQL
- SQLAlchemy
- psycopg
- uv
- Git 

## Status

🚧 Work in progress — Master's Thesis project.

**Currently implemented**

- Stratified ranked player sampling through League-V4
- Fixed modelling cohort at T0 across ranks from Iron to Diamond
- 90-day historical match extraction through Match-V5
- Match deduplication and complete participant-level data extraction
- Historical Data Dragon extraction for the required patch range
- Versioned champion metadata extraction and loading
- Versioned item metadata extraction and loading
- Versioned rune metadata extraction and loading
- Versioned summoner spell metadata extraction and loading
- Bronze PostgreSQL schemas for players, match participants, champions, items, runes and summoner spells
- Batched loading of participant-level Match-V5 data
- Raw nested data preservation using JSONB
- Dockerized PostgreSQL environment
- Configurable pipeline for independent extraction and loading stages
- Data profiling and Bronze schema validation
- PostgreSQL row-count validation after ingestion

**Next steps**

- Build Silver player and match-level tables
- Clean and normalize Bronze data into the Silver layer
- Associate historical matches with their corresponding Data Dragon version
- Enrich historical matches with patch-specific champion, item, rune, and summoner spell metadata
- Define churn observation and target windows
- Feature engineering
- Exploratory data analysis
- Churn modelling and evaluation
