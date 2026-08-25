import json
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

#function to load the data from the json into the table in the db
def load_champions(input_file):
    #open and read json file
    with input_file.open("r", encoding="utf-8") as file:
        champions = json.load(file)

    #checkpoint
    #print(champions["version"])
    #print(len(champions["data"]))

    #DATA LIST CREATION 
    # in the json there are a lot of nested items and I want a list of dicts per champion so load is easier
    rows=[]
    for champion in champions["data"].values():
        tags = champion.get("tags", [])
        info = champion.get("info", [])
        stats = champion.get("stats", [])

        row= {
        "champion_id": int(champion["key"]),
        "champion_code": champion["id"],
        "name": champion["name"],
        "title": champion.get("title"),
        "blurb": champion.get("blurb"),

        "primary_tag": tags[0] if len(tags) > 0 else None,
        "secondary_tag": tags[1] if len(tags) > 1 else None,
        "partype": champion.get("partype"),

        "attack": info.get("attack"),
        "defense": info.get("defense"),
        "magic": info.get("magic"),
        "difficulty": info.get("difficulty"),

        "hp": stats.get("hp"),
        "hp_per_level": stats.get("hpperlevel"),
        "mp": stats.get("mp"),
        "mp_per_level": stats.get("mpperlevel"),
        "move_speed": stats.get("movespeed"),
        "armor": stats.get("armor"),
        "armor_per_level": stats.get("armorperlevel"),
        "spell_block": stats.get("spellblock"),
        "spell_block_per_level": stats.get("spellblockperlevel"),
        "attack_range": stats.get("attackrange"),
        "hp_regen": stats.get("hpregen"),
        "hp_regen_per_level": stats.get("hpregenperlevel"),
        "mp_regen": stats.get("mpregen"),
        "mp_regen_per_level": stats.get("mpregenperlevel"),
        "crit": stats.get("crit"),
        "crit_per_level": stats.get("critperlevel"),
        "attack_damage": stats.get("attackdamage"),
        "attack_damage_per_level": stats.get("attackdamageperlevel"),
        "attack_speed_per_level": stats.get("attackspeedperlevel"),
        "attack_speed": stats.get("attackspeed"),

        "ddragon_version": champions["version"],
    }

        rows.append(row)

    #checkpoint
    print(rows[0])
    print(len(rows))

    #TABLE INSERTION PART
    load_dotenv()
    #the env vars
    user = os.getenv("POSTGRES_USER")
    password = os.getenv("POSTGRES_PASSWORD")
    database = os.getenv("POSTGRES_DB")

    database_url = (f"postgresql+psycopg://{user}:{password}@localhost:5432/{database}")

    engine = create_engine(database_url)

    #Insert command for the champion characteristics into the table
    insert_query = text("""
        INSERT INTO champions (
            champion_id,
            champion_code,
            name,
            title,
            blurb,
            primary_tag,
            secondary_tag,
            partype,
            attack,
            defense,
            magic,
            difficulty,
            hp,
            hp_per_level,
            mp,
            mp_per_level,
            move_speed,
            armor,
            armor_per_level,
            spell_block,
            spell_block_per_level,
            attack_range,
            hp_regen,
            hp_regen_per_level,
            mp_regen,
            mp_regen_per_level,
            crit,
            crit_per_level,
            attack_damage,
            attack_damage_per_level,
            attack_speed_per_level,
            attack_speed,
            ddragon_version
        )
        VALUES (
            :champion_id,
            :champion_code,
            :name,
            :title,
            :blurb,
            :primary_tag,
            :secondary_tag,
            :partype,
            :attack,
            :defense,
            :magic,
            :difficulty,
            :hp,
            :hp_per_level,
            :mp,
            :mp_per_level,
            :move_speed,
            :armor,
            :armor_per_level,
            :spell_block,
            :spell_block_per_level,
            :attack_range,
            :hp_regen,
            :hp_regen_per_level,
            :mp_regen,
            :mp_regen_per_level,
            :crit,
            :crit_per_level,
            :attack_damage,
            :attack_damage_per_level,
            :attack_speed_per_level,
            :attack_speed,
            :ddragon_version
        )
        ON CONFLICT (champion_id, ddragon_version)
        DO UPDATE SET
            name = EXCLUDED.name,
            title = EXCLUDED.title,
            blurb = EXCLUDED.blurb,
            primary_tag = EXCLUDED.primary_tag,
            secondary_tag = EXCLUDED.secondary_tag,
            partype = EXCLUDED.partype,
            attack = EXCLUDED.attack,
            defense = EXCLUDED.defense,
            magic = EXCLUDED.magic,
            difficulty = EXCLUDED.difficulty,
            hp = EXCLUDED.hp,
            hp_per_level = EXCLUDED.hp_per_level,
            mp = EXCLUDED.mp,
            mp_per_level = EXCLUDED.mp_per_level,
            move_speed = EXCLUDED.move_speed,
            armor = EXCLUDED.armor,
            armor_per_level = EXCLUDED.armor_per_level,
            spell_block = EXCLUDED.spell_block,
            spell_block_per_level = EXCLUDED.spell_block_per_level,
            attack_range = EXCLUDED.attack_range,
            hp_regen = EXCLUDED.hp_regen,
            hp_regen_per_level = EXCLUDED.hp_regen_per_level,
            mp_regen = EXCLUDED.mp_regen,
            mp_regen_per_level = EXCLUDED.mp_regen_per_level,
            crit = EXCLUDED.crit,
            crit_per_level = EXCLUDED.crit_per_level,
            attack_damage = EXCLUDED.attack_damage,
            attack_damage_per_level = EXCLUDED.attack_damage_per_level,
            attack_speed_per_level = EXCLUDED.attack_speed_per_level,
            attack_speed = EXCLUDED.attack_speed;
    """)

    #Execute the command written before
    with engine.begin() as connection:
        connection.execute(insert_query, rows)

    print(f"Loaded {len(rows)} champions into PostgreSQL.")