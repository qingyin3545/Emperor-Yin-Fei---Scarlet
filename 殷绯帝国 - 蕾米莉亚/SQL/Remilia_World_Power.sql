CREATE TABLE IF NOT EXISTS ROG_GlobalUserSettings (Type text default null, Value integer default 0);
--------------------------------------------------------------------------------------------------------------------
-- 强权初始科技兼容
--------------------------------------------------------------------------------------------------------------------
DELETE FROM Civilization_FreeTechs WHERE CivilizationType='CIVILIZATION_SCARLET' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1); 
INSERT INTO Civilization_FreeTechs(CivilizationType,TechType )
SELECT 'CIVILIZATION_SCARLET',	    'TECH_FISHERY' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL
SELECT 'CIVILIZATION_SCARLET',	    'TECH_AGRICULTURE' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL
SELECT 'CIVILIZATION_SCARLET',	    'TECH_HUNTING' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL
SELECT 'CIVILIZATION_SCARLET',	    'TECH_STONE_TOOLS' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);
--------------------------------------------------------------------------------------------------------------------
-- 世界强权健康度
--------------------------------------------------------------------------------------------------------------------
INSERT INTO Improvement_Yields (ImprovementType, YieldType, Yield) 
SELECT	 'IMPROVEMENT_SCARLET_CASTLE', 'YIELD_HEALTH', 1 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);

INSERT INTO Building_YieldModifiers (BuildingType, YieldType, Yield) 
SELECT	 'BUILDING_Vampire_Mansion', 'YIELD_HEALTH', 1 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);
--------------------------------------------------------------------------------------------------------------------
-- 血盟古堡额外资源兼容
--------------------------------------------------------------------------------------------------------------------
INSERT INTO Improvement_ResourceTypes (ImprovementType, ResourceType)
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_RASPBERRYZ' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL-- 浆果
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_TEQUILA' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 龙舌兰酒
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_SULFUR' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 硫磺
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_SANPEDRO' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 圣佩德罗
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_TITANIUM' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 钛
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_SAFFRON' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 藏红花
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_TIN' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1); -- 硝石
--------------------------------------------------------------------------------------------------------------------
-- 血龙礼拜堂：世界强权新军事建筑兼容
--------------------------------------------------------------------------------------------------------------------
INSERT INTO Building_BuildingClassYieldChanges (BuildingType, BuildingClassType, YieldType, YieldChange) 
SELECT	 'BUILDING_BLOOD_DRAGON_KEEP', 'BUILDINGCLASS_ZXZCC', 'YIELD_GOLD', 5 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --重型造船厂
SELECT	 'BUILDING_BLOOD_DRAGON_KEEP', 'BUILDINGCLASS_FW_BIOMOD_TANK', 'YIELD_GOLD', 25 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1); --星际基地
--------------------------------------------------------------------------------------------------------------------
-- 赤龙圣团：世界强权万古长战晋升兼容
--------------------------------------------------------------------------------------------------------------------
DELETE FROM UnitPromotions_UnitClasses WHERE UnitClassType='UNITCLASS_CRIMSONDRAKE' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);
INSERT INTO UnitPromotions_UnitClasses (PromotionType, UnitClassType, Modifier) 
SELECT	 'PROMOTION_ANTI_TANK', 'UNITCLASS_CRIMSONDRAKE', -100 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1)UNION ALL --兼容强权反装甲克制系数的降低
SELECT	 'PROMOTION_AIR_ATTACK', 'UNITCLASS_CRIMSONDRAKE', -50 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1); --兼容强权攻击机克制系数的降低
--------------------------------------------------------------------------------------------------------------------
-- 世界强权屏蔽兼容
--------------------------------------------------------------------------------------------------------------------
INSERT INTO Civilization_BuildingClassOverrides (CivilizationType, BuildingClassType, BuildingType) 
SELECT	 'CIVILIZATION_SCARLET', 'BUILDINGCLASS_WHITE_HOUSE', null WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
-- 重型机甲晋升替换
--------------------------------------------------------------------------------------------------------------------
UPDATE Unit_FreePromotions
SET PromotionType = 'PROMOTION_HEAVY_ROBORT'
WHERE PromotionType = 'PROMOTION_TANK_COMBAT' 
AND UnitType = 'UNIT_CRIMSONDRAKE' 
AND NOT EXISTS (SELECT * FROM UnitPromotions WHERE Type='PROMOTION_HEAVY_ROBORT');
-- 虽然强权已经有更好的判定了，但既然有效那还是继续留着
CREATE TRIGGER SCARLET_PROMOTION
AFTER INSERT ON UnitPromotions
WHEN EXISTS (SELECT * FROM UnitPromotions WHERE Type='PROMOTION_HEAVY_ROBORT')
BEGIN
	UPDATE Unit_FreePromotions
	SET PromotionType = 'PROMOTION_HEAVY_ROBORT'
	WHERE PromotionType = 'PROMOTION_TANK_COMBAT' AND UnitType = 'UNIT_CRIMSONDRAKE';
END;