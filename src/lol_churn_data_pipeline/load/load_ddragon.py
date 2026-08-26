import json
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

def load_champions(input_file, version):

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
        info = champion.get("info", {})
        stats = champion.get("stats", {})
        
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

        "ddragon_version": version
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
        INSERT INTO champions_bronze (
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

def load_items(input_file, version):
    with input_file.open("r", encoding="utf-8") as file:
            items = json.load(file)

    rows=[]
    for item_id, item in items["data"].items():
        row = {
            "item_id": int(item_id),
            "ddragon_version": version,

            "name": item.get("name"),
            "description": item.get("description"),
            "colloq": item.get("colloq"),

            "from_items": json.dumps(item.get("from")),
            "into_items": json.dumps(item.get("into")),
            "depth": item.get("depth"),

            "gold_base": item.get("gold", {}).get("base"),
            "gold_total": item.get("gold", {}).get("total"),
            "gold_sell": item.get("gold", {}).get("sell"),
            "gold_purchasable": item.get("gold", {}).get("purchasable"),

            "consumed": item.get("consumed"),
            "stacks": item.get("stacks"),
            "consume_on_full": item.get("consumeOnFull"),
            "special_recipe": item.get("specialRecipe"),
            "in_store": item.get("inStore"),
            "hide_from_all": item.get("hideFromAll"),

            "required_champion": item.get("requiredChampion"),
            "required_ally": item.get("requiredAlly"),

            "tags": json.dumps(item.get("tags")),
            "maps": json.dumps(item.get("maps")),
            "stats": json.dumps(item.get("stats")),
            "rune": json.dumps(item.get("rune")),
        }
        rows.append(row)
    #checkpoint
    print("Example item:", rows[0])
    print(f"Number of item rows  {len(rows)} in version: {version}")

    #TABLE INSERTION PART
    load_dotenv()
    #the env vars
    user = os.getenv("POSTGRES_USER")
    password = os.getenv("POSTGRES_PASSWORD")
    database = os.getenv("POSTGRES_DB")
    database_url = (f"postgresql+psycopg://{user}:{password}@localhost:5432/{database}")
    engine = create_engine(database_url)
    
    #COMMAND
    insert_query = text("""
    INSERT INTO items_bronze (
        item_id,
        ddragon_version,
        name,
        description,
        colloq,
        from_items,
        into_items,
        depth,
        gold_base,
        gold_total,
        gold_sell,
        gold_purchasable,
        consumed,
        stacks,
        consume_on_full,
        special_recipe,
        in_store,
        hide_from_all,
        required_champion, 
        required_ally,
        tags,
        maps,
        stats,
        rune           
    )
    VALUES (
        :item_id,
        :ddragon_version,
        :name,
        :description,
        :colloq,
        CAST(:from_items AS JSONB),
        CAST(:into_items AS JSONB),
        :depth,
        :gold_base,
        :gold_total,
        :gold_sell,
        :gold_purchasable,
        :consumed,
        :stacks,
        :consume_on_full,
        :special_recipe,
        :in_store,
        :hide_from_all,
        :required_champion, 
        :required_ally,
        CAST(:tags AS JSONB),
        CAST(:maps AS JSONB),
        CAST(:stats AS JSONB),
        CAST(:rune AS JSONB)           
    )
    ON CONFLICT (item_id, ddragon_version)
    DO UPDATE SET
        item_id= EXCLUDED.item_id,
        ddragon_version= EXCLUDED.ddragon_version,
        name= EXCLUDED.name,
        description= EXCLUDED.description,
        colloq= EXCLUDED.colloq,
        from_items= EXCLUDED.from_items,
        into_items= EXCLUDED.into_items,
        depth= EXCLUDED.depth,
        gold_base= EXCLUDED.gold_base,
        gold_total= EXCLUDED.gold_total,
        gold_sell= EXCLUDED.gold_sell,
        gold_purchasable= EXCLUDED.gold_purchasable,
        consumed= EXCLUDED.consumed,
        stacks= EXCLUDED.stacks,
        consume_on_full= EXCLUDED.consume_on_full,
        special_recipe= EXCLUDED.special_recipe,
        in_store= EXCLUDED.in_store,
        hide_from_all= EXCLUDED.hide_from_all,
        required_champion= EXCLUDED.required_champion, 
        required_ally= EXCLUDED.required_ally,
        tags= EXCLUDED.tags,
        maps= EXCLUDED.maps,
        stats= EXCLUDED.stats,
        rune= EXCLUDED.rune
""")
    #Execute the command written before
    with engine.begin() as connection:
        connection.execute(insert_query, rows)
    print(f"Loaded {len(rows)} items into PostgreSQL.")

def load_runes (input_file, version):

    with input_file.open("r", encoding="utf-8") as file:
        runes= json.load(file)
    rows=[]
    for rune_style in runes:
        id_rune_style = rune_style["id"]
        key_rune_style = rune_style["key"]
        name_rune_style = rune_style["name"]

        for slot_index, slot in enumerate(rune_style["slots"]):
            for rune in slot["runes"]:
                row = {
                    "id_rune": rune.get("id"),
                    "key": rune.get("key"),
                    "name": rune.get("name"),
                    "short_desc": rune.get("shortDesc"),
                    "long_desc": rune.get("longDesc"),
                    "slot": slot_index,
                    "id_rune_style": id_rune_style,
                    "key_rune_style": key_rune_style,
                    "name_rune_style": name_rune_style,
                    "ddragon_version": version,
                }

                rows.append(row)
    #checkpoint
    print("Example rune:", rows[0])
    print(f"Number of rune rows  {len(rows)} in version: {version}")

    #TABLE INSERTION PART
    load_dotenv()
    #the env vars
    user = os.getenv("POSTGRES_USER")
    password = os.getenv("POSTGRES_PASSWORD")
    database = os.getenv("POSTGRES_DB")
    database_url = (f"postgresql+psycopg://{user}:{password}@localhost:5432/{database}")
    engine = create_engine(database_url)

    #COMANDO
    insert_query = text("""
        INSERT INTO runes_bronze (
            id_rune,
            key,
            name,
            short_desc,
            long_desc,
            slot,
            id_rune_style,
            key_rune_style,
            name_rune_style,
            ddragon_version
        )
        VALUES (
            :id_rune,
            :key,
            :name,
            :short_desc,
            :long_desc,
            :slot,
            :id_rune_style,
            :key_rune_style,
            :name_rune_style,
            :ddragon_version           
        )
        ON CONFLICT (id_rune, ddragon_version)
        DO UPDATE SET
            id_rune=EXCLUDED.id_rune,
            key=EXCLUDED.key,
            name=EXCLUDED.name,
            short_desc = EXCLUDED.short_desc,
            long_desc = EXCLUDED.long_desc,
            slot=EXCLUDED.slot,
            id_rune_style = EXCLUDED.id_rune_style,
            key_rune_style=EXCLUDED.key_rune_style,
            name_rune_style=EXCLUDED.name_rune_style,
            ddragon_version=EXCLUDED.ddragon_version
    """)
        #Execute the command written before
    with engine.begin() as connection:
        connection.execute(insert_query, rows)
    print(f"Loaded {len(rows)} runes into PostgreSQL.")

def load_summoners(input_file, version):
    
    with input_file.open("r", encoding="utf-8") as file:
        summoners = json.load(file)

    rows = []
    for summoner in summoners["data"].values():
        row = {
            "summoner_spell_id": int(summoner["key"]),
            "spell_code": summoner["id"],
            "ddragon_version": version,

            "name": summoner.get("name"),
            "description": summoner.get("description"),
            "tooltip": summoner.get("tooltip"),

            "max_rank": summoner.get("maxrank"),
            "summoner_level": summoner.get("summonerLevel"),

            "cooldown": json.dumps(summoner.get("cooldown")),
            "cooldown_burn": summoner.get("cooldownBurn"),

            "cost": json.dumps(summoner.get("cost")),
            "cost_burn": summoner.get("costBurn"),
            "cost_type": summoner.get("costType"),
            "resource": summoner.get("resource"),

            "range_values": json.dumps(summoner.get("range")),
            "range_burn": summoner.get("rangeBurn"),
            "max_ammo": summoner.get("maxammo"),

            "data_values": json.dumps(summoner.get("datavalues")),
            "effect": json.dumps(summoner.get("effect")),
            "effect_burn": json.dumps(summoner.get("effectBurn")),
            "vars": json.dumps(summoner.get("vars")),

            "modes": json.dumps(summoner.get("modes")),
        }

        rows.append(row)

    # Check
    print(rows[0])
    print(f"Number of summoner rows: {len(rows)} in version: {version}")

    # PostgreSQL connection
    load_dotenv()
    user = os.getenv("POSTGRES_USER")
    password = os.getenv("POSTGRES_PASSWORD")
    database = os.getenv("POSTGRES_DB")
    database_url = (f"postgresql+psycopg://{user}:{password}@localhost:5432/{database}")
    engine = create_engine(database_url)
    #COMANDO
    insert_query = text("""
        INSERT INTO summoner_spells_bronze (
            summoner_spell_id,
            spell_code,
            ddragon_version,
            name,
            description,
            tooltip,
            max_rank,
            summoner_level,
            cooldown,
            cooldown_burn,
            cost,
            cost_burn,
            cost_type,
            resource,
            range_values,
            range_burn,
            max_ammo,
            data_values,
            effect,
            effect_burn,
            vars,
            modes
        )
        VALUES (
            :summoner_spell_id,
            :spell_code,
            :ddragon_version,
            :name,
            :description,
            :tooltip,
            :max_rank,
            :summoner_level,
            CAST(:cooldown AS JSONB),
            :cooldown_burn,
            CAST(:cost AS JSONB),
            :cost_burn,
            :cost_type,
            :resource,
            CAST(:range_values AS JSONB),
            :range_burn,
            :max_ammo,
            CAST(:data_values AS JSONB),
            CAST(:effect AS JSONB),
            CAST(:effect_burn AS JSONB),
            CAST(:vars AS JSONB),
            CAST(:modes AS JSONB)
        )
        ON CONFLICT (summoner_spell_id, ddragon_version)
        DO UPDATE SET
            spell_code = EXCLUDED.spell_code,
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            tooltip = EXCLUDED.tooltip,
            max_rank = EXCLUDED.max_rank,
            summoner_level = EXCLUDED.summoner_level,
            cooldown = EXCLUDED.cooldown,
            cooldown_burn = EXCLUDED.cooldown_burn,
            cost = EXCLUDED.cost,
            cost_burn = EXCLUDED.cost_burn,
            cost_type = EXCLUDED.cost_type,
            resource = EXCLUDED.resource,
            range_values = EXCLUDED.range_values,
            range_burn = EXCLUDED.range_burn,
            max_ammo = EXCLUDED.max_ammo,
            data_values = EXCLUDED.data_values,
            effect = EXCLUDED.effect,
            effect_burn = EXCLUDED.effect_burn,
            vars = EXCLUDED.vars,
            modes = EXCLUDED.modes;
    """)

    with engine.begin() as connection:
        connection.execute(insert_query, rows)
    print(f"Loaded {len(rows)} summoner spells for Data Dragon {version} into Postgre")


#MASTER LOADER
def load_historical_ddragon(ddragon_folder):

    for version_folder in sorted(ddragon_folder.iterdir()):
        if not version_folder.is_dir():
            continue
        version = version_folder.name
        print(f"\nLoading Data Dragon version {version}...")

        champions_file = version_folder / "champion.json"
        items_file = version_folder / "item.json"
        runes_file = version_folder / "runesReforged.json"
        summoners_file = version_folder / "summoner.json"

        if champions_file.exists():
            load_champions(champions_file, version)
        if items_file.exists():
            load_items(items_file, version)
        if runes_file.exists():
            load_runes(runes_file, version)
        if summoners_file.exists():
            load_summoners(summoners_file, version)

    print("\nFinished loading historical Data Dragon data.")