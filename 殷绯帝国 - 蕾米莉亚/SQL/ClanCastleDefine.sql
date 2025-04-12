--------------------------------------------------------------------------------------------------------------------
-- 血盟古堡
--------------------------------------------------------------------------------------------------------------------
INSERT INTO ArtDefine_LandmarkTypes(Type, LandmarkType, FriendlyName)
SELECT 'ART_DEF_IMPROVEMENT_SCARLET_CASTLE', 'Improvement', 'SCARLET_CASTLE';

INSERT INTO ArtDefine_StrategicView(StrategicViewType, TileType, Asset)
SELECT 'ART_DEF_IMPROVEMENT_SCARLET_CASTLE', 'Improvement', 'SV_ClanCastle.dds';

INSERT INTO ArtDefine_Landmarks(Era, State, Scale, ImprovementType, LayoutHandler, ResourceType, Model, TerrainContour)
SELECT 'Any', 'UnderConstruction', 0.0018,  'ART_DEF_IMPROVEMENT_SCARLET_CASTLE', 'SNAPSHOT', 'ART_DEF_RESOURCE_ALL', 'ClanCastle_hb.fxsxml', 1 UNION ALL
SELECT 'Any', 'Constructed', 0.0018,  'ART_DEF_IMPROVEMENT_SCARLET_CASTLE', 'RANDOM', 'ART_DEF_RESOURCE_ALL', 'ClanCastle_01.fxsxml', 1 UNION ALL
SELECT 'Any', 'Constructed', 0.0018,  'ART_DEF_IMPROVEMENT_SCARLET_CASTLE', 'RANDOM', 'ART_DEF_RESOURCE_ALL', 'ClanCastle_02.fxsxml', 1 UNION ALL
SELECT 'Any', 'Constructed', 0.0018,  'ART_DEF_IMPROVEMENT_SCARLET_CASTLE', 'RANDOM', 'ART_DEF_RESOURCE_ALL', 'ClanCastle_03.fxsxml', 1 UNION ALL
SELECT 'Any', 'Pillaged', 0.0018,  'ART_DEF_IMPROVEMENT_SCARLET_CASTLE', 'SNAPSHOT', 'ART_DEF_RESOURCE_ALL', 'ClanCastle_pl.fxsxml', 1;
--------------------------------------------------------------------------------------------------------------------
-- 世界强权额外资源兼容
--------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ROG_GlobalUserSettings (Type text default null, Value integer default 0);
INSERT INTO Improvement_ResourceTypes (ImprovementType, ResourceType)
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_RASPBERRYZ' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL-- 浆果
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_TEQUILA' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 龙舌兰酒
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_SULFUR' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 硫磺
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_SANPEDRO' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 圣佩德罗
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_TITANIUM' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 钛
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_SAFFRON' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL -- 藏红花
SELECT  'IMPROVEMENT_SCARLET_CASTLE',   'RESOURCE_TIN' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1); -- 硝石
--------------------------------------------------------------------------------------------------------------------
-- 血盟古堡：相邻设施产出加成
--------------------------------------------------------------------------------------------------------------------
INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType ,OtherImprovementType,YieldType, Yield)
SELECT	'IMPROVEMENT_SCARLET_CASTLE',Type,  'YIELD_FOOD', 1  
FROM Improvements WHERE Type !='IMPROVEMENT_SCARLET_CASTLE';

INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType ,OtherImprovementType,YieldType, Yield)
SELECT	 'IMPROVEMENT_SCARLET_CASTLE', Type,  'YIELD_PRODUCTION', 1 
FROM Improvements WHERE Type !='IMPROVEMENT_SCARLET_CASTLE';

INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType ,OtherImprovementType,YieldType, Yield)
SELECT	 'IMPROVEMENT_SCARLET_CASTLE', Type,  'YIELD_GOLD', 2 
FROM Improvements WHERE Type !='IMPROVEMENT_SCARLET_CASTLE';

CREATE TRIGGER Improvement_YieldAdjacent_New
AFTER INSERT ON Improvements
WHEN 'IMPROVEMENT_SCARLET_CASTLE'!=NEW.Type  
BEGIN
	INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType ,OtherImprovementType,YieldType, Yield)
	SELECT	 'IMPROVEMENT_SCARLET_CASTLE',Type,  'YIELD_FOOD', 1  
	FROM Improvements WHERE Type !='IMPROVEMENT_SCARLET_CASTLE';

	INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType ,OtherImprovementType,YieldType, Yield)
	SELECT	 'IMPROVEMENT_SCARLET_CASTLE', Type,  'YIELD_PRODUCTION', 1
	FROM Improvements WHERE Type !='IMPROVEMENT_SCARLET_CASTLE';
	
	INSERT INTO Improvement_AdjacentImprovementYieldChanges(ImprovementType ,OtherImprovementType,YieldType, Yield)
	SELECT	 'IMPROVEMENT_SCARLET_CASTLE', Type,  'YIELD_GOLD', 2
	FROM Improvements WHERE Type !='IMPROVEMENT_SCARLET_CASTLE';
END;
--------------------------------------------------------------------------------------------------------------------