CREATE TABLE IF NOT EXISTS TNL_World_Civilization_StartingPlots(CivilizationType text REFERENCES Civilizations(Type), X integer default -1, Y integer default -1);
INSERT INTO TNL_World_Civilization_StartingPlots
			(CivilizationType,										X,		Y)
VALUES		('CIVILIZATION_SCARLET',			   					31,     67);	-- Romania

CREATE TABLE IF NOT EXISTS TNL_EastAsia_Civilization_StartingPlots(CivilizationType text REFERENCES Civilizations(Type), X integer default -1, Y integer default -1);
INSERT INTO TNL_EastAsia_Civilization_StartingPlots
			(CivilizationType,										X,		Y)
VALUES		('CIVILIZATION_SCARLET',			   					108,    77);	-- Scarleina