import json
from pathlib import Path
from collections import Counter


def list_unique_fields (filespath):
    fields = Counter()
    challenges = Counter()
    total_participants = 0
    total_challenges = 0

    print("Depending on the number of matches recorded this might take a while, please be patient")

    for file_path in filespath.glob("*.json"):
        with file_path.open("r", encoding="utf-8") as file:
            match = json.load(file)
        participants = match["info"]["participants"]
        for participant in participants:
            total_participants += 1
            fields.update(participant.keys())
            for challenge in participant["challenges"]:
                total_challenges+=1
                challenges.update(challenges.keys())


    print(f"\nTotal participant records: {total_participants}")
    print(f"\nUnique challenges recorded : {total_challenges}")
    for field in sorted(fields):
        print(field, fields[field])
    #for challenge in sorted(challenges):
    #   print(challenge, challenges[challenge])

#execution
path=Path("data/bronze/matches/20260820")

list_unique_fields(path)

"""
Total participant records: 786800
Unique challenges recorded : 100354661

Because of the nature of the challenges I have decided to keep them as a json in the match_player tab. 

PlayerBehavior 786800
PlayerScore0 786800
PlayerScore1 786800
PlayerScore10 786800
PlayerScore11 786800
PlayerScore2 786800
PlayerScore3 786800
PlayerScore4 786800
PlayerScore5 786800
PlayerScore6 786800
PlayerScore7 786800
PlayerScore8 786800
PlayerScore9 786800
allInPings 786800
assistMePings 786800
assists 786800
baronKills 786800
basicPings 786800
causedGameEndFromIGNBSurrender 786800
challenges 786800
champExperience 786800
champLevel 786800
championId 786800
championName 786800
championTransform 786800
commandPings 786800
consumablesPurchased 786800
damageDealtToBuildings 786800
damageDealtToEpicMonsters 786800
damageDealtToObjectives 786800
damageDealtToTurrets 786800
damageSelfMitigated 786800
dangerPings 786800
deaths 786800
detectorWardsPlaced 786800
doubleKills 786800
dragonKills 786800
eligibleForProgression 786800
enemyMissingPings 786800
enemyVisionPings 786800
firstBloodAssist 786800
firstBloodKill 786800
firstTowerAssist 786800
firstTowerKill 786800
gameEndedInEarlySurrender 786800
gameEndedInIGNBSurrender 786800
gameEndedInSurrender 786800
getBackPings 786800
goldEarned 786800
goldSpent 786800
holdPings 786800
individualPosition 786800
inhibitorKills 786800
inhibitorTakedowns 786800
inhibitorsLost 786800
item0 786800
item1 786800
item2 786800
item3 786800
item4 786800
item5 786800
item6 786800
itemsPurchased 786800
killingSprees 786800
kills 786800
lane 786800
largestCriticalStrike 786800
largestKillingSpree 786800
largestMultiKill 786800
longestTimeSpentLiving 786800
magicDamageDealt 786800
magicDamageDealtToChampions 786800
magicDamageTaken 786800
missions 786800
needVisionPings 786800
neutralMinionsKilled 786800
nexusKills 786800
nexusLost 786800
nexusTakedowns 786800
objectivesStolen 786800
objectivesStolenAssists 786800
onMyWayPings 786800
participantId 786800
pentaKills 786800
perks 786800
physicalDamageDealt 786800
physicalDamageDealtToChampions 786800
physicalDamageTaken 786800
placement 786800
playerAugment1 786800
playerAugment2 786800
playerAugment3 786800
playerAugment4 786800
playerAugment5 786800
playerAugment6 786800
playerSubteamId 786800
positionAssignedByMatchmaking 731340
profileIcon 786800
pushPings 786800
puuid 786800
quadraKills 786800
retreatPings 786800
riotIdGameName 786800
riotIdTagline 786800
role 786800
roleBoundItem 786800
selectedRolePreferences 731340
sightWardsBoughtInGame 786800
spell1Casts 786800
spell2Casts 786800
spell3Casts 786800
spell4Casts 786800
subteamPlacement 786800
summoner1Casts 786800
summoner1Id 786800
summoner2Casts 786800
summoner2Id 786800
summonerId 786800
summonerLevel 786800
summonerName 786800
teamEarlySurrendered 786800
teamIGNBSurrendered 786800
teamId 786800
teamPosition 786800
timeCCingOthers 786800
timePlayed 786800
totalAllyJungleMinionsKilled 786800
totalDamageDealt 786800
totalDamageDealtToChampions 786800
totalDamageShieldedOnTeammates 786800
totalDamageTaken 786800
totalEnemyJungleMinionsKilled 786800
totalHeal 786800
totalHealsOnTeammates 786800
totalMinionsKilled 786800
totalTimeCCDealt 786800
totalTimeSpentDead 786800
totalUnitsHealed 786800
tripleKills 786800
trueDamageDealt 786800
trueDamageDealtToChampions 786800
trueDamageTaken 786800
turretKills 786800
turretTakedowns 786800
turretsLost 786800
unrealKills 786800
visionClearedPings 786800
visionScore 786800
visionWardsBoughtInGame 786800
wardsKilled 786800
wardsPlaced 786800
wasAfk 68060
wasPremadeWithIGNBGameEndCauser 786800
wasPremadeWithSevereTransgressor 786800
wasSevereTransgressor 786800
win 786800
"""