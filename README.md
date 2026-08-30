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

## Silver layer

The Silver layer transforms the source-preserving Bronze data into cleaned and validated relational datasets while maintaining traceability to the original Riot data.

The current Silver layer contains:

- **1,400 players** in `players_silver`;
- **78,954 tracked-player match records** in `player_matches_silver`;
- **78,680 unique matches** in `matches_silver`;
- **295,437 unique teammate relationships** in `teammates_silver`;
- versioned champion, item, rune and summoner spell reference tables.

The tables have deliberately different grains:

- `players_silver` — one row per sampled player;
- `player_matches_silver` — one row per sampled player and match;
- `matches_silver` — one row per unique match;
- `teammates_silver` — one row per unique unordered teammate pair;
- Data Dragon Silver tables — one entity per historical Data Dragon version.

`player_matches_silver` contains only players belonging to the modelling cohort. In contrast, `matches_silver` and `teammates_silver` are constructed using the complete Bronze participant data so that match and teammate context is not lost when the other participants are outside the original cohort.

Teammate relationships use a canonical unordered pair representation to prevent storing both `(A, B)` and `(B, A)`. Relationships are retained even when players only appeared together once; thresholds for repeated interaction are intentionally deferred to the analytical and feature-engineering stages.

Historical Data Dragon entities remain versioned in Silver. Mechanical attributes are preserved so that changes between patches can later be measured and evaluated alongside changes in player behaviour.

Match versions are mapped to Data Dragon using their major/minor patch version, with validation confirming that every observed match patch has a corresponding and unambiguous Data Dragon version.

### Silver validation

Silver is validated against Bronze before being used for feature engineering.

The validation suite currently contains **56 checks** covering:

- expected tables and primary keys;
- row-count reconciliation between Bronze and Silver;
- table grains and duplicate detection;
- cohort integrity;
- player-level aggregate reconstruction;
- participant-level transformation logic;
- match-level aggregation;
- team composition and winner consistency;
- teammate relationship reconstruction;
- historical Data Dragon version preservation;
- patch-specific champion, item and summoner spell resolution.

The completed validation run produced:

- **0 blocking failures**
- **51 passed checks**
- **5 warnings requiring review**

The remaining warnings correspond to source-level or boundary cases rather than failed Bronze-to-Silver transformations. These include a small number of unrecognised team positions, matches around the historical-window boundary, matches without a reported winning team, teammate role counts affected by missing positions, and special item identifiers requiring additional interpretation.

These cases are retained rather than silently modified so that unusual source behaviour remains traceable during later analytical stages.

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
- Fixed 1,400-player modelling cohort at T0
- 90-day historical Match-V5 extraction
- Match ID deduplication before full Match-V5 retrieval
- Complete participant-level Bronze preservation
- Historical Data Dragon extraction across the required patch range
- Versioned champion, item, rune and summoner spell ingestion
- Bronze PostgreSQL schema and batched ingestion pipeline
- Nested source-data preservation using JSONB
- Dockerized PostgreSQL environment
- Configurable pipeline for independent extraction and loading stages
- Bronze data profiling and validation
- Silver player-level transformation
- Silver participant-level transformation
- Silver match-level aggregation
- Silver teammate relationship construction
- Versioned Silver Data Dragon reference tables
- Match-to-Data Dragon patch mapping
- Bronze-to-Silver reconciliation and validation
- Silver integrity, grain and quality checks

**Next steps**

- Define the churn observation and target windows
- Build Gold player-level feature tables
- Engineer behavioural and activity features
- Engineer teammate and social-interaction features
- Measure relevant historical patch changes
- Exploratory data analysis
- Churn modelling and evaluation
