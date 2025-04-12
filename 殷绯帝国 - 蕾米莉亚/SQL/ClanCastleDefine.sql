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