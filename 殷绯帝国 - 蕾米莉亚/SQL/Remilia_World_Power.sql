--------------------------------------------------------------------------------------------------------------------
-- 世界强权兼容性更改
--------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ROG_GlobalUserSettings (Type text default null, Value integer default 0);
INSERT INTO ROG_GlobalUserSettings(Type, Value) SELECT 'MOD_REMILIA', 0;

--DROP TRIGGER CivRemilia1;
--DROP TRIGGER CivRemilia2;
CREATE TRIGGER CivRemilia1
AFTER UPDATE ON ROG_GlobalUserSettings
WHEN NEW.Type = 'MOD_REMILIA' AND NEW.Value= 1
BEGIN
	--------------------------------------------------------------------------------------------------------------------
	-- 初始科技兼容
	--------------------------------------------------------------------------------------------------------------------
	DELETE FROM Civilization_FreeTechs WHERE CivilizationType='CIVILIZATION_SCARLET';
	INSERT INTO Civilization_FreeTechs(CivilizationType, TechType)
	SELECT 'CIVILIZATION_SCARLET', 'TECH_FISHERY' UNION ALL
	SELECT 'CIVILIZATION_SCARLET', 'TECH_AGRICULTURE' UNION ALL
	SELECT 'CIVILIZATION_SCARLET', 'TECH_HUNTING' UNION ALL
	SELECT 'CIVILIZATION_SCARLET', 'TECH_STONE_TOOLS';

	--------------------------------------------------------------------------------------------------------------------
	-- 健康度
	--------------------------------------------------------------------------------------------------------------------
	INSERT INTO Improvement_Yields (ImprovementType, YieldType, Yield) 
	SELECT 'IMPROVEMENT_SCARLET_CASTLE', 'YIELD_HEALTH', 1;

	INSERT INTO Building_YieldModifiers (BuildingType, YieldType, Yield) 
	SELECT 'BUILDING_Vampire_Mansion', 'YIELD_HEALTH', 1;

	--------------------------------------------------------------------------------------------------------------------
	-- 血盟古堡额外资源兼容（使用LIKE以保证未加载强权时数据库没有报错）
	--------------------------------------------------------------------------------------------------------------------
	INSERT INTO Improvement_ResourceTypes (ImprovementType, ResourceType)
	SELECT  'IMPROVEMENT_SCARLET_CASTLE', t.Type FROM Resources t
	WHERE t.Type LIKE 'RESOURCE_RASPBERRYZ' -- 浆果
	OR	  t.Type LIKE 'RESOURCE_TEQUILA'	-- 龙舌兰酒
	OR	  t.Type LIKE 'RESOURCE_SULFUR'		-- 硫磺
	OR	  t.Type LIKE 'RESOURCE_SANPEDRO'	-- 圣佩德罗
	OR	  t.Type LIKE 'RESOURCE_TITANIUM'	-- 钛
	OR	  t.Type LIKE 'RESOURCE_SAFFRON'	-- 藏红花
	OR	  t.Type LIKE 'RESOURCE_TIN';		-- 硝石

	--------------------------------------------------------------------------------------------------------------------
	-- 血龙礼拜堂：新军事建筑兼容
	--------------------------------------------------------------------------------------------------------------------
	INSERT INTO Building_BuildingClassYieldChanges (BuildingType, BuildingClassType, YieldType, YieldChange) 
	SELECT 'BUILDING_BLOOD_DRAGON_KEEP', 'BUILDINGCLASS_ZXZCC', 'YIELD_GOLD', 5 UNION ALL --重型造船厂
	SELECT 'BUILDING_BLOOD_DRAGON_KEEP', 'BUILDINGCLASS_BIOMOD_TANK', 'YIELD_GOLD', 25; --星际基地

	--------------------------------------------------------------------------------------------------------------------
	-- 白宫屏蔽
	--------------------------------------------------------------------------------------------------------------------
	INSERT INTO Civilization_BuildingClassOverrides (CivilizationType, BuildingClassType, BuildingType) 
	SELECT 'CIVILIZATION_SCARLET', 'BUILDINGCLASS_WHITE_HOUSE', NULL;

	--------------------------------------------------------------------------------------------------------------------
	-- 赤龙圣团晋升替换重型机甲
	--------------------------------------------------------------------------------------------------------------------
	DELETE FROM Unit_FreePromotions WHERE PromotionType = 'PROMOTION_TANK_COMBAT' AND UnitType = 'UNIT_CRIMSONDRAKE';
	INSERT INTO Unit_FreePromotions(UnitType, PromotionType)
	SELECT 'UNIT_CRIMSONDRAKE', t.Type FROM UnitPromotions t WHERE t.Type LIKE 'PROMOTION_HEAVY_ROBORT';
END;

--开启兼容
UPDATE ROG_GlobalUserSettings SET Value = 1 
WHERE Type = 'MOD_REMILIA' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type= 'WORLD_POWER_PATCH' AND Value = 1);

CREATE TRIGGER CivRemilia2
AFTER UPDATE ON ROG_GlobalUserSettings
WHEN NEW.Type = 'WORLD_POWER_PATCH' AND NEW.Value= 1
BEGIN
    UPDATE ROG_GlobalUserSettings SET Value = 1 
    WHERE Type = 'MOD_REMILIA' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type= 'MOD_REMILIA' AND Value = 0);
END;