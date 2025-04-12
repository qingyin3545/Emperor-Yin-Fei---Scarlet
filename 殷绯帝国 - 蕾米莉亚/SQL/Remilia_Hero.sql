-- ============================================================================
-- Audio_Sounds table
-- ============================================================================
INSERT OR REPLACE INTO Audio_Sounds
        (SoundID,								Filename,						LoadType)
VALUES  ('SND_UNIT_REMILIA_IDLE',		        'lmly_idle',                    'DynamicResident'), 
        ('SND_UNIT_REMILIA_ATTACK_VOX_A',		'lmly_AttackA',                 'DynamicResident'), 
        ('SND_UNIT_REMILIA_ATTACK_VOX_B',		'lmly_AttackB',                 'DynamicResident'), 
        ('SND_UNIT_REMILIA_DEATH',		        'lmly_dead',               		'DynamicResident'), 
        ('SND_UNIT_REMILIA_FLYING',		        'lmly_1pass',				    'DynamicResident'), 
         
		('SND_UNIT_REMILIA_CHARGE_ATTACK',		'lmly_R',			            'DynamicResident'),
		('SND_UNIT_REMILIA_CAST',				'lmly_E2_01',			        'DynamicResident');
-- ============================================================================
-- Audio_3DSounds table
-- ============================================================================   
INSERT OR REPLACE INTO Audio_3DSounds
        (ScriptID,								SoundID,							SoundType,      MaxVolume, MinVolume)
VALUES  ('AS3D_UNIT_REMILIA_IDLE',              'SND_UNIT_REMILIA_IDLE',		    'GAME_SFX',     30,        30),
        ('AS3D_UNIT_REMILIA_ATTACK_VOX_A',      'SND_UNIT_REMILIA_ATTACK_VOX_A',	'GAME_SFX',     60,        60),
        ('AS3D_UNIT_REMILIA_ATTACK_VOX_B',      'SND_UNIT_REMILIA_ATTACK_VOX_B',	'GAME_SFX',     60,        60),
        ('AS3D_UNIT_REMILIA_DEATH',				'SND_UNIT_REMILIA_DEATH',			'GAME_SFX',     60,        60),
        ('AS3D_UNIT_REMILIA_FLYING',			'SND_UNIT_REMILIA_FLYING',			'GAME_SFX',     60,        60),
	    ('AS3D_UNIT_REMILIA_CHARGE_ATTACK',		'SND_UNIT_REMILIA_CHARGE_ATTACK',	'GAME_SFX',     60,        60),
		('AS3D_UNIT_REMILIA_CAST',				'SND_UNIT_REMILIA_CAST',			'GAME_SFX',     60,        60);
-- ============================================================================
-- Remilia_Hero UnitInfos
-- ============================================================================
INSERT INTO ArtDefine_UnitInfos 
		(Type, 								DamageStates,	Formation)
SELECT	'ART_DEF_UNIT_REMILIA',				DamageStates, 	null
FROM ArtDefine_UnitInfos WHERE Type = 'ART_DEF_UNIT__WARRIOR';

INSERT INTO ArtDefine_UnitInfoMemberInfos 	
		(UnitInfoType,					UnitMemberInfoType,				NumMembers)
VALUES	('ART_DEF_UNIT_REMILIA', 		'ART_DEF_UNIT_MEMBER_REMILIA',	1);

INSERT INTO ArtDefine_UnitMemberCombats 
		(UnitMemberType,							EnableActions, DisableActions, MoveRadius, ShortMoveRadius, ChargeRadius, AttackRadius, RangedAttackRadius, MoveRate, ShortMoveRate, TurnRateMin, TurnRateMax, TurnFacingRateMin, TurnFacingRateMax, RollRateMin, RollRateMax, PitchRateMin, PitchRateMax, LOSRadiusScale, TargetRadius, TargetHeight, HasShortRangedAttack, HasLongRangedAttack, HasLeftRightAttack, HasStationaryMelee, HasStationaryRangedAttack, HasRefaceAfterCombat, ReformBeforeCombat, HasIndependentWeaponFacing, HasOpponentTracking, HasCollisionAttack, AttackAltitude, AltitudeDecelerationDistance, OnlyTurnInMovementActions, RushAttackFormation)
SELECT	'ART_DEF_UNIT_MEMBER_REMILIA',				EnableActions, DisableActions, MoveRadius, ShortMoveRadius, ChargeRadius, AttackRadius, RangedAttackRadius, MoveRate, ShortMoveRate, TurnRateMin, TurnRateMax, TurnFacingRateMin, TurnFacingRateMax, RollRateMin, RollRateMax, PitchRateMin, PitchRateMax, LOSRadiusScale, TargetRadius, TargetHeight, HasShortRangedAttack, HasLongRangedAttack, HasLeftRightAttack, HasStationaryMelee, HasStationaryRangedAttack, HasRefaceAfterCombat, ReformBeforeCombat, HasIndependentWeaponFacing, HasOpponentTracking, HasCollisionAttack, AttackAltitude, AltitudeDecelerationDistance, OnlyTurnInMovementActions, RushAttackFormation
FROM ArtDefine_UnitMemberCombats WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WARRIOR';

INSERT INTO ArtDefine_UnitMemberCombatWeapons	
		(UnitMemberType,							"Index", SubIndex, ID, VisKillStrengthMin, VisKillStrengthMax, ProjectileSpeed, ProjectileTurnRateMin, ProjectileTurnRateMax, HitEffect, HitEffectScale, HitRadius, ProjectileChildEffectScale, AreaDamageDelay, ContinuousFire, WaitForEffectCompletion, TargetGround, IsDropped, WeaponTypeTag, WeaponTypeSoundOverrideTag)
SELECT	'ART_DEF_UNIT_MEMBER_REMILIA',				"Index", SubIndex, ID, VisKillStrengthMin, VisKillStrengthMax, ProjectileSpeed, ProjectileTurnRateMin, ProjectileTurnRateMax, HitEffect, HitEffectScale, HitRadius, ProjectileChildEffectScale, AreaDamageDelay, ContinuousFire, WaitForEffectCompletion, TargetGround, IsDropped, WeaponTypeTag, WeaponTypeSoundOverrideTag
FROM ArtDefine_UnitMemberCombatWeapons WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WARRIOR';

INSERT INTO ArtDefine_UnitMemberInfos 	
		(Type, 								Scale,	ZOffset, Domain, Model, 				MaterialTypeTag, MaterialTypeSoundOverrideTag)
SELECT	'ART_DEF_UNIT_MEMBER_REMILIA',		0.21,	ZOffset, Domain, 'Remilia.fxsxml',		MaterialTypeTag, MaterialTypeSoundOverrideTag
FROM ArtDefine_UnitMemberInfos WHERE Type = 'ART_DEF_UNIT_MEMBER_WARRIOR';

INSERT INTO ArtDefine_StrategicView 
		(StrategicViewType, 			TileType,	Asset)
VALUES	('ART_DEF_UNIT_REMILIA',			'Unit', 	'Scarlet_Atlas128.dds');