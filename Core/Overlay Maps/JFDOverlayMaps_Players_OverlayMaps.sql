--==========================================================================================================================
-- OVERLAY MAPS: PLAYERS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMaps
----------------------------------------------------------------------------------------------------------------------------
-----------------------------------
--PLAYERS: BORDERS
-----------------------------------
INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_BORDERS',					'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_BORDERS');

INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerBorder,				IteratePlayers,		PopulatePlayers,		DontShowLegend)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_BORDERS_OWNER',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_BORDERS',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_BORDERS_OWNER',			1,							1,					1,						1);

--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerBorderRank,			IteratePlayers,		PopulateRankings,		DontShowLegend)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_BORDERS_RANK',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_BORDERS',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_BORDERS_RANK',				1,							1,					1,						1);
-----------------------------------
--PLAYERS: GOVERNMENT
-----------------------------------
INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											RequiresToExist)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT',				'GOVERNMENT_JFD_MONARCHY');

--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerGovernment,			IteratePlayers,		PopulatePlayers)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_STATUS',		'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_STATUS',		1,							1,					1);

INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerGovernmentType,		IteratePlayers,		PopulatePlayers)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',			1,							1,					1);
-----------------------------------
--PLAYERS: GROWTH
-----------------------------------
INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GROWTH',					'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_GROWTH');

INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerGrowth,				IteratePlayers,		PopulatePlayers)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GROWTH_STATUS',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_GROWTH',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_GROWTH_STATUS',			1,							1,					1);

--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerGrowthRank,			IteratePlayers,		PopulateRankings,		DontShowLegend)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_GROWTH_RANK',				'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_GROWTH',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_GROWTH_RANK',				1,							1,					1,						1);
-----------------------------------
--PLAYERS: HAPPINESS
-----------------------------------
INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_HAPPINESS');

INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerHappiness,			IteratePlayers,		PopulatePlayers)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_STATUS',		'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_HAPPINESS',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_STATUS',			1,							1,					1);

--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerHappinessRank,		IteratePlayers,		PopulateRankings,		DontShowLegend)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_RANK',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_HAPPINESS',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_RANK',			1,							1,					1,						1);
-----------------------------------
--PLAYERS: IDEOLOGY
-----------------------------------
INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY');

INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerIdeologyType,		IteratePlayers,		PopulatePlayers)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY_TYPE',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY_TYPE',			1,							1,					1);
-----------------------------------
--PLAYERS: INDUSTRY
-----------------------------------
--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_INDUSTRY',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_INDUSTRY');
--
--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerIndustryRank,		IteratePlayers,		PopulateRankings,		DontShowLegend)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_INDUSTRY_RANK',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_INDUSTRY',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_INDUSTRY_RANK',			1,							1,					1,						1);
-----------------------------------
--PLAYERS: MILITARY
-----------------------------------
--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_MILITARY',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_MILITARY');
--
--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerMilitaryRank,		IteratePlayers,		PopulateRankings,		DontShowLegend)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_MILITARY_RANK',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_MILITARY',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_MILITARY_RANK',			1,							1,					1,						1);
-----------------------------------
--PLAYERS: POPULATION
-----------------------------------
--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_POPULATION',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_POPULATION');
--
--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerPopulationRank,		IteratePlayers,		PopulateRankings,		DontShowLegend)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_POPULATION_RANK',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_POPULATION',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_POPULATION_RANK',			1,							1,					1,						1);
-----------------------------------
--PLAYERS: RELIGION
-----------------------------------
--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_RELIGION',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_RELIGION');
--
--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerReligion,			IteratePlayers,		PopulatePlayers,	PopulateReligions)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_RELIGION_TYPE',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_RELIGION',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_RELIGION_TYPE',			1,							1,					1,					1);
-----------------------------------
--PLAYERS: TECHNOLOGY
-----------------------------------
INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY');

INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerTechnology,			IteratePlayers,		PopulatePlayers)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_STATUS',		'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_STATUS',		1,							1,					1);

INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerTechnologyEraType,	IteratePlayers,		PopulatePlayers)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',			1,							1,					1);

--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerTechnologyRank,		IteratePlayers,		PopulateRankings,		DontShowLegend)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_RANK',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_RANK',			1,							1,					1,						1);
-----------------------------------
--PLAYERS: TREASURY
-----------------------------------
INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TREASURY',				'OVERLAY_CLASS_JFD_PLAYERS',		null,										'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TREASURY');

INSERT INTO JFD_OverlayMaps	
		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerTreasury,			IteratePlayers,		PopulatePlayers)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TREASURY_STATUS',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_TREASURY',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TREASURY_STATUS',			1,							1,					1);

--INSERT INTO JFD_OverlayMaps	
--		(Type,												ClassType,							MasterOverlayMapType,						ShortDescription,											IsPlayerTreasuryRank,		IteratePlayers,		PopulateRankings,		DontShowLegend)
--VALUES	('OVERLAY_MAP_JFD_PLAYERS_TREASURY_RANK',			'OVERLAY_CLASS_JFD_PLAYERS',		'OVERLAY_MAP_JFD_PLAYERS_TREASURY',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TREASURY_RANK',			1,							1,					1,						1);
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMap_Legends
----------------------------------------------------------------------------------------------------------------------------
-----------------------------------
--PLAYERS: BORDERS
-----------------------------------
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												UsePlayerDescription,											IsPlayerBorder,								UsePlayerIcon,								UsePlayerColor,								ColorAlpha,			DefaultChecked,		ShowInLegendAlways)	
VALUES	('OVERLAY_MAP_JFD_PLAYERS_BORDERS_OWNER',		'OVERLAY_LEGEND_JFD_PLAYER_BORDER',						1,																1,											1,											1,											1.0,				1,					1);
-----------------------------------
--PLAYERS: GOVERNMENT
-----------------------------------
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerGovernment,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)						
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_STATUS',	'OVERLAY_LEGEND_JFD_GOVERNMENT',						'TXT_KEY_LEGEND_JFD_GOVERNMENT',								1,											'[ICON_JFD_GOVERNMENT]',					'COLOR_JFD_OVERLAY_YIELD_SOVEREIGNTY',		1.0,				1,					1);	

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerGovernmentNOT,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)						
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_STATUS',	'OVERLAY_LEGEND_JFD_GOVERNMENT_NOT',					'TXT_KEY_LEGEND_JFD_GOVERNMENT_NOT',							1,											'[ICON_BULLET]',							'COLOR_JFD_OVERLAY_GREY',					1.0,				1,					1);	

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerGovernmentType,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)					
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_MONARCHY',				'TXT_KEY_GOVERNMENT_JFD_MONARCHY_DESC',							'GOVERNMENT_JFD_MONARCHY',					'[ICON_GOVERNMENT_JFD_MONARCHY]',			'COLOR_JFD_OVERLAY_RED',					1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_PRINCIPALITY',			'TXT_KEY_GOVERNMENT_JFD_PRINCIPALITY_DESC',						'GOVERNMENT_JFD_PRINCIPALITY',				'[ICON_GOVERNMENT_JFD_PRINCIPALITY]',		'COLOR_JFD_OVERLAY_YELLOW',					1.0,				1,					0),	
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_REPUBLIC',				'TXT_KEY_GOVERNMENT_JFD_REPUBLIC_DESC',							'GOVERNMENT_JFD_REPUBLIC',					'[ICON_GOVERNMENT_JFD_REPUBLIC]',			'COLOR_JFD_OVERLAY_BLUE',					1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_IMPERIAL',				'TXT_KEY_GOVERNMENT_JFD_IMPERIAL_DESC',							'GOVERNMENT_JFD_IMPERIAL',					'[ICON_GOVERNMENT_JFD_IMPERIAL]',			'COLOR_JFD_OVERLAY_PURPLE_DARK',			1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_MERCHANT',				'TXT_KEY_GOVERNMENT_JFD_MERCHANT_DESC',							'GOVERNMENT_JFD_MERCHANT',					'[ICON_GOVERNMENT_JFD_MERCHANT]',			'COLOR_JFD_OVERLAY_YELLOW_MIDDLE',			1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_MILITARY',				'TXT_KEY_GOVERNMENT_JFD_MILITARY_DESC',							'GOVERNMENT_JFD_MILITARY',					'[ICON_GOVERNMENT_JFD_MILITARY]',			'COLOR_JFD_OVERLAY_GREY_DARK',				1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_NOMADIC',				'TXT_KEY_GOVERNMENT_JFD_NOMADIC_DESC',							'GOVERNMENT_JFD_NOMADIC',					'[ICON_GOVERNMENT_JFD_NOMADIC]',			'COLOR_JFD_OVERLAY_BROWN',					1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_MONASTIC',				'TXT_KEY_GOVERNMENT_JFD_MONASTIC_DESC',							'GOVERNMENT_JFD_MONASTIC',					'[ICON_GOVERNMENT_JFD_MONASTIC]',			'COLOR_JFD_OVERLAY_PURPLE_LIGHT',			1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_REVOLUTIONARY',			'TXT_KEY_GOVERNMENT_JFD_REVOLUTIONARY_DESC',					'GOVERNMENT_JFD_REVOLUTIONARY',				'[ICON_GOVERNMENT_JFD_REVOLUTIONARY]',		'COLOR_JFD_OVERLAY_ORANGE_DARK',			1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_THEOCRATIC',				'TXT_KEY_GOVERNMENT_JFD_THEOCRATIC_DESC',						'GOVERNMENT_JFD_THEOCRATIC',				'[ICON_GOVERNMENT_JFD_THEOCRATIC]',			'COLOR_JFD_OVERLAY_WHITE',					1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_TOTALITARIAN',			'TXT_KEY_GOVERNMENT_JFD_TOTALITARIAN_DESC',						'GOVERNMENT_JFD_TOTALITARIAN',				'[ICON_GOVERNMENT_JFD_TOTALITARIAN]',		'COLOR_JFD_OVERLAY_BLACK',					1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_TRIBAL',					'TXT_KEY_GOVERNMENT_JFD_TRIBAL_DESC',							'GOVERNMENT_JFD_TRIBAL',					'[ICON_GOVERNMENT_JFD_TRIBAL]',				'COLOR_JFD_OVERLAY_ORANGE',					1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_CALIPHATE',				'TXT_KEY_GOVERNMENT_JFD_CALIPHATE_DESC',						'GOVERNMENT_JFD_CALIPHATE',					'[ICON_GOVERNMENT_JFD_CALIPHATE]',			'COLOR_JFD_OVERLAY_GREEN_DARK',				1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_HOLY_ROMAN',				'TXT_KEY_GOVERNMENT_JFD_HOLY_ROMAN_DESC',						'GOVERNMENT_JFD_HOLY_ROMAN',				'[ICON_GOVERNMENT_JFD_HOLY_ROMAN]',			'COLOR_JFD_OVERLAY_PURPLE_MIDDLE',			1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_MANDATE',				'TXT_KEY_GOVERNMENT_JFD_MANDATE_DESC',							'GOVERNMENT_JFD_MANDATE',					'[ICON_GOVERNMENT_JFD_MANDATE]',			'COLOR_JFD_OVERLAY_YELLOW_LIGHT',			1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_MAMLUKE',				'TXT_KEY_GOVERNMENT_JFD_MAMLUKE_DESC',							'GOVERNMENT_JFD_MAMLUKE',					'[ICON_GOVERNMENT_JFD_MAMLUKE]',			'COLOR_JFD_OVERLAY_YELLOW_DARK',			1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_PAPACY',					'TXT_KEY_GOVERNMENT_JFD_PAPACY_DESC',							'GOVERNMENT_JFD_PAPACY',					'[ICON_GOVERNMENT_JFD_PAPACY]',				'COLOR_JFD_OVERLAY_MAGENTA_LIGHT',			1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_SHOGUNATE',				'TXT_KEY_GOVERNMENT_JFD_SHOGUNATE_DESC',						'GOVERNMENT_JFD_SHOGUNATE',					'[ICON_GOVERNMENT_JFD_SHOGUNATE]',			'COLOR_JFD_OVERLAY_RED_DARK',				1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_CITY_STATE',				'TXT_KEY_GOVERNMENT_JFD_CITY_STATE_DESC',						'GOVERNMENT_JFD_CITY_STATE',				'[ICON_CITY_STATE]',						'COLOR_JFD_OVERLAY_GREY',					1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_GOVERNMENT_TYPE',		'OVERLAY_LEGEND_JFD_GOVERNMENT_TRIBE',					'TXT_KEY_GOVERNMENT_JFD_TRIBE_DESC',							'GOVERNMENT_JFD_TRIBE',						'[ICON_GOVERNMENT_JFD_TRIBE]',				'COLOR_JFD_OVERLAY_BROWN_LIGHT',			1.0,				1,					1);		
-----------------------------------
--PLAYERS: GROWTH
-----------------------------------
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerGrowthVPos,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GROWTH_STATUS',		'OVERLAY_LEGEND_JFD_GROWTH_BOOMING',					'TXT_KEY_LEGEND_JFD_GROWTH_BOOMING',							1,											'[ICON_FOOD_VPOS]',							'COLOR_JFD_OVERLAY_YIELD_FOOD_3',			1.0,				1,					1);							

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerGrowthPos,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GROWTH_STATUS',		'OVERLAY_LEGEND_JFD_GROWTH_GROWING',					'TXT_KEY_LEGEND_JFD_GROWTH_GROWING',							1,											'[ICON_FOOD_POS]',							'COLOR_JFD_OVERLAY_YIELD_FOOD',				1.0,				1,					1);							

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerGrowthNeu,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GROWTH_STATUS',		'OVERLAY_LEGEND_JFD_GROWTH_STAGNANT',					'TXT_KEY_LEGEND_JFD_GROWTH_STAGNANT',							1,											'[ICON_FOOD_NEU]',							'COLOR_JFD_OVERLAY_YIELD_FOOD_2',			1.0,				1,					1);							

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerGrowthNeg,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GROWTH_STATUS',		'OVERLAY_LEGEND_JFD_GROWTH_DECLINING',					'TXT_KEY_LEGEND_JFD_GROWTH_DECLINING',							1,											'[ICON_FOOD_NEG]',							'COLOR_JFD_OVERLAY_RED',					1.0,				1,					1);							
-----------------------------------
--PLAYERS: HAPPINESS
-----------------------------------
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerGoldenAge,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_STATUS',	'OVERLAY_LEGEND_JFD_GOLDEN_AGE',						'TXT_KEY_LEGEND_JFD_GOLDEN_AGE',								1,											'[ICON_GOLDEN_AGE]',						'COLOR_JFD_OVERLAY_GOLDEN_AGE',				1.0,				1,					1);

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerHappy,								IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_STATUS',	'OVERLAY_LEGEND_JFD_HAPPINESS_HAPPY',					'TXT_KEY_LEGEND_JFD_HAPPINESS_HAPPY',							1,											'[ICON_HAPPINESS_1]',						'COLOR_JFD_OVERLAY_HAPPINESS',				1.0,				1,					1);	

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerUnhappy,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_STATUS',	'OVERLAY_LEGEND_JFD_HAPPINESS_UNHAPPY',					'TXT_KEY_LEGEND_JFD_HAPPINESS_UNHAPPY',							1,											'[ICON_HAPPINESS_3]',						'COLOR_JFD_OVERLAY_UNHAPPINESS_3',			1.0,				1,					1);	

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerVeryUnhappy,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_STATUS',	'OVERLAY_LEGEND_JFD_HAPPINESS_VERY_UNHAPPY',			'TXT_KEY_LEGEND_JFD_HAPPINESS_VERY_UNHAPPY',					1,											'[ICON_HAPPINESS_4]',						'COLOR_JFD_OVERLAY_UNHAPPINESS_4',			1.0,				1,					1);	

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerAnarchy,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_STATUS',	'OVERLAY_LEGEND_JFD_HAPPINESS_ANARCHY',					'TXT_KEY_LEGEND_JFD_HAPPINESS_ANARCHY',							1,											'[ICON_RESISTANCE]',						'COLOR_JFD_OVERLAY_ANARCHY',				1.0,				1,					1);	
-----------------------------------	
--PLAYERS: IDEOLOGY
-----------------------------------
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerIdeologyType,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY_TYPE',		'OVERLAY_LEGEND_JFD_IDEOLOGY_AUTOCRACY',				'TXT_KEY_POLICY_BRANCH_AUTOCRACY',								'POLICY_BRANCH_AUTOCRACY',					'[ICON_IDEOLOGY_AUTOCRACY]',				'COLOR_JFD_OVERLAY_GREY',					1.0,				1,					1),			
		('OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY_TYPE',		'OVERLAY_LEGEND_JFD_IDEOLOGY_FREEDOM',					'TXT_KEY_POLICY_BRANCH_FREEDOM',								'POLICY_BRANCH_FREEDOM',					'[ICON_IDEOLOGY_FREEDOM]',					'COLOR_JFD_OVERLAY_YELLOW',					1.0,				1,					1),		
		('OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY_TYPE',		'OVERLAY_LEGEND_JFD_IDEOLOGY_NEUTRALITY',				'TXT_KEY_POLICY_BRANCH_JFD_NEUTRALITY',							'POLICY_BRANCH_JFD_NEUTRALITY',				'[ICON_IDEOLOGY_JFD_NEUTRALITY]',			'COLOR_JFD_OVERLAY_WHITE',					1.0,				1,					0),		
		('OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY_TYPE',		'OVERLAY_LEGEND_JFD_IDEOLOGY_ORDER',					'TXT_KEY_POLICY_BRANCH_ORDER',									'POLICY_BRANCH_ORDER',						'[ICON_IDEOLOGY_ORDER]',					'COLOR_JFD_OVERLAY_RED',					1.0,				1,					1),				
		('OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY_TYPE',		'OVERLAY_LEGEND_JFD_IDEOLOGY_SPIRIT',					'TXT_KEY_POLICY_BRANCH_JFD_SPIRIT',								'POLICY_BRANCH_JFD_SPIRIT',					'[ICON_IDEOLOGY_JFD_SPIRIT]',				'COLOR_JFD_OVERLAY_BLUE',					1.0,				1,					0);						
			
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerIdeologyNOT,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)						
VALUES	('OVERLAY_MAP_JFD_PLAYERS_IDEOLOGY_TYPE',		'OVERLAY_LEGEND_JFD_IDEOLOGY_NOT',						'TXT_KEY_LEGEND_JFD_IDEOLOGY_NOT',								1,											'[ICON_LEGEND_NO_IDEOLOGY]',				'COLOR_JFD_OVERLAY_GREY',					1.0,				1,					1);	
-----------------------------------
--PLAYERS: RELIGION
-----------------------------------
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												UseReligionName,												IsPlayerReligionType,						UseReligionIcon,							UseReligionColor,							ColorAlpha,			DefaultChecked,		ShowInLegendAlways)		
VALUES	('OVERLAY_MAP_JFD_PLAYERS_RELIGION_TYPE',		'OVERLAY_LEGEND_JFD_RELIGION_TYPE',						1,																1,											1,											1,											1.0,				1,					1);	
-----------------------------------
--PLAYERS: TECHNOLOGY
-----------------------------------
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerTechnologyPos,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_STATUS',	'OVERLAY_LEGEND_JFD_TECHNOLOGY_PROGRESSING',			'TXT_KEY_LEGEND_JFD_TECHNOLOGY_PROGRESSING',					1,											'[ICON_SCIENCE_POS]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					1);							

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerTechnologyNeg,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_STATUS',	'OVERLAY_LEGEND_JFD_TECHNOLOGY_STALLED',				'TXT_KEY_LEGEND_JFD_TECHNOLOGY_STALLED',						1,											'[ICON_SCIENCE_EMP]',						'COLOR_JFD_OVERLAY_RED',					1.0,				1,					1);							

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerEraType,							IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)									
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_ANCIENT',						'TXT_KEY_LEGEND_JFD_ERA_ANCIENT',								'ERA_ANCIENT',								'[ICON_LEGEND_ERA_1]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_CLASSICAL',						'TXT_KEY_LEGEND_JFD_ERA_CLASSICAL',								'ERA_CLASSICAL',							'[ICON_LEGEND_ERA_2]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0),				
		('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_MEDIEVAL',						'TXT_KEY_LEGEND_JFD_ERA_MEDIEVAL',								'ERA_MEDIEVAL',								'[ICON_LEGEND_ERA_3]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0),				
		('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_RENAISSANCE',					'TXT_KEY_LEGEND_JFD_ERA_RENAISSANCE',							'ERE_RENAISSANCE',							'[ICON_LEGEND_ERA_4]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_ENLIGHTENMENT',					'TXT_KEY_LEGEND_JFD_ERA_ENLIGHTENMENT',							'ERA_ENLIGHTENMENT',						'[ICON_LEGEND_ERA_5]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_INDUSTRIAL',					'TXT_KEY_LEGEND_JFD_ERA_INDUSTRIAL',							'ERA_INDUSTRIAL',							'[ICON_LEGEND_ERA_6]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0),			
		('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_MODERN',						'TXT_KEY_LEGEND_JFD_ERA_MODERN',								'ERA_MODERN',								'[ICON_LEGEND_ERA_7]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0),				
		('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_POSTMODERN',					'TXT_KEY_LEGEND_JFD_ERA_POSTMODERN',							'ERA_POSTMODERN',							'[ICON_LEGEND_ERA_8]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0),				
		('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA',		'OVERLAY_LEGEND_JFD_ERA_FUTURE',						'TXT_KEY_LEGEND_JFD_ERA_FUTURE',								'ERA_FUTURE',								'[ICON_LEGEND_ERA_9]',						'COLOR_JFD_OVERLAY_YIELD_SCIENCE',			1.0,				1,					0);			
-----------------------------------
--PLAYERS: TREASURY
-----------------------------------
INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerTreasuryPos,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TREASURY_STATUS',		'OVERLAY_LEGEND_JFD_TREASURY_PROSPERING',				'TXT_KEY_LEGEND_JFD_TREASURY_PROSPERING',						1,											'[ICON_GOLD_POS]',							'COLOR_JFD_OVERLAY_YIELD_GOLD',				1.0,				1,					1);							

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerTreasuryNeu,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TREASURY_STATUS',		'OVERLAY_LEGEND_JFD_TREASURY_BALANCED',					'TXT_KEY_LEGEND_JFD_TREASURY_BALANCED',							1,											'[ICON_GOLD_NEU]',							'COLOR_JFD_OVERLAY_YIELD_GOLD_2',			1.0,				1,					1);							

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerTreasuryNeg,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TREASURY_STATUS',		'OVERLAY_LEGEND_JFD_TREASURY_DEPLETING',				'TXT_KEY_LEGEND_JFD_TREASURY_DEPLETING',						1,											'[ICON_GOLD_NEG]',							'COLOR_JFD_OVERLAY_YIELD_GOLD_3',			1.0,				1,					1);							

INSERT INTO JFD_OverlayMap_Legends
		(OverlayMapType,								LegendType,												ShortDescription,												IsPlayerTreasuryVNeg,						IconFont,									ColorType,									ColorAlpha,			DefaultChecked,		ShowInLegendAlways)				
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TREASURY_STATUS',		'OVERLAY_LEGEND_JFD_TREASURY_DEPLETED',					'TXT_KEY_LEGEND_JFD_TREASURY_DEPLETED',							1,											'[ICON_GOLD_EMP]',							'COLOR_JFD_OVERLAY_RED',					1.0,				1,					1);							
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMap_Rankings
----------------------------------------------------------------------------------------------------------------------------
-----------------------------------		
--BORDERS
-----------------------------------
INSERT INTO JFD_OverlayMap_Rankings
		(OverlayMapType,								Description,												Help,														IsNumLand,				IconFont,							ColorType,								ColorTypeAlt,				ColorTypeAltEqualToValue)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_BORDERS_RANK',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_BORDERS_RANK_DESC',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_BORDERS_RANK_HELP',		1,						'[ICON_CULTURE]',					'COLOR_JFD_OVERLAY_YIELD_CULTURE',		'COLOR_JFD_OVERLAY_RED',	0);
-----------------------------------		
--GROWTH
-----------------------------------
INSERT INTO JFD_OverlayMap_Rankings
		(OverlayMapType,								Description,												Help,														IsNumFood,				IconFont,							ColorType,								ColorTypeAlt,				ColorTypeAltEqualToValue)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_GROWTH_RANK',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_GROWTH_RANK_DESC',			'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_GROWTH_RANK_HELP',			1,						'[ICON_FOOD]',						'COLOR_JFD_OVERLAY_YIELD_FOOD',			'COLOR_JFD_OVERLAY_RED',	0);
-----------------------------------		
--HAPPINESS
-----------------------------------
INSERT INTO JFD_OverlayMap_Rankings
		(OverlayMapType,								Description,												Help,														IsNumHappiness,			IconFont,							ColorType,								ColorTypeAlt,				ColorTypeAltEqualToValue)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_RANK',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_RANK_DESC',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_HAPPINESS_RANK_HELP',		1,						'[ICON_HAPPINESS_1]',				'COLOR_JFD_OVERLAY_HAPPINESS',			'COLOR_JFD_OVERLAY_RED',	0);
-----------------------------------		
--INDUSTRY
-----------------------------------
INSERT INTO JFD_OverlayMap_Rankings
		(OverlayMapType,								Description,												Help,														IsNumProduction,		IconFont,							ColorType,								ColorTypeAlt,				ColorTypeAltEqualToValue)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_INDUSTRY_RANK',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_INDUSTRY_RANK_DESC',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_INDUSTRY_RANK_HELP',		1,						'[ICON_PRODUCTION]',				'COLOR_JFD_OVERLAY_YIELD_PRODUTION',	'COLOR_JFD_OVERLAY_RED',	0);
-----------------------------------		
--MILITARY
-----------------------------------
INSERT INTO JFD_OverlayMap_Rankings
		(OverlayMapType,								Description,												Help,														IsNumMilStrength,		IconFont,							ColorType,								ColorTypeAlt,				ColorTypeAltEqualToValue)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_MILITARY_RANK',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_MILITARY_RANK_DESC',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_MILITARY_RANK_HELP',		1,						'[ICON_STRENGTH]',					'COLOR_JFD_OVERLAY_UNIT_STRENGTH',		'COLOR_JFD_OVERLAY_RED',	0);
-----------------------------------		
--POPULATION
-----------------------------------
INSERT INTO JFD_OverlayMap_Rankings
		(OverlayMapType,								Description,												Help,														IsNumPopulation,		IconFont,							ColorType,								ColorTypeAlt,				ColorTypeAltEqualToValue)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_POPULATION_RANK',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_POPULATION_RANK_DESC',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_POPULATION_RANK_HELP',		1,						'[ICON_CITIZEN]',					'COLOR_JFD_OVERLAY_YIELD_FOOD_3',		'COLOR_JFD_OVERLAY_RED',	0);
-----------------------------------		
--TECHNOLOGY
-----------------------------------
INSERT INTO JFD_OverlayMap_Rankings
		(OverlayMapType,								Description,												Help,														IsNumTechs,				IconFont,							ColorType,								ColorTypeAlt,				ColorTypeAltEqualToValue)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_RANK',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_RANK_DESC',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_RANK_HELP',		1,						'[ICON_RESEARCH]',					'COLOR_JFD_OVERLAY_YIELD_SCIENCE',		'COLOR_JFD_OVERLAY_RED',	0);
-----------------------------------		
--TREASURY
-----------------------------------
INSERT INTO JFD_OverlayMap_Rankings
		(OverlayMapType,								Description,												Help,														IsNumGold,				IconFont,							ColorType,								ColorTypeAlt,				ColorTypeAltEqualToValue)
VALUES	('OVERLAY_MAP_JFD_PLAYERS_TREASURY_RANK',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TREASURY_RANK_DESC',		'TXT_KEY_OVERLAY_MAP_JFD_PLAYERS_TREASURY_RANK_HELP',		1,						'[ICON_GOLD]',						'COLOR_JFD_OVERLAY_YIELD_GOLD',			'COLOR_JFD_OVERLAY_RED',	0);
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMap_Options
----------------------------------------------------------------------------------------------------------------------------
INSERT INTO JFD_OverlayMap_Options	
		(OverlayMapType,	OptionType,									ShortDescription,										Help,														DefaultChecked,		IsValid)
SELECT	Type,				'OVERLAY_JFD_OPTION_EXCLUDE_INACTIVE',		'TXT_KEY_OVERLAY_JFD_OPTION_EXCLUDE_INACTIVE',			'TXT_KEY_OVERLAY_JFD_OPTION_EXCLUDE_INACTIVE_HELP',			0,					1
FROM JFD_OverlayMaps WHERE ClassType = 'OVERLAY_CLASS_JFD_PLAYERS';

INSERT INTO JFD_OverlayMap_Options	
		(OverlayMapType,	OptionType,									ShortDescription,										Help,														DefaultChecked,		IsValid)
SELECT	Type,				'OVERLAY_JFD_OPTION_EXCLUDE_WATER_TILES',	'TXT_KEY_OVERLAY_JFD_OPTION_EXCLUDE_PILLAGED_TILES',	'TXT_KEY_OVERLAY_JFD_OPTION_EXCLUDE_PILLAGED_TILES_HELP',	1,					1
FROM JFD_OverlayMaps WHERE ClassType = 'OVERLAY_CLASS_JFD_PLAYERS';

INSERT INTO JFD_OverlayMap_Options	
		(OverlayMapType,	OptionType,									ShortDescription,										Help,														DefaultChecked,		IsValid)
SELECT	Type,				'OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS',	'TXT_KEY_OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS',		'TXT_KEY_OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS_HELP',		0,					1
FROM JFD_OverlayMaps WHERE ClassType = 'OVERLAY_CLASS_JFD_PLAYERS'
AND Type IN ('OVERLAY_MAP_JFD_PLAYERS_BORDERS_OWNER', 'OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY', 'OVERLAY_MAP_JFD_PLAYERS_TECHNOLOGY_ERA');

INSERT INTO JFD_OverlayMap_Options	
		(OverlayMapType,	OptionType,									ShortDescription,										Help,														DefaultChecked,		IsValid)
SELECT	Type,				'OVERLAY_JFD_OPTION_SHOW_CITIES',			'TXT_KEY_OVERLAY_JFD_OPTION_SHOW_CITIES',				'TXT_KEY_OVERLAY_JFD_OPTION_SHOW_CITIES_HELP',				1,					1
FROM JFD_OverlayMaps WHERE ClassType = 'OVERLAY_CLASS_JFD_PLAYERS';

INSERT INTO JFD_OverlayMap_Options	
		(OverlayMapType,	OptionType,									ShortDescription,										Help,														DefaultChecked,		IsValid)
SELECT	Type,				'OVERLAY_JFD_OPTION_SHOW_STARTS',			'TXT_KEY_OVERLAY_JFD_OPTION_SHOW_STARTS',				'TXT_KEY_OVERLAY_JFD_OPTION_SHOW_STARTS_HELP',				0,					1
FROM JFD_OverlayMaps WHERE ClassType = 'OVERLAY_CLASS_JFD_PLAYERS';

INSERT INTO JFD_OverlayMap_Options	
		(OverlayMapType,	OptionType,									ShortDescription,										Help,														DefaultChecked,		IsValid)
SELECT	Type,				'OVERLAY_JFD_OPTION_SHOW_TERRAIN',			'TXT_KEY_OVERLAY_JFD_OPTION_SHOW_TERRAIN',				'TXT_KEY_OVERLAY_JFD_OPTION_SHOW_TERRAIN_HELP',				0,					1
FROM JFD_OverlayMaps WHERE ClassType = 'OVERLAY_CLASS_JFD_PLAYERS';
--==========================================================================================================================
--==========================================================================================================================