# League of Legends Churn Data Pipeline

End-to-end data engineering and machine learning project designed to study
player behaviour and predict player churn in League of Legends.

## Project overview

The project builds a reproducible data pipeline using data from the Riot Games
API and Data Dragon.

The pipeline is designed around a Bronze / Silver / Gold architecture:

- **Bronze:** raw data extracted from Riot APIs.
- **Silver:** cleaned and normalized relational data.
- **Gold:** player-level features for churn analysis and machine learning.
- The final objective is to identify behavioural patterns associated with
players reducing or stopping their activity.

## Architecture
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

PostgreSQL is used as the analytical database and runs in Docker.

## Current data sources

- **Data Dragon** — champion metadata and base statistics.
- **League-V4** — ranked player sampling.
- **Match-V5** — historical match and player activity data.

## Historical player sampling

A key challenge is avoiding survivorship bias when selecting players.

Instead of using currently ranked players directly as the modelling cohort,
current ranked players are used as **seed players** to locate historical
matches.

Participants from those historical matches are then used to construct a
historically active player cohort.

This allows the dataset to potentially contain both players who remain active
and players whose activity subsequently decreases.

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

Currently implemented:
- Data Dragon extraction and transformation
- PostgreSQL loading
- Dockerized PostgreSQL environment
- Ranked player sampling through League-V4
- Historical match extraction through Match-V5
- Initial historical cohort sampling strategy

Next steps:
- Scale historical player sampling
- Build Silver match/player tables
- Define churn observation windows
- Feature engineering
- Exploratory analysis and modelling
