include( "UtilityFunctions.lua" );
include("FLuaVector.lua");
include("PlotIterators.lua")
-- SaveUtils
WARN_NOT_SHARED = false; include( "SaveUtils" ); MY_MOD_NAME = "Scarlet";
-- 万古长战
local ScarletEWID = GameInfo.UnitPromotions["PROMOTION_ETERNAL_WARDRAKE"].ID

local ScarletTransport = 0
----------------------------------------------------------------------------------------------------------------------------
local isSPEx = false
local isSPExID = "41450919-c52c-406f-8752-5ea34be32b2d"

for _, mod in pairs(Modding.GetActivatedMods()) do
	if (mod.ID == isSPExID) then
		isSPEx = true
		break
	end
end
----------------------------------------------------------------------------------------------------------------------------
function GetCloseCity ( iPlayer, plot )
	local pPlayer = Players[iPlayer]
	local distance = 1000
	local closeCity = nil
	if pPlayer == nil then
		print ("nil")
		return nil
	end

	if pPlayer:GetNumCities() <= 0 then 
		print ("No Cities!")
		return
	end

	for pCity in pPlayer:Cities() do
		distanceToCity = Map.PlotDistance(pCity:GetX(), pCity:GetY(), plot:GetX(), plot:GetY())
		if ( distanceToCity < distance) then
			distance = distanceToCity
			closeCity = pCity
		end
	end
	return closeCity
end
----------------------------------------------------------------------------------------------------------------------------
local g_DoScarletCombat = nil;
function ScarletCombatStarted(iType, iPlotX, iPlotY)
	if iType == GameInfoTypes["BATTLETYPE_MELEE"]
	or iType == GameInfoTypes["BATTLETYPE_RANGED"]
	or iType == GameInfoTypes["BATTLETYPE_AIR"]
	or iType == GameInfoTypes["BATTLETYPE_SWEEP"]
	then
		g_DoScarletCombat = {
			attPlayerID = -1,
			attUnitID   = -1,
			defPlayerID = -1,
			defUnitID   = -1,
			attODamage  = 0,
			defODamage  = 0,
			PlotX = iPlotX,
			PlotY = iPlotY,
			bIsCity = false,
			defCityID = -1,
			battleType = iType,
		};
		--print("战斗开始.")
	end
end

GameEvents.BattleStarted.Add(ScarletCombatStarted);
function ScarletCombatJoined(iPlayer, iUnitOrCity, iRole, bIsCity)
	if g_DoScarletCombat == nil
	or Players[ iPlayer ] == nil or not Players[ iPlayer ]:IsAlive()
	or (not bIsCity and Players[ iPlayer ]:GetUnitByID(iUnitOrCity) == nil)
	or (bIsCity and (Players[ iPlayer ]:GetCityByID(iUnitOrCity) == nil or iRole == GameInfoTypes["BATTLEROLE_ATTACKER"]))
	or iRole == GameInfoTypes["BATTLEROLE_BYSTANDER"]
	then
		return;
	end
	if bIsCity then
		g_DoScarletCombat.defPlayerID = iPlayer;
		g_DoScarletCombat.defCityID = iUnitOrCity;
		g_DoScarletCombat.bIsCity = bIsCity;
	elseif iRole == GameInfoTypes["BATTLEROLE_ATTACKER"] then
		g_DoScarletCombat.attPlayerID = iPlayer;
		g_DoScarletCombat.attUnitID = iUnitOrCity;
		g_DoScarletCombat.attODamage = Players[ iPlayer ]:GetUnitByID(iUnitOrCity):GetDamage();
	elseif iRole == GameInfoTypes["BATTLEROLE_DEFENDER"] or iRole == GameInfoTypes["BATTLEROLE_INTERCEPTOR"] then
		g_DoScarletCombat.defPlayerID = iPlayer;
		g_DoScarletCombat.defUnitID = iUnitOrCity;
		g_DoScarletCombat.defODamage = Players[ iPlayer ]:GetUnitByID(iUnitOrCity):GetDamage();
	end
	
	-- Prepare for Capture Unit!
	if not bIsCity and g_DoScarletCombat.battleType == GameInfoTypes["BATTLETYPE_MELEE"]
	and Players[g_DoScarletCombat.attPlayerID] ~= nil and Players[g_DoScarletCombat.attPlayerID]:GetUnitByID(g_DoScarletCombat.attUnitID) ~= nil
	and Players[g_DoScarletCombat.defPlayerID] ~= nil and Players[g_DoScarletCombat.defPlayerID]:GetUnitByID(g_DoScarletCombat.defUnitID) ~= nil
	then
		local attPlayer = Players[g_DoScarletCombat.attPlayerID];
		local attUnit   = attPlayer:GetUnitByID(g_DoScarletCombat.attUnitID);
		local defPlayer = Players[g_DoScarletCombat.defPlayerID];
		local defUnit   = defPlayer:GetUnitByID(g_DoScarletCombat.defUnitID);
	
		if attUnit:GetCaptureChance(defUnit) > 0 then
			local unitClassType = defUnit:GetUnitClassType();
			local unitPlot = defUnit:GetPlot();
			local unitOriginalOwner = defUnit:GetOriginalOwner();
		
			local sCaptUnitName = nil;
			if defUnit:HasName() then
				sCaptUnitName = defUnit:GetNameNoDesc();
			end
			
			local unitLevel = defUnit:GetLevel();
			local unitEXP   = attUnit:GetExperience();
			local attMoves = attUnit:GetMoves();
			print("attacking Unit remains moves:"..attMoves);
		end
	end
end
GameEvents.BattleJoined.Add(ScarletCombatJoined);
function ScarletCombatEffect()
 	 --Defines and status checks
	if g_DoScarletCombat == nil or Players[ g_DoScarletCombat.defPlayerID ] == nil
	or Players[ g_DoScarletCombat.attPlayerID ] == nil or not Players[ g_DoScarletCombat.attPlayerID ]:IsAlive()
	or Players[ g_DoScarletCombat.attPlayerID ]:GetUnitByID(g_DoScarletCombat.attUnitID) == nil
	-- or Players[ g_DoScarletCombat.attPlayerID ]:GetUnitByID(g_DoScarletCombat.attUnitID):IsDead()
	or Map.GetPlot(g_DoScarletCombat.PlotX, g_DoScarletCombat.PlotY) == nil
	then
		return;
	end
	
	local attPlayerID = g_DoScarletCombat.attPlayerID;
	local attPlayer = Players[ attPlayerID ];
	local defPlayerID = g_DoScarletCombat.defPlayerID;
	local defPlayer = Players[ defPlayerID ];
	
	local attUnit = attPlayer:GetUnitByID(g_DoScarletCombat.attUnitID);
	local attPlot = attUnit:GetPlot();
	
	local plotX = g_DoScarletCombat.PlotX;
	local plotY = g_DoScarletCombat.PlotY;
	local batPlot = Map.GetPlot(plotX, plotY);
	local batType = g_DoScarletCombat.battleType;
	
	local bIsCity = g_DoScarletCombat.bIsCity;
	local defUnit = nil;
	local defPlot = nil;
	local defCity = nil;
	
	local attFinalUnitDamage = attUnit:GetDamage();
	local defFinalUnitDamage = 0;
	local attUnitDamage = attFinalUnitDamage - g_DoScarletCombat.attODamage;
	local defUnitDamage = 0;
	
	if not bIsCity and defPlayer:GetUnitByID(g_DoScarletCombat.defUnitID) then
		defUnit = defPlayer:GetUnitByID(g_DoScarletCombat.defUnitID);
		defPlot = defUnit:GetPlot();
		defFinalUnitDamage = defUnit:GetDamage();
		defUnitDamage = defFinalUnitDamage - g_DoScarletCombat.defODamage;
	elseif bIsCity and defPlayer:GetCityByID(g_DoScarletCombat.defCityID) then
		defCity = defPlayer:GetCityByID(g_DoScarletCombat.defCityID);
	end
	
	g_DoScarletCombat = nil;
		--Complex Effects Only for Human VS AI(reduce time and enhance stability)
	if not attPlayer:IsHuman() and not defPlayer:IsHuman() then
		return;
	end
	-- Not for Barbarins
	if attPlayer:IsBarbarian() then
		return;
	end

	-- 猩红骑团
	local ScarletBDWID = GameInfo.UnitPromotions["PROMOTION_Blood_dragon_warrior"].ID
	-- 惶怖荡武
    local RedDeathKnightID = GameInfo.UnitPromotions["PROMOTION_RED_DEATH_KNIGHTS"].ID
	local RedDeathKnightEffectID = GameInfo.UnitPromotions["PROMOTION_RED_DEATH_KNIGHTS_EFFECT"].ID
	-- 寂庭血宴
	local ScarletRageID = GameInfo.UnitPromotions["PROMOTION_SCARLET_RAGE"].ID
	-- 狂霄逆浪
	local ScarletVBGID = GameInfo.UnitPromotions["PROMOTION_VENGEFUL_BLOOD_GOD"].ID
	-- 狂澜障岳
	local ScarletCollDamageID = GameInfo.UnitPromotions["PROMOTION_SCARLET_COLLATERAL_DAMAGE"].ID
	-- 血堡战旗
	local ScarletBloodFlagID = GameInfo.UnitPromotions["PROMOTION_Flag_of_Blood_Keep"].ID

	---------------------猩红骑团：攻击造成自身战斗力÷5的额外伤害，并恢复等量生命
	if not bIsCity then
		if not attUnit:IsDead() and batType == GameInfoTypes["BATTLETYPE_MELEE"]
		and attUnit:IsHasPromotion(ScarletBDWID) and not defUnit:IsDead() 
		then
			local extraDamage = math.ceil(attUnit:GetBaseCombatStrength() / 5)
			defUnit:ChangeDamage(extraDamage, attPlayerID)
			attUnit:ChangeDamage(-extraDamage)
			print("Ah, power of blood dragon warrior!")
		end
	end

	---------------------寂庭血宴：攻击后根据造成的伤害恢复生命，最高不超过15
	if not bIsCity then
		if attUnit:IsHasPromotion(ScarletRageID) then
			local attheal = math.min(15, defUnitDamage)
			attUnit:ChangeDamage(-attheal)
			print("SuckBloodAndHeal:"..attheal)
		end
	end

	---------------------惶怖荡武: 对主目标赋予晋升使其当前回合无法攻击并减少50%移动力
	if not bIsCity then
		if  not defUnit:IsDead() and attUnit:IsHasPromotion(RedDeathKnightID) then
			defUnit:SetHasPromotion(RedDeathKnightEffectID, true)
			local defMoves = defUnit:GetMoves()
			--print ("defUnit:GetMoves()"..defMoves)	
			if defMoves > 0 then
				defUnit:SetMoves(defUnit:GetMoves() / 2) 
			end
		end
	end

	---------------------惶怖荡武: 赤殇骑团近战AOE, 对溅射目标赋予晋升使其当前回合无法攻击并减少50%移动力
	if (attUnit:IsHasPromotion(RedDeathKnightID)) then
		-- 溅射目标
		for i = 0, 5 do
			local adjPlot = Map.PlotDirection(plotX, plotY, i)
			if (adjPlot ~= nil and not adjPlot:IsCity()) then
				print("Available for AOE Damage!")
	
				local pUnit = adjPlot:GetUnit(0)
				if pUnit and (pUnit:GetDomainType() == DomainTypes.DOMAIN_LAND or pUnit:GetDomainType() == DomainTypes.DOMAIN_SEA) then
					local pCombat = pUnit:GetBaseCombatStrength()
					local pPlayer = Players[pUnit:GetOwner()]
					
					if PlayersAtWar(attPlayer, pPlayer) then
						local SplashDamageOri = defUnitDamage
	
						local AOEmod = 0.5
							
						local text = nil;
						local attUnitName = attUnit:GetName();
						local defUnitName = pUnit:GetName();
							
						local SplashDamageFinal = math.floor(SplashDamageOri * AOEmod); -- Set the Final Damage
						if     SplashDamageFinal >= pUnit:GetCurrHitPoints() then
							SplashDamageFinal = pUnit:GetCurrHitPoints();
							local eUnitType = pUnit:GetUnitType();
								
							if     defPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_DEATH", attUnitName, defUnitName);
							elseif attPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
							end
						elseif SplashDamageFinal > 0 then
							if     defPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE", attUnitName, defUnitName, SplashDamageFinal);
							elseif attPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY", attUnitName, defUnitName, SplashDamageFinal);
							end
						end
						if text then
							Events.GameplayAlertMessage( text );
						end
						pUnit:ChangeDamage(SplashDamageFinal, attPlayer)
						if not pUnit:IsDead() then
							pUnit:SetHasPromotion(RedDeathKnightEffectID, true)
							local defMoves = pUnit:GetMoves()	
							if defMoves > 0 then
								pUnit:SetMoves(pUnit:GetMoves() / 2) 
							end
						end
						print("Splash Damage="..SplashDamageFinal)
					end
				end
			end
		end
	end

	---------------------狂霄逆浪:遭受远程攻击时若攻击目标不超过自身最大射程2以上，予以远程反击
	if not bIsCity then
		if not defUnit:IsDead() and defUnit:IsHasPromotion(ScarletVBGID) 
		and batType == GameInfoTypes["BATTLETYPE_RANGED"]
		and Map.PlotDistance(defUnit:GetX(), defUnit:GetY(), attUnit:GetX(), attUnit:GetY()) <= defUnit:Range() + 2
		then
			defUnit:RangeStrike(attUnit:GetX(), attUnit:GetY())
			defUnit:SetMadeAttack (false)
			print ("I see you!")
		end
	end

	---------------------万古长战：每次战斗可永久提升3基础战斗力
	if attUnit and not attUnit:IsDead() and attUnit:IsHasPromotion(ScarletEWID) then
		attUnit:SetBaseCombatStrength(attUnit:GetBaseCombatStrength() + 3)
		print ("Attack:+3!!")
	elseif not bIsCity then
		if not defUnit:IsDead() and defUnit:IsHasPromotion(ScarletEWID) then
			defUnit:SetBaseCombatStrength(defUnit:GetBaseCombatStrength() + 3)
			print ("Defense:+3!!")
		end
	end

	---------------------万古长战：杀敌后传送冷却立刻结束
	if defUnit and attUnit:IsHasPromotion(ScarletEWID) then
		print ("DefUnit Damage:"..defFinalUnitDamage);
		if defFinalUnitDamage >= 100 then
			save( attPlayer, "ScarletTransport", -1)
			print ("Ah, tansport!");
		end
	end

	---------------------真红狂月：杀敌为最近城市提供产能
	if not bIsCity and not attUnit:IsDead() and defUnit:IsDead() and
	attPlayer:GetCivilizationType() == GameInfoTypes["CIVILIZATION_SCARLET"] then
		local icCity = GetCloseCity(attPlayerID, defPlot) 
		local idefCombat = GameInfo.Units[defUnit:GetUnitType()].Combat * 2
		local iText = Locale.ConvertTextKey("TXT_KEY_SCARLET_COMBAT_PRODUCTION", attUnit:GetName(), defUnit:GetName(), icCity:GetName(), idefCombat)
		if icCity ~= nil then
			icCity:SetOverflowProduction(icCity:GetOverflowProduction() + idefCombat)
			if attPlayer:IsHuman() then
				defUnit:AddMessage(iText, attPlayerID)
				local hex = ToHexFromGrid(Vector2(plotX, plotY))
				Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("[COLOR_CITY_BROWN]+{1_Num}[ENDCOLOR][ICON_PRODUCTION]", idefCombat))
				Events.GameplayFX(hex.x, hex.y, -1)
			end
		end
	end
	
	---------------------狂澜障岳：遭受游猎和潜艇攻击时减伤
	if not bIsCity then
		if not defUnit:IsDead() and defUnit:IsHasPromotion(ScarletVBGID) and attUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_NAVAL_HIT_AND_RUN"].ID) then
			defUnit:ChangeDamage(-0.5 * defUnitDamage)
		end
		if not defUnit:IsDead() and defUnit:IsHasPromotion(ScarletVBGID) and attUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_SUBMARINE_COMBAT"].ID) then
			defUnit:ChangeDamage(-0.5 * defUnitDamage)
		end
	end
	
	---------------------血堡战旗：遭受远程攻击时减伤
	if not bIsCity then
		if not defUnit:IsDead() and defUnit:IsHasPromotion(ScarletBloodFlagID) and batType == GameInfoTypes["BATTLETYPE_RANGED"] then
			defUnit:ChangeDamage(-0.25 * defUnitDamage)
		end
	end

end
GameEvents.BattleFinished.Add(ScarletCombatEffect)

----------------------------------------------------------------------------------------------------------------------------
-- 血盟古堡：城市防御、城市生命加成以及健康加成
----------------------------------------------------------------------------------------------------------------------------
function GetNumberWorkedClanCastles(playerID, city)
	local numWorkedClanCastles = 0
	for cityPlot = 0, city:GetNumCityPlots() - 1, 1 do
		local plot = city:GetCityIndexPlot(cityPlot)
		if plot then
			if plot:GetOwner() == playerID then
				if city:IsWorkingPlot(plot) then	
					if plot:GetImprovementType() == GameInfoTypes["IMPROVEMENT_SCARLET_CASTLE"] then 
						numWorkedClanCastles = numWorkedClanCastles + 1
					end
				end
			end
		end
	end
	
	return numWorkedClanCastles
end
	
function ClanCastleExperience(playerID)
	local player = Players[playerID]
	if player:IsAlive() then
		for city in player:Cities() do
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_SCARLET_CASTLE_MANPOWER"], GetNumberWorkedClanCastles(playerID, city))
		end
	end
end
--GameEvents.PlayerDoTurn.Add(ClanCastleExperience)
----------------------------------------------------------------------------------------------------------------------------
-- 血盟古堡：建造完成生成重步兵
----------------------------------------------------------------------------------------------------------------------------
local ScarletCivilizationID  = GameInfoTypes.CIVILIZATION_SCARLET
function OnClanCastleCreated(iPlayer, iUnit, iX, iY, iBuild)
	if iBuild == nil then return end
	local pPlayer = Players[iPlayer]
	if pPlayer:GetCivilizationType() ~= ScarletCivilizationID then return end

	if iBuild == GameInfoTypes.BUILD_SCARLET_CASTLE then
		local pUnit = pPlayer:InitUnit(pPlayer:GetCivUnitNowTech(GameInfoTypes.UNITCLASS_SWORDSMAN), iX, iY)
		pUnit:ChangeExperience(15)
	end
end
GameEvents.PlayerBuilt.Add(OnClanCastleCreated)
----------------------------------------------------------------------------------------------------------------------------
-- 红魔觉醒：每回合赋予单位经验值（已注释废弃）
----------------------------------------------------------------------------------------------------------------------------
function ScarletMist(iPlayer)
	local pPlayer = Players[iPlayer]
	if pPlayer:GetCivilizationType() == GameInfo.Civilizations["CIVILIZATION_SCARLET"].ID then
		for unit in pPlayer:Units() do
			if unit:CanAcquirePromotionAny() then
				local pPlot = unit:GetPlot()
				if pPlot:GetOwner() > -1 then
					local pPlotOwner = Players[pPlot:GetOwner()]
					if pPlotOwner == pPlayer and unit:IsCombatUnit() then
						unit:ChangeExperience(2)
					end
				end
			end
		end
	end
end
--GameEvents.PlayerDoTurn.Add(ScarletMist)
----------------------------------------------------------------------------------------------------------------------------
-- 绯赤魔导议会：黄金时代伟人诞生加成
----------------------------------------------------------------------------------------------------------------------------
function ScarletPolicies(playerID)
	local player = Players[playerID]
	
	if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
		return
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_RED_MAGICIAN"]) > 0 
	and player:GetGoldenAgeTurns() > 0
	then 
		player:SetHasPolicy(GameInfoTypes["POLICY_RED_MAGICIAN"], true, true)
	else
		player:SetHasPolicy(GameInfoTypes["POLICY_RED_MAGICIAN"], false)
	end
	
end
GameEvents.PlayerDoTurn.Add(ScarletPolicies)
----------------------------------------------------------------------------------------------------------------------------
-- 绯赤魔导议会：诞生大科/大工/大文任意一种伟人时，给其他两种未诞生的伟人+50点数
----------------------------------------------------------------------------------------------------------------------------
function WonderAccelerateGreatPeople(playerID, unitID)
	local player = Players[playerID]
    if player:GetUnitByID(unitID) == nil then return end
    local unit = player:GetUnitByID(unitID)
	
	if player:CountNumBuildings(GameInfoTypes.BUILDING_RED_MAGICIAN) > 0 then
		local iGreatPeople = GameInfo.GameSpeeds[Game.GetGameSpeedType()].GreatPeoplePercent / 100
		local iUnitClassType = {GameInfoTypes.UNITCLASS_WRITER, GameInfoTypes.UNITCLASS_SCIENTIST, GameInfoTypes.UNITCLASS_ENGINEER}
		local iSpecialists = {GameInfo.Specialists.SPECIALIST_WRITER.ID, GameInfo.Specialists.SPECIALIST_SCIENTIST.ID, GameInfo.Specialists.SPECIALIST_ENGINEER.ID}
		local is1, is2 = nil, nil
		print("iGreatPeople:"..iGreatPeople)
		for i = 1, 3 do
			if unit:GetUnitClassType() == iUnitClassType[i] then
				if i == 1 then
					is1, is2 = iSpecialists[2], iSpecialists[3]
				elseif i == 2 then
					is1, is2 = iSpecialists[1], iSpecialists[3]
				elseif i == 3 then
					is1, is2 = iSpecialists[1], iSpecialists[2]
				end	
				for city in player:Cities() do
					if city:IsHasBuilding(GameInfoTypes.BUILDING_RED_MAGICIAN) then
						print("is1:"..city:GetSpecialistGreatPersonProgress(is1))
						print("is2:"..city:GetSpecialistGreatPersonProgress(is2))
						city:ChangeSpecialistGreatPersonProgressTimes100(is1, math.ceil(5000 * iGreatPeople))
						city:ChangeSpecialistGreatPersonProgressTimes100(is2, math.ceil(5000 * iGreatPeople))
					end
				end
			end
		end
	end
end
Events.SerialEventUnitCreated.Add(WonderAccelerateGreatPeople)
----------------------------------------------------------------------------------------------------------------------------
-- 红色不夜城：进入新时代开启黄金时代
----------------------------------------------------------------------------------------------------------------------------
local RncGameSpeed = ((GameInfo.GameSpeeds[Game.GetGameSpeedType()].BuildPercent)/100)
local RNC = GameInfoTypes["BUILDING_Red_Night_Castle"]
local ScarletPalace = GameInfoTypes["BUILDING_SCARLET_PALACE"]

function RNCGoldenAge(nEra, PlayerID)
	local pPlayer = Players[PlayerID]
	if pPlayer:IsAlive() then
		for pCity in pPlayer:Cities() do
			if pCity:IsHasBuilding(RNC) and pPlayer:CountNumBuildings(ScarletPalace) <= 0 then
				pPlayer:ChangeGoldenAgeTurns( 10 * RncGameSpeed + 1 )
			elseif pCity:IsHasBuilding(RNC) and pPlayer:CountNumBuildings(ScarletPalace) > 0 then
				pPlayer:ChangeGoldenAgeTurns( 20 * RncGameSpeed + 1 )
			end
		end
	end
end
Events.SerialEventEraChanged.Add(RNCGoldenAge)
--ChangeWeLoveTheKingDayCounter敬王日
----------------------------------------------------------------------------------------------------------------------------
-- 红色不夜城：传统政策额外加成
----------------------------------------------------------------------------------------------------------------------------
function ScarletOpenTree(playerID, policyID)
	local pPlayer = Players[playerID]
	if pPlayer == nil or pPlayer:IsBarbarian() or pPlayer:IsMinorCiv() or pPlayer:GetNumCities() <= 0 then
		return
	end
	
	local pTradition = GameInfoTypes.POLICY_TRADITION --传统开门

	if pPlayer:HasPolicy(pTradition) and pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_Red_Night_Castle"]) > 0 then
		pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_RED_NIGHT_CASTLE"].ID, true, true)	
	else
		pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_RED_NIGHT_CASTLE"].ID, false)
	end

end
GameEvents.PlayerDoTurn.Add(ScarletOpenTree)
----------------------------------------------------------------------------------------------------------------------------
-- 猩红血骑：战斗力随科技提升
----------------------------------------------------------------------------------------------------------------------------
local BloodKnihtID = GameInfoTypes["UNIT_BLOOD_KNIGHTS"]
local Metallurgy = GameInfoTypes["TECH_METALLURGY"]	
function BloodKnihtCombatStrength(iTeam, iTech, bAdopted)
	for iPlayer=0, GameDefines.MAX_MAJOR_CIVS-1 do
		local pPlayer = Players[iPlayer]
		local bTeam = (pPlayer:GetTeam() == iTeam)
		if bTeam and (pPlayer:GetCivilizationType() ~= BARBARIAN ) and bAdopted then
			local pTeam = Teams[iTeam]
			for pUnit in pPlayer:Units() do
				if pUnit:GetUnitType() == BloodKnihtID  then
					if iTech == Metallurgy then
						pUnit:SetBaseCombatStrength(55)
						pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_BLOOD_KNIGHTS_RETROFIT"].ID, true)
					end
				end
			end
		end
	end
end
GameEvents.TeamSetHasTech.Add(BloodKnihtCombatStrength)
function BloodKnihtCombatStrength2(playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	local pPlayer = Players[playerID]
	local pUnit = pPlayer:GetUnitByID(unitID)
	if pPlayer:IsAlive() and (pPlayer:GetCivilizationType() ~= BARBARIAN ) then
		local pTeam = Teams[pPlayer:GetTeam()]
		if pUnit:GetUnitType() == BloodKnihtID  then
			if pTeam:GetTeamTechs():HasTech(Metallurgy) then
				pUnit:SetBaseCombatStrength(55)
				pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_BLOOD_KNIGHTS_RETROFIT"].ID, true)
			end
		end
	end
end
Events.SerialEventUnitCreated.Add(BloodKnihtCombatStrength2)
----------------------------------------------------------------------------------------------------------------------------
-- 荣光血翼主力舰：战斗力随科技提升
----------------------------------------------------------------------------------------------------------------------------
local BloodWingID = GameInfoTypes["UNIT_BLOOD_WING_SHIP"]
local Industrialization = GameInfoTypes["TECH_INDUSTRIALIZATION"]	
function BloodWingCombatStrength(iTeam, iTech, bAdopted)
	for iPlayer=0, GameDefines.MAX_MAJOR_CIVS-1 do
		local pPlayer = Players[iPlayer]
		local bTeam = (pPlayer:GetTeam() == iTeam)
		if bTeam and (pPlayer:GetCivilizationType() ~= BARBARIAN ) and bAdopted then
			local pTeam = Teams[iTeam]
			for pUnit in pPlayer:Units() do
				if pUnit:GetUnitType() == BloodWingID  then
					if iTech == Industrialization then
						pUnit:SetBaseCombatStrength(280)
						pUnit:SetBaseRangedCombatStrength(280)
						pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_BLOOD_WING_RETROFIT"].ID, true)
					end
				end
			end
		end
	end
end
GameEvents.TeamSetHasTech.Add(BloodWingCombatStrength)
function BloodWingCombatStrength2(playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	local pPlayer = Players[playerID]
	local pUnit = pPlayer:GetUnitByID(unitID)
	if pPlayer:IsAlive() and (pPlayer:GetCivilizationType() ~= BARBARIAN ) then
		local pTeam = Teams[pPlayer:GetTeam()]
		if pUnit:GetUnitType() == BloodWingID  then
			if pTeam:GetTeamTechs():HasTech(Industrialization) then
				pUnit:SetBaseCombatStrength(280)
				pUnit:SetBaseRangedCombatStrength(280)
				pUnit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_BLOOD_WING_RETROFIT"].ID, true)
			end
		end
	end
end
Events.SerialEventUnitCreated.Add(BloodWingCombatStrength2)
------------------------------------------------------------------------------------------------------------------------------
-- 泣血捶膺：回合开始移动力减半且丧失攻击能力
----------------------------------------------------------------------------------------------------------------------------
function RedDeathKnightEffect1(playerID)
	local player = Players[playerID]

	if player == nil then
		return
	end
	
	local RedDeathKnightEffectID = GameInfo.UnitPromotions["PROMOTION_RED_DEATH_KNIGHTS_EFFECT"].ID

	for unit in player:Units() do
		if unit:IsHasPromotion(RedDeathKnightEffectID) then
			-- unit:SetHasPromotion(RedDeathKnightEffectID, false)
			local defMoves = unit:GetMoves()
			print ("unit:GetMoves()"..defMoves)	
			if defMoves > 0 then
				unit:SetMoves(unit:GetMoves() / 2) 
			end

		end
	end

end
GameEvents.PlayerDoTurn.Add(RedDeathKnightEffect1)
------------------------------------------------------------------------------------------------------------------------------
-- 泣血捶膺：回合结束消除效果
----------------------------------------------------------------------------------------------------------------------------
function RedDeathKnightEffect2(playerID)
	local player = Players[playerID]

	if player == nil then
		return
	end
	
	local RedDeathKnightEffectID = GameInfo.UnitPromotions["PROMOTION_RED_DEATH_KNIGHTS_EFFECT"].ID

	for unit in player:Units() do
		if unit:IsHasPromotion(RedDeathKnightEffectID) then
			unit:SetHasPromotion(RedDeathKnightEffectID, false)
		end
	end

end
GameEvents.PlayerDoneTurn.Add(RedDeathKnightEffect2)
----------------------------------------------------------------------------------------------------------------------------
-- 次元之爪：传送突袭
----------------------------------------------------------------------------------------------------------------------------
local ScarletTransportButton = {
	Name = "REMILIA SUPER TRANSPORT",
	Title = "TXT_KEY_TITLE_REMILIA_SUPER_TRANSPORT",
	OrderPriority = 200,
	IconAtlas = "SCARLETSKILL_ATLAS",
	PortraitIndex = 30,
	ToolTip = function(action, unit)
		local sTooltip;
		local pPlayer = Players[Game:GetActivePlayer()];
		sTooltip = Locale.ConvertTextKey( "TXT_KEY_COND_REMILIA_SUPER_TRANSPORT");
		return sTooltip
	end, -- or a TXT_KEY_ or a function
	Condition = function(action, unit)
		if unit:GetMoves() <= 0 then
			return false
		end
		local pPlayer = Players[Game:GetActivePlayer()];
		local iScarletEW = load( pPlayer, "ScarletTransport", iScarletEW ) or -1;
		if unit:CanMove() and unit:IsHasPromotion(ScarletEWID)
		and iScarletEW < 0
		then
			return true
		end
	end, -- or nil or a boolean, default is true
	Disabled = function(action, unit)
		local pPlayer = Players[Game:GetActivePlayer()];
		local iScarletEW = load( pPlayer, "ScarletTransport", iScarletEW ) or -1;
		return unit:CanMove() and unit:IsHasPromotion(ScarletEWID) and iScarletEW >= 0
	end, -- or nil or a boolean, default is false
	Action = function(action, unit, eClick)
	if eClick == Mouse.eRClick then
		return
	end
	local pPlayer = Players[Game:GetActivePlayer()];
	local iScarletEW = load( pPlayer, "ScarletTransport", iScarletEW ) or -1;
	if pPlayer:IsHuman() and iScarletEW < 0 then
		-- 四格范围传送地块高亮
		local uniqueRange = 4
		for dx = -uniqueRange, uniqueRange, 1 do
			for dy = -uniqueRange, uniqueRange, 1 do
				local iPlot = Map.PlotXYWithRangeCheck(unit:GetX(), unit:GetY(), dx, dy, uniqueRange);
				if (iPlot ~= nil) and iScarletEW < 0 
				and  iPlot:GetNumUnits() == 0 
				and (not iPlot:IsMountain())
				and (not iPlot:IsWater()) 
				and (not iPlot:IsCity())
				then
					Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(iPlot:GetX(), iPlot:GetY())), true, Vector4(0.55, 0.15, 0.0, 1.0))
				end
			end
		end
	end
	ScarletTransport = 1
end
}
LuaEvents.UnitPanelActionAddin(ScarletTransportButton)

function ScarletInputHandler( uiMsg, wParam, lParam )
	
	if ScarletTransport == 1 then
		if uiMsg == MouseEvents.LButtonDown then
			lButtonDown = true
			local uniqueRange = 4
			local pPlot = Map.GetPlot(UI.GetMouseOverHex())
			local pPlayer = Players[Game:GetActivePlayer()]
			local num = 0
			local pSelUnit = UI.GetHeadSelectedUnit()
			local selUnitPlot = pSelUnit:GetPlot()
			local distance = Map.PlotDistance(selUnitPlot:GetX(), selUnitPlot:GetY(), pPlot:GetX(), pPlot:GetY())
			
			local iScarletEW = load( pPlayer, "ScarletTransport", iScarletEW ) or -1;
			if distance <= uniqueRange and distance > 0 and pSelUnit:GetMoves() ~= 0 
			and  pSelUnit:IsHasPromotion(ScarletEWID) 
			and  pPlot:GetNumUnits() == 0 
			and (not pPlot:IsMountain())
			and (not pPlot:IsWater()) 
			and (not pPlot:IsCity())
			and  iScarletEW < 0
			then
				pSelUnit:SetXY(pPlot:GetX(), pPlot:GetY());
				-- Events.AudioPlay2DSound("AS2D_SPACE_TRANSPORT") 
				local hex = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()))		
				Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("TXT_KEY_ALERT_REMILIA_SUPER_TRANSPORT", pSelUnit:GetName()))
				Events.GameplayFX(hex.x, hex.y, -1)
				iScarletEW =  iScarletEW + 1
				save( pPlayer, "ScarletTransport", iScarletEW )
			end
			-- end
			Events.ClearHexHighlights()
			ScarletTransport = 0
		elseif uiMsg == MouseEvents.LButtonUp then
			if lButtonDown then
				lButtonDown = false
			end
		elseif uiMsg == MouseEvents.RButtonDown then
			rButtonDown = true
		elseif uiMsg == MouseEvents.RButtonUp then
			if rButtonDown and ScarletTransport == 1 then
				rButtonDown = false
				ScarletTransport = 0
				Events.ClearHexHighlights()
			end
		end
	end
	return false;
end
ContextPtr:SetInputHandler( ScarletInputHandler )

-- 次元之爪：冷却时间3回合
GameEvents.PlayerDoTurn.Add(
function(playerID)
	local player = Players[playerID] 

	if player == nil or player:IsBarbarian() then
		return
	end

	for unit in player:Units() do
		if unit:IsHasPromotion(ScarletEWID) then
			local iScarletEW = load( player, "ScarletTransport", iScarletEW) or -1;
			if iScarletEW < 2 and iScarletEW >= 0 then
				iScarletEW = iScarletEW + 1
				save( player, "ScarletTransport", iScarletEW)
			elseif iScarletEW == 2 then
				iScarletEW = -1
				save( player, "ScarletTransport", iScarletEW)
			end
		end
	end

end)
----------------------------------------------------------------------------------------------------------------------------
-- 绯月圣典：当场上存在殷绯帝国时其他文明不可选取此工程
----------------------------------------------------------------------------------------------------------------------------
function IsCivilisationActive(CivilizationID)
  for iSlot = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		local slotStatus = PreGame.GetSlotStatus(iSlot)
		if (slotStatus == SlotStatus.SS_TAKEN or slotStatus == SlotStatus.SS_COMPUTER) then
			if PreGame.GetCivilization(iSlot) == CivilizationID then
				return true
			end
		end
	end

	return false
end

local CivilizationID  = GameInfoTypes.CIVILIZATION_SCARLET
local bIsCivActive	 = IsCivilisationActive(CivilizationID)

function CityCanCreateOnly(playerID, cityID, projectTypeID)
	local player = Players[playerID]
	if (projectTypeID == GameInfo.Projects{Type="PROJECT_REDMOON_INDEX"}().ID) then
		return player:GetCivilizationType() == CivilizationID 
	end	
	return true
end
if bIsCivActive then
GameEvents.CityCanCreate.Add(CityCanCreateOnly)
end
----------------------------------------------------------------------------------------------------------------------------
-- 单位命名：升级时保留旧名级
----------------------------------------------------------------------------------------------------------------------------
function SetScarletUnitsName( iPlayer, iOldUnit,  iNewUnit)
	if Players[ iPlayer ] == nil or not Players[ iPlayer ]:IsAlive()
	or Players[ iPlayer ]:GetUnitByID( iOldUnit ) == nil
	or Players[ iPlayer ]:GetUnitByID( iOldUnit ):IsDead()
	or Players[ iPlayer ]:GetUnitByID( iOldUnit ):IsDelayedDeath()
	or Players[ iPlayer ]:GetUnitByID( iOldUnit ):HasName() 
	then
		return;
	end
	local pUnit = Players[ iPlayer ]:GetUnitByID( iOldUnit );
	if  pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_RED_DEATH_KNIGHTS"].ID) then
		pUnit:SetName("TXT_KEY_UNIT_RED_DEATH_KNIGHT"); -- 赤殇血骑
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_ETERNAL_WARDRAKE"].ID) then
		pUnit:SetName("TXT_KEY_UNIT_CRIMSONDRAKE");	-- 赤龙圣团
	end
end
GameEvents.UnitUpgraded.Add(SetScarletUnitsName)
----------------------------------------------------------------------------------------------------------------------------
-- 血龙礼拜堂：拥有鲜血要塞则陆军获得双倍初始经验值
----------------------------------------------------------------------------------------------------------------------------
local DomainLandID = GameInfoTypes["DOMAIN_LAND"]
local function BloodDraonKeepCityTrained(playerID, cityID, unitID)
	local player = Players[playerID]
	if (not player:IsAlive()) then return end
	local city = player:GetCityByID(cityID)
	local unit = player:GetUnitByID(unitID)
	if player:CountNumBuildings(GameInfoTypes["BUILDING_BLOOD_DRAGON_KEEP"]) < 1 then return end
	if (not city:IsHasBuilding(GameInfoTypes["BUILDING_Blood_Fortress"])) then return end
	if (not unit:IsCombatUnit()) then return end

	if unit:GetDomainType() ~= DomainLandID then return end
	local numXP = city:GetDomainFreeExperience(DomainLandID)
	unit:ChangeExperience(numXP)
end 
GameEvents.CityTrained.Add(BloodDraonKeepCityTrained)
----------------------------------------------------------------------------------------------------------------------------
-- 歃血要塞：范围内的作战单位为城市加产能累积
----------------------------------------------------------------------------------------------------------------------------
local BloodFortressID = GameInfoTypes["BUILDING_Blood_Fortress"]
local ProductionGameSpeed = ((GameInfo.GameSpeeds[Game.GetGameSpeedType()].BuildPercent)/100)
function BloodFortressDoneTurn(playerID)
	local player = Players[playerID];
	if player == nil then return end;
	if (not player:IsAlive()) then return end;
	if player:IsBarbarian() or player:IsMinorCiv() then return end;
	
	if player:CountNumBuildings(BloodFortressID) > 0 then
		for city in player:Cities() do
			if city:IsHasBuilding(BloodFortressID) then
				local cityPlot = city:Plot();
				for plot in PlotAreaSpiralIterator(cityPlot, 3, SECTOR_NORTH, DIRECTION_CLOCKWISE) do
					if plot and plot:GetNumUnits() > 0 then
						local NowEra = player:GetCurrentEra()
						local num_plot_units = 0
						for i = 0, plot:GetNumUnits() - 1, 1 do
							local fUnit = plot:GetUnit(i)
							if fUnit:IsCombatUnit() then
								num_plot_units = num_plot_units + 1
							end
						end
						if num_plot_units > 0 then
							local unitProduction = math.ceil(num_plot_units * 1 * (NowEra + 1 ) * ProductionGameSpeed)
							city:SetOverflowProduction(city:GetOverflowProduction() + unitProduction);
							local hex = ToHexFromGrid(Vector2(plot:GetX(), plot:GetY()));
							Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("[COLOR_CITY_BROWN]+{1_Num}[ENDCOLOR][ICON_PRODUCTION]", unitProduction ));
							Events.GameplayFX(hex.x, hex.y, -1);
						end
					end
				end
			end
		end
	end
end
GameEvents.PlayerDoneTurn.Add(BloodFortressDoneTurn);
----------------------------------------------------------------------------------------------------------------------------
-- 禁忌秘文库：根据研发科技数量给科研
----------------------------------------------------------------------------------------------------------------------------
function ArcaneTabooLibraryBonus(iPlayer)
	local pPlayer = Players[iPlayer];
	local iTeam = pPlayer:GetTeam()
	local pTeam = Teams[iTeam];
	local pTechs = pTeam:GetTeamTechs()
	local iTechs = pTechs:GetNumTechsKnown()
	
	if pPlayer == nil or pPlayer:IsBarbarian() or pPlayer:IsMinorCiv() or pPlayer:GetNumCities() <= 0 then
		return
	end
	
	for pCity in pPlayer:Cities() do
		if pCity:IsHasBuilding(GameInfoTypes.BUILDING_ARCANE_TABOO_LIBRARY) then
			pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TABOO_LIBRARY_BOUNS"], math.floor(iTechs/2))
		end
	break
	end
end
GameEvents.PlayerDoTurn.Add(ArcaneTabooLibraryBonus)
----------------------------------------------------------------------------------------------------------------------------
-- 禁忌秘文库：根据政策树提供伟人诞生速率
----------------------------------------------------------------------------------------------------------------------------
function ArcaneTabooLibraryAdoptPolicy(playerID)
	local player = Players[playerID]
	local numUnlockedBranches = player:GetNumPolicyBranchesUnlocked()
	
	if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
		return
	end
	
	for city in player:Cities() do
		if city:IsHasBuilding(GameInfoTypes.BUILDING_ARCANE_TABOO_LIBRARY) then
			city:SetNumRealBuilding(GameInfoTypes["BUILDING_TABOO_LIBRARY_POLICY"], numUnlockedBranches)
		end
	break
	end
end
GameEvents.PlayerAdoptPolicyBranch.Add(ArcaneTabooLibraryAdoptPolicy)
GameEvents.PlayerDoTurn.Add(ArcaneTabooLibraryAdoptPolicy)
----------------------------------------------------------------------------------------------------------------------------
-- 禁忌秘文库：建成后开启意识形态
----------------------------------------------------------------------------------------------------------------------------
function ArcaneTabooLibraryAddNotification(iPlayer, iCity, iBuilding, bGold, bFaithOrCulture)
	local pPlayer = Players[iPlayer];
	local pCity = pPlayer:GetCityByID(iCity)

	if pPlayer == nil or pPlayer:IsBarbarian() or pPlayer:IsMinorCiv() or pPlayer:GetNumCities() <= 0 then
		return
	end
	
	if iBuilding == GameInfoTypes["BUILDING_ARCANE_TABOO_LIBRARY"] then
	local heading = Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_SUMMARY_CHOOSE_IDEOLOGY");
	local text = Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_SUMMARY_CHOOSE_IDEOLOGY_ATL");
		pPlayer:AddNotification(NotificationTypes.NOTIFICATION_CHOOSE_IDEOLOGY, text, heading, -1, -1);
	end

end
GameEvents.CityConstructed.Add(ArcaneTabooLibraryAddNotification)
----------------------------------------------------------------------------------------------------------------------------
-- 殷月红魔殿：市政厅减少阈值惩罚傀儡城提供人力
----------------------------------------------------------------------------------------------------------------------------
function ScarletPalaceBonus(playerID)
	local player = Players[playerID]
	
	if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
		return
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_SCARLET_PALACE"]) > 0 then
		for city in player:Cities() do
			if city:IsHasBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV1"]) 
			or city:IsHasBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV2"])
			or city:IsHasBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV3"])
			or city:IsHasBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV4"])
			or city:IsHasBuilding(GameInfoTypes["BUILDING_CITY_HALL_LV5"])
			then
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_SCARLET_PALACE_CULTURE"],1)
			else
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_SCARLET_PALACE_CULTURE"],0)
			end
			
			if city:IsHasBuilding(GameInfoTypes["BUILDING_PUPPET_GOVERNEMENT"]) then
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_SCARLET_PALACE_MANPOWER"],1)
			else
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_SCARLET_PALACE_MANPOWER"],0)
			end
		end
	end
	
end
GameEvents.PlayerDoTurn.Add(ScarletPalaceBonus)
----------------------------------------------------------------------------------------------------------------------------