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

## Tech stack

- Python
- PostgreSQL
- Docker / Docker Compose
- Riot Games API
- Data Dragon
- SQL
- uv
- Git / GitHub

## Status

🚧 Work in progress — Master's Thesis project.

**Currently implemented**

- Stratified ranked player sampling through League-V4
- Fixed modelling cohort at T0 across ranks from Iron to Diamond
- 90-day historical match extraction through Match-V5
- Match deduplication and complete participant-level data extraction
- Data Dragon champion extraction
- Bronze PostgreSQL schemas for champions, players, and match participants
- Bronze loading pipeline
- Raw nested Match-V5 data preservation using JSONB
- Dockerized PostgreSQL environment
- Configurable pipeline for independent extraction and loading stages
- Initial data profiling and schema validation

**Next steps**
- Extend Data Dragon extraction to include historical patches
- Extract and store item metadata from Data Dragon
- Complete and validate the Bronze layer (with the items and historicals)
- Build Silver player and match-level tables
- Enrich historical matches with patch-specific champion and item metadata
- Define churn observation and target windows
- Feature engineering
- Exploratory data analysis
- Churn modelling and evaluation
