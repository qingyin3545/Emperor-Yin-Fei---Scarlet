include( "UtilityFunctions.lua" );
include("FLuaVector.lua");
include("PlotIterators.lua")
-- SaveUtils
include("RemiliaSaveUtils.lua"); MY_MOD_NAME = "Scarlet";
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
	if pPlayer == nil or pPlayer:GetNumCities() <= 0 then return end
	
	local distance = 1000
	local closeCity = nil
	for pCity in pPlayer:Cities() do
		local distanceToCity = Map.PlotDistance(pCity:GetX(), pCity:GetY(), plot:GetX(), plot:GetY())
		if distanceToCity < distance then
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
-- 万古长战
local ScarletEWID = GameInfo.UnitPromotions["PROMOTION_ETERNAL_WARDRAKE"].ID
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
						if SplashDamageFinal >= pUnit:GetCurrHitPoints() then
							SplashDamageFinal = pUnit:GetCurrHitPoints();

							if defPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_DEATH", attUnitName, defUnitName);
							elseif attPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
							end
						elseif SplashDamageFinal > 0 then
							if defPlayerID == Game.GetActivePlayer() then
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
								pUnit:SetMoves(defMoves / 2) 
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
		attUnit:ChangeCombatStrengthChangeFromKilledUnits(3)
		print ("Attack:+3!!")
	end
	if defUnit and not defUnit:IsDead() and defUnit:IsHasPromotion(ScarletEWID) then
		defUnit:ChangeCombatStrengthChangeFromKilledUnits(3)
		print ("Defense:+3!!")
	end
	---------------------万古长战：杀敌后传送冷却立刻结束
	if defUnit and defUnit:IsDead() and attUnit:IsHasPromotion(ScarletEWID) then
		save( attPlayer, "ScarletTransport" .. attUnit:GetID(), -4)
		print ("Ah, tansport!", attUnit:GetID());
	end

	---------------------真红狂月：杀敌为最近城市提供产能
	if not bIsCity and not attUnit:IsDead() and defUnit:IsDead() and
	attPlayer:GetCivilizationType() == GameInfoTypes["CIVILIZATION_SCARLET"] then
		local icCity = GetCloseCity(attPlayerID, defPlot) 
		if icCity ~= nil then
			local idefCombat = GameInfo.Units[defUnit:GetUnitType()].Combat * 2
			icCity:SetOverflowProduction(icCity:GetOverflowProduction() + idefCombat)
			if attPlayer:IsHuman() then
				local iText = Locale.ConvertTextKey("TXT_KEY_SCARLET_COMBAT_PRODUCTION", attUnit:GetName(), defUnit:GetName(), icCity:GetName(), idefCombat)
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
local iGreatPeople = GameInfo.GameSpeeds[Game.GetGameSpeedType()].GreatPeoplePercent / 100
local iUnitClassType = {GameInfoTypes.UNITCLASS_WRITER, GameInfoTypes.UNITCLASS_SCIENTIST, GameInfoTypes.UNITCLASS_ENGINEER}
local iSpecialists = {GameInfo.Specialists.SPECIALIST_WRITER.ID, GameInfo.Specialists.SPECIALIST_SCIENTIST.ID, GameInfo.Specialists.SPECIALIST_ENGINEER.ID}
function WonderAccelerateGreatPeople(playerID, unitID)
	local player = Players[playerID]
	if player == nil then return end
	if player:CountNumBuildings(GameInfoTypes.BUILDING_RED_MAGICIAN) <= 0 then return end

	local unit = player:GetUnitByID(unitID)
    if unit == nil then return end

	for i = 1, 3 do
		if unit:GetUnitClassType() == iUnitClassType[i] then
			local is1, is2 = nil, nil
			if i == 1 then
				is1, is2 = iSpecialists[2], iSpecialists[3]
			elseif i == 2 then
				is1, is2 = iSpecialists[1], iSpecialists[3]
			elseif i == 3 then
				is1, is2 = iSpecialists[1], iSpecialists[2]
			end	
			for city in player:Cities() do
				if city:IsHasBuilding(GameInfoTypes.BUILDING_RED_MAGICIAN) then
					--print("is1:"..city:GetSpecialistGreatPersonProgress(is1))
					--print("is2:"..city:GetSpecialistGreatPersonProgress(is2))
					city:ChangeSpecialistGreatPersonProgressTimes100(is1, math.ceil(5000 * iGreatPeople))
					city:ChangeSpecialistGreatPersonProgressTimes100(is2, math.ceil(5000 * iGreatPeople))
					break
				end
			end
		end
	end
end
GameEvents.UnitCreated.Add(WonderAccelerateGreatPeople)
----------------------------------------------------------------------------------------------------------------------------
-- 红色不夜城：进入新时代开启黄金时代
----------------------------------------------------------------------------------------------------------------------------
local RncGameSpeed = ((GameInfo.GameSpeeds[Game.GetGameSpeedType()].GoldenAgePercent)/100)
local RNC = GameInfoTypes["BUILDING_Red_Night_Castle"]
local ScarletPalace = GameInfoTypes["BUILDING_SCARLET_PALACE"]
function RNCGoldenAge(PlayerID, nEra)
	local pPlayer = Players[PlayerID]
	if not pPlayer or not pPlayer:IsAlive() then return end
	
	if pPlayer:CountNumBuildings(RNC) <= 0 then return end
	if pPlayer:CountNumBuildings(ScarletPalace) <= 0 then
		pPlayer:ChangeGoldenAgeTurns( 10 * RncGameSpeed + 1 )
	else
		pPlayer:ChangeGoldenAgeTurns( 20 * RncGameSpeed + 1 )
	end
end
GameEvents.PlayerSetEra.Add(RNCGoldenAge)
----------------------------------------------------------------------------------------------------------------------------
-- 红色不夜城：传统政策额外加成
----------------------------------------------------------------------------------------------------------------------------
local iTradition = GameInfoTypes.POLICY_BRANCH_TRADITION
local iExtraTradition = GameInfoTypes.POLICY_RED_NIGHT_CASTLE
function ScarletOpenTree(iPlayer, iPolicyBranch)
	local pPlayer = Players[iPlayer]
	if pPlayer == nil or not pPlayer:IsAlive() then return end
	
	if pPlayer:HasPolicyBranch(iTradition) and pPlayer:CountNumBuildings(RNC) > 0 then
		pPlayer:SetHasPolicy(iExtraTradition, true, true)	
	else
		pPlayer:SetHasPolicy(iExtraTradition, false)
	end
end
GameEvents.PlayerAdoptPolicyBranch.Add(ScarletOpenTree)
----------------------------------------------------------------------------------------------------------------------------
-- 次元之爪：传送突袭
----------------------------------------------------------------------------------------------------------------------------
local ScarletTransport = 0
local ScarletTransportButton = {
	Name = "REMILIA SUPER TRANSPORT",
	Title = "TXT_KEY_TITLE_REMILIA_SUPER_TRANSPORT",
	OrderPriority = 200,
	IconAtlas = "SCARLETSKILL_ATLAS",
	PortraitIndex = 30,
	ToolTip = "TXT_KEY_COND_REMILIA_SUPER_TRANSPORT", -- or a TXT_KEY_ or a function
	Condition = function(action, unit)
		return unit:CanMove() and unit:IsHasPromotion(ScarletEWID)
	end, -- or nil or a boolean, default is true
	Disabled = function(action, unit)
		local pPlayer = Players[unit:GetOwner()];
		local iScarletEW = load( pPlayer, "ScarletTransport" .. unit:GetID()) or -4;
		--print(iScarletEW, unit:GetID(), Game.GetElapsedGameTurns() - iScarletEW)
		return Game.GetElapsedGameTurns() - iScarletEW <= 3
	end, -- or nil or a boolean, default is false
	Action = function(action, unit, eClick)
	if eClick == Mouse.eRClick then
		return
	end
	-- 四格范围传送地块高亮
	local uniqueRange = 4
	for dx = -uniqueRange, uniqueRange, 1 do
		for dy = -uniqueRange, uniqueRange, 1 do
			local iPlot = Map.PlotXYWithRangeCheck(unit:GetX(), unit:GetY(), dx, dy, uniqueRange);
			if iPlot ~= nil and iPlot:GetNumUnits() == 0 
			and not iPlot:IsMountain()
			and not iPlot:IsWater()
			and not iPlot:IsCity()
			then
				Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(iPlot:GetX(), iPlot:GetY())), true, Vector4(0.55, 0.15, 0.0, 1.0))
			end
		end
	end
	ScarletTransport = 1
end
}
LuaEvents.UnitPanelActionAddin(ScarletTransportButton)

function ScarletInputHandler( uiMsg, wParam, lParam )
	if ScarletTransport ~= 1 then return false end
	if uiMsg == MouseEvents.LButtonDown then
		lButtonDown = true
		local uniqueRange = 4
		local pPlot = Map.GetPlot(UI.GetMouseOverHex())
		local pPlayer = Players[Game:GetActivePlayer()]
		local num = 0
		local pSelUnit = UI.GetHeadSelectedUnit()
		local selUnitPlot = pSelUnit:GetPlot()
		local distance = Map.PlotDistance(selUnitPlot:GetX(), selUnitPlot:GetY(), pPlot:GetX(), pPlot:GetY())
		
		local iScarletEW = load( pPlayer, "ScarletTransport" .. pSelUnit:GetID() ) or -4;
		--print(iScarletEW, pSelUnit:GetID(), Game.GetElapsedGameTurns() - iScarletEW)
		if distance <= uniqueRange and distance > 0
		and Game.GetElapsedGameTurns() - iScarletEW > 3 and pSelUnit:IsHasPromotion(ScarletEWID) and pSelUnit:GetMoves() > 0
		and pPlot:GetNumUnits() == 0 and not pPlot:IsMountain() and not pPlot:IsWater() and not pPlot:IsCity()
		then
			pSelUnit:SetXY(pPlot:GetX(), pPlot:GetY());
			-- Events.AudioPlay2DSound("AS2D_SPACE_TRANSPORT") 
			local hex = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()))		
			Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("TXT_KEY_ALERT_REMILIA_SUPER_TRANSPORT", pSelUnit:GetName()))
			Events.GameplayFX(hex.x, hex.y, -1)
			-- 保存回合数，以减少计算
			save( pPlayer, "ScarletTransport" .. pSelUnit:GetID(), Game.GetElapsedGameTurns() )
		end
		Events.ClearHexHighlights()
		ScarletTransport = 0
	elseif uiMsg == MouseEvents.LButtonUp then
		if lButtonDown then
			lButtonDown = false
		end
	-- 右键取消
	elseif uiMsg == MouseEvents.RButtonDown then
		rButtonDown = true
	elseif uiMsg == MouseEvents.RButtonUp then
		if rButtonDown and ScarletTransport == 1 then
			rButtonDown = false
			ScarletTransport = 0
			Events.ClearHexHighlights()
		end
	end
	return false;
end
ContextPtr:SetInputHandler( ScarletInputHandler )
----------------------------------------------------------------------------------------------------------------------------
-- 单位命名：升级时保留旧名级
----------------------------------------------------------------------------------------------------------------------------
function SetScarletUnitsName( iPlayer, iOldUnit,  iNewUnit)
	local pPlayer = Players[ iPlayer ]
	if pPlayer == nil or not pPlayer:IsAlive() then return end

	local pUnit = pPlayer:GetUnitByID( iOldUnit );
	if pUnit == nil or pUnit:IsDead() or pUnit:IsDelayedDeath() or pUnit:HasName() then return end

	if  pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_RED_DEATH_KNIGHTS"]) then
		pUnit:SetName("TXT_KEY_UNIT_RED_DEATH_KNIGHT"); -- 赤殇血骑
	elseif pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_ETERNAL_WARDRAKE"]) then
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
	if player == nil or not player:IsAlive() then return end
	if player:IsBarbarian() or player:IsMinorCiv() then return end;
	if player:CountNumBuildings(BloodFortressID) <= 0 then return end

	local bPlayerHuman = player:IsHuman()
	local NowEra = player:GetCurrentEra()
	for city in player:Cities() do
		if city:IsHasBuilding(BloodFortressID) then
			local cityPlot = city:Plot();
			local num_plot_units = 0
			for plot in PlotAreaSpiralIterator(cityPlot, 3, SECTOR_NORTH, DIRECTION_CLOCKWISE) do
				if plot and plot:GetNumUnits() > 0 then
					for i = 0, plot:GetNumUnits() - 1, 1 do
						local fUnit = plot:GetUnit(i)
						if fUnit:IsCombatUnit() then
							num_plot_units = num_plot_units + 1
						end
					end
				end
			end
			if num_plot_units > 0 then
				local unitProduction = math.ceil(num_plot_units * 1 * (NowEra + 1 ) * ProductionGameSpeed)
				city:SetOverflowProduction(city:GetOverflowProduction() + unitProduction);
				if bPlayerHuman then
					local hex = ToHexFromGrid(Vector2(city:GetX(), city:GetY()));
					Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("[COLOR_CITY_BROWN]+{1_Num}[ENDCOLOR][ICON_PRODUCTION]", unitProduction));
					Events.GameplayFX(hex.x, hex.y, -1);
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
			break
		end
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
			break
		end
	end
end
GameEvents.PlayerAdoptPolicyBranch.Add(ArcaneTabooLibraryAdoptPolicy)
GameEvents.PlayerDoTurn.Add(ArcaneTabooLibraryAdoptPolicy)
----------------------------------------------------------------------------------------------------------------------------
-- 禁忌秘文库：建成后开启意识形态
----------------------------------------------------------------------------------------------------------------------------
function ArcaneTabooLibraryAddNotification(iPlayer, iCity, iBuilding, bGold, bFaithOrCulture)
	if iBuilding ~= GameInfoTypes["BUILDING_ARCANE_TABOO_LIBRARY"] then return end

	local pPlayer = Players[iPlayer];
	if pPlayer == nil or not pPlayer:IsMajorCiv() then return end
	
	local heading = Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_SUMMARY_CHOOSE_IDEOLOGY");
	local text = Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_SUMMARY_CHOOSE_IDEOLOGY_ATL");
	pPlayer:AddNotification(NotificationTypes.NOTIFICATION_CHOOSE_IDEOLOGY, text, heading, -1, -1);
end
GameEvents.CityConstructed.Add(ArcaneTabooLibraryAddNotification)
----------------------------------------------------------------------------------------------------------------------------
-- 殷月红魔殿：市政厅减少阈值惩罚傀儡城提供人力
----------------------------------------------------------------------------------------------------------------------------
local iScarletPalace = GameInfoTypes["BUILDING_SCARLET_PALACE"]
local iScarletPalaceCulture = GameInfoTypes["BUILDING_SCARLET_PALACE_CULTURE"]
local iScarletPalaceManpower = GameInfoTypes["BUILDING_SCARLET_PALACE_MANPOWER"]
local iCorruptionLv0 = GameInfoTypes["CORRUPTION_LV0"]
local iCorruptionPuppet = GameInfoTypes["CORRUPTION_PUPPET"]
function ScarletPalaceBonus(playerID)
	local player = Players[playerID]
	if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
		return
	end
	
	if player:CountNumBuildings(iScarletPalace) == 1 then
		local pPalaceCity = nil
		local iNumCityHall = 0
		local iNumPuppet = 0
		for city in player:Cities() do
			if city:GetCorruptionLevel() > iCorruptionLv0 then
				iNumCityHall = iNumCityHall + 1
			elseif city:GetCorruptionLevel() == iCorruptionPuppet then
				iNumPuppet = iNumPuppet + 1
			end

			if city:IsHasBuilding(iScarletPalace) then
				pPalaceCity = city
			end
		end

		if pPalaceCity then
			pPalaceCity:SetNumRealBuilding(iScarletPalaceCulture, iNumCityHall)
			pPalaceCity:SetNumRealBuilding(iScarletPalaceManpower, iNumPuppet)
		end
	end
end
GameEvents.PlayerDoTurn.Add(ScarletPalaceBonus)
----------------------------------------------------------------------------------------------------------------------------