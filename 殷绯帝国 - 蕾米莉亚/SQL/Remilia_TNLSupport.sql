CREATE TABLE IF NOT EXISTS TNL_World_Civilization_StartingPlots(CivilizationType text REFERENCES Civilizations(Type), X integer default -1, Y integer default -1);
INSERT INTO TNL_World_Civilization_StartingPlots
			(CivilizationType,										X,		Y)
VALUES		('CIVILIZATION_SCARLET',			   					31,     67);	-- Romania

CREATE TABLE IF NOT EXISTS TNL_EastAsia_Civilization_StartingPlots(CivilizationType text REFERENCES Civilizations(Type), X integer default -1, Y integer default -1);
INSERT INTO TNL_EastAsia_Civilization_StartingPlots
			(CivilizationType,										X,		Y)
VALUES		('CIVILIZATION_SCARLET',			   					108,    77);	-- Scarleina

-- VMC DoneTurn -- 开启VMC回合相关Event
UPDATE CustomModOptions SET Value = 1 Where Name = 'EVENTS_PLAYER_TURN';

-- 重型机甲晋升替换
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
