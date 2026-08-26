import json
from pathlib import Path
from collections import Counter


def list_unique_fields (filespath):
    fields = Counter()
    challenges = Counter()
    total_participants = 0
    participants_with_challenges=0

    print("Depending on the number of matches recorded this might take a while, please be patient")

    for file_path in filespath.glob("*.json"):
        with file_path.open("r", encoding="utf-8") as file:
            match = json.load(file)
        participants = match["info"]["participants"]
        for participant in participants:
            total_participants += 1
            fields.update(participant.keys())
            participant_challenges = participant.get("challenges", {})

            if participant_challenges:
                participants_with_challenges += 1
                challenges.update(participant_challenges.keys())

    print(f"Total participants: {total_participants}")
    print(f"Participants with challenges: {participants_with_challenges}")
    print(f"Unique challenges recorded: {len(challenges)}")

    for challenge in sorted(challenges):
        print(challenge, challenges[challenge])

#execution
path=Path("data/bronze/matches/20260820")

list_unique_fields(path)

"""
Total participants: 786800
Participants with challenges: 786800
Unique challenges recorded: 142

12AssistStreakCount 786800
HealFromMapSources 786800
InfernalScalePickup 786800
SWARM_DefeatAatrox 786800
SWARM_DefeatBriar 786800
SWARM_DefeatMiniBosses 786800
SWARM_EvolveWeapon 786800
SWARM_Have3Passives 786800
SWARM_KillEnemy 786800
SWARM_PickupGold 786800
SWARM_ReachLevel50 786800
SWARM_Survive15Min 786800
SWARM_WinWith5EvolvedWeapons 786800
abilityUses 786800
acesBefore15Minutes 786800
alliedJungleMonsterKills 786800
baronBuffGoldAdvantageOverThreshold 169775
baronTakedowns 786800
blastConeOppositeOpponentCount 786800
bountyGold 786800
buffsStolen 786800
completeSupportQuestInTime 786800
controlWardTimeCoverageInRiverOrEnemyHalf 233743
controlWardsPlaced 786800
damagePerMinute 786800
damageTakenOnTeamPercentage 786800
dancedWithRiftHerald 786800
deathsByEnemyChamps 786800
dodgeSkillShotsSmallWindow 786800
doubleAces 786800
dragonTakedowns 786800
earliestBaron 319870
earliestDragonTakedown 408482
earliestElderDragon 34735
earlyLaningPhaseGoldExpAdvantage 746958
effectiveHealAndShielding 786800
elderDragonKillsWithOpposingSoul 786800
elderDragonMultikills 786800
enemyChampionImmobilizations 786800
enemyJungleMonsterKills 786800
epicMonsterKillsNearEnemyJungler 786800
epicMonsterKillsWithin30SecondsOfSpawn 786800
epicMonsterSteals 786800
epicMonsterStolenWithoutSmite 786800
fasterSupportQuestCompletion 37598
fastestLegendary 47712
firstTurretKilled 786800
firstTurretKilledTime 371900
fistBumpParticipation 786800
flawlessAces 786800
fullTeamTakedown 786800
gameLength 786800
getTakedownsInAllLanesEarlyJungleAsLaner 629360
goldPerMinute 786800
hadAfkTeammate 24279
hadOpenNexus 786800
highestChampionDamage 78586
highestCrowdControlScore 78073
highestWardKills 90858
immobilizeAndKillWithAlly 786800
initialBuffCount 786800
initialCrabCount 786800
jungleCsBefore10Minutes 786800
junglerKillsEarlyJungle 157354
junglerTakedownsNearDamagedEpicMonster 786800
kTurretsDestroyedBeforePlatesFall 786800
kda 786800
killAfterHiddenWithAlly 786800
killParticipation 756960
killedChampTookFullTeamDamageSurvived 786800
killingSprees 786800
killsNearEnemyTurret 786800
killsOnLanersEarlyJungleAsJungler 157354
killsOnOtherLanesEarlyJungleAsLaner 629360
killsOnRecentlyHealedByAramPack 786800
killsUnderOwnTurret 786800
killsWithHelpFromEpicMonster 786800
knockEnemyIntoTeamAndKill 786800
landSkillShotsEarlyGame 786800
laneMinionsFirst10Minutes 786800
laningPhaseGoldExpAdvantage 741642
legendaryCount 786800
legendaryItemUsed 786800
lostAnInhibitor 786800
maxCsAdvantageOnLaneOpponent 747638
maxKillDeficit 786800
maxLevelLeadLaneOpponent 747638
mejaisFullStackInTime 786800
moreEnemyJungleThanOpponent 786800
multiKillOneSpell 786800
multiTurretRiftHeraldCount 786800
multikills 786800
multikillsAfterAggressiveFlash 786800
outerTurretExecutesBefore10Minutes 786800
outnumberedKills 786800
outnumberedNexusKill 786800
perfectDragonSoulsTaken 786800
perfectGame 786800
pickKillWithAlly 786800
playedChampSelectPosition 747528
poroExplosions 786800
quickCleanse 786800
quickFirstTurret 786800
quickSoloKills 786800
riftHeraldTakedowns 786800
saveAllyFromDeath 786800
scuttleCrabKills 786800
shortestTimeToAceFromFirstTakedown 176612
skillshotsDodged 786800
skillshotsHit 786800
snowballsHit 786800
soloBaronKills 786800
soloKills 786800
soloTurretsLategame 166171
stealthWardsPlaced 786800
survivedSingleDigitHpCount 786800
survivedThreeImmobilizesInFight 786800
takedownOnFirstTurret 786800
takedowns 786800
takedownsAfterGainingLevelAdvantage 786800
takedownsBeforeJungleMinionSpawn 786800
takedownsFirstXMinutes 786800
takedownsInAlcove 786800
takedownsInEnemyFountain 786800
teamBaronKills 786800
teamDamagePercentage 784840
teamElderDragonKills 786800
teamRiftHeraldKills 786800
teleportTakedowns 39997
tookLargeDamageSurvived 786800
turretPlatesTaken 786800
turretTakedowns 786800
turretsTakenWithRiftHerald 786800
twentyMinionsIn3SecondsCount 786800
twoWardsOneSweeperCount 786800
unseenRecalls 786800
visionScoreAdvantageLaneOpponent 747638
visionScorePerMinute 786800
voidMonsterKill 786800
wardTakedowns 786800
wardTakedownsBefore20M 786800
wardsGuarded 786800
"""