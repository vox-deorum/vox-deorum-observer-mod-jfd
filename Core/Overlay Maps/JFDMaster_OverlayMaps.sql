--==========================================================================================================================
-- MAPS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMapClasses
----------------------------------------------------------------------------------------------------------------------------	
CREATE TABLE IF NOT EXISTS 
JFD_OverlayMapClasses(
	ID  									integer 							   primary key autoincrement,
	Type 									text												default null,
	ShortDescription						text												default null,
	Help									text												default null,
	OnlyValidActivePlayer					boolean												default 0,
	OnlyValidMajorPlayers					boolean												default 0,
	OnlyValidMinorPlayers					boolean												default 0);
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMapFilters
----------------------------------------------------------------------------------------------------------------------------	
CREATE TABLE IF NOT EXISTS 
JFD_OverlayMapFilters(
	ID  									integer 							   primary key autoincrement,
	Type 									text												default null,
	ShortDescription						text												default null,
	Help									text												default null);
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMapOptions
----------------------------------------------------------------------------------------------------------------------------	
CREATE TABLE IF NOT EXISTS 
JFD_OverlayMapOptions(
	ID  									integer 							   primary key autoincrement,
	Type 									text												default null,
	ShortDescription						text												default null,
	Help									text												default null);
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMaps
----------------------------------------------------------------------------------------------------------------------------	
CREATE TABLE IF NOT EXISTS 
JFD_OverlayMaps(
	ID  									integer 							   primary key autoincrement,
	Type 									text												default null,
	ClassType 								text												default null,
	MasterOverlayMapType 					text												default null,
	ShortDescription						text												default null,
	Help									text												default null,
	DontShowLegend							boolean												default 0,
	PopulatePlayers							boolean												default 0,
	PopulateRankings						boolean												default 0,
	PopulateReligions						boolean												default 0,
	IterateTiles							boolean												default 0,
	IteratePlayers							boolean												default 0,
	IteratePlayerCities						boolean												default 0,
	IteratePlayerTiles						boolean												default 0,
	IteratePlayerUnits						boolean												default 0,
	RequiresFilteredPlayer					boolean												default 0,
	RequiresJFDLL							boolean												default 0,
	RequiresToExist							text												default null,
	-----------------------------------
	--PLAYERS
	-----------------------------------
	IsPlayer								boolean												default 0,	
	IsPlayerType							boolean												default 0,	
	IsPlayerBorder							boolean												default 0,
	IsPlayerBorderRank						boolean												default 0,
	IsPlayerCultureType						boolean												default 0,
	IsPlayerSubCultureType					boolean												default 0,
	IsPlayerGoldenAge						boolean												default 0,
	IsPlayerGovernment						boolean												default 0,
	IsPlayerGovernmentType					boolean												default 0,
	IsPlayerGrowth							boolean												default 0,
	IsPlayerGrowthRank						boolean												default 0,
	IsPlayerHappiness						boolean												default 0,
	IsPlayerHappinessRank					boolean												default 0,
	IsPlayerIdeology						boolean												default 0,
	IsPlayerIdeologyType					boolean												default 0,
	IsPlayerIdeologyPrefType				boolean												default 0,
	IsPlayerIndustryRank					boolean												default 0,
	IsPlayerMilitaryRank					boolean												default 0,
	IsPlayerPolicyBranch					boolean												default 0,
	IsPlayerPolicyBranchType				boolean												default 0,
	IsPlayerPopulationRank					boolean												default 0,
	IsPlayerPublicOpinion					boolean												default 0,
	IsPlayerPublicOpinionType				boolean												default 0,
	IsPlayerReligion						boolean												default 0,
	IsPlayerTechnology						boolean												default 0,
	IsPlayerTechnologyEraType				boolean												default 0,
	IsPlayerTechnologyRank					boolean												default 0,
	IsPlayerTreasury						boolean												default 0,
	IsPlayerTreasuryRank					boolean												default 0,
	-----------------------------------
	--DIPLOMACY
	-----------------------------------
	IsDiplomacyDefensivePact				boolean												default 0,
	IsDiplomacyDOF							boolean												default 0,
	IsDiplomacyEmbassyFrom					boolean												default 0,
	IsDiplomacyEmbassyTo					boolean												default 0,
	IsDiplomacyOpenBordersFrom				boolean												default 0,
	IsDiplomacyOpenBordersTo				boolean												default 0,
	IsDiplomacyResearchAgreement			boolean												default 0,
	IsDiplomacyRelation						boolean												default 0,
	IsDiplomacyWarPeace						boolean												default 0);	
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMap_Options
----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS
JFD_OverlayMap_Options (
    OverlayMapType							text    											default null,
	OptionType								text    											default null,
	ShortDescription						text    											default null,
	Help									text    											default null,
	DefaultChecked							boolean												default 1,
	IsValid									boolean												default 1);
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMap_Legends
----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS
JFD_OverlayMap_Legends (
	LegendType								text    											default null,
	OverlayMapType							text    											default null,
	ShortDescription						text    											default null,
	Help									text    											default null,
	UseFilteredPlayerDescription			boolean												default 0,	
	UseTableDescription						text												default null,	
	UsePlayerDescription					boolean												default 0,	
	UseReligionName							boolean												default 0,	
	-----------------------------------
	IconFont								text    											default null,
	UseFilteredPlayerIcon					boolean												default 0,	
	UsePlayerIcon							boolean												default 0,	
	UseReligionIcon							boolean												default 0,	
	-----------------------------------
	ColorType								text    REFERENCES Colors(Type)						default null,
	ColorAlpha								integer												default 1.0,	
	UseAreaColorType						boolean												default 0,	
	UseFilteredPlayerColor					boolean												default 0,	
	UsePlayerColor							boolean												default 0,	
	UsePlayerColorFallback					boolean												default 0,	
	UsePlayerColorInverted					boolean												default 0,	
	UseRankedColor							boolean												default 0,	
	UseReligionColor						boolean												default 0,	
	-----------------------------------
	DefaultChecked							boolean												default 1,
	ShowInLegend							boolean												default 1,	
	ShowInLegendAlways						boolean												default 1,	
	ShowInLegendOnlyFiltered				boolean												default 0,	
	ShowInLegendOption						text												default null,	
	ShowInLegendOptionNOT					text												default null,	
	-----------------------------------
	--PLAYERS
	-----------------------------------
	IsPlayerBorder							boolean												default 0,
	IsPlayerGoldenAge						boolean												default 0,
	IsPlayerAnarchy							boolean												default 0,
	IsPlayerHappy							boolean												default 0,
	IsPlayerUnhappy							boolean												default 0,
	IsPlayerVeryUnhappy						boolean												default 0,
	IsPlayerSuperUnhappy					boolean												default 0,
	IsPlayerEraType							text    											default null,
	IsPlayerGovernment						boolean												default 0,
	IsPlayerGovernmentNOT					boolean												default 0,
	IsPlayerGovernmentType					text    											default null,
	IsPlayerGrowthPos						boolean												default 0,
	IsPlayerGrowthVPos						boolean												default 0,
	IsPlayerGrowthNeu						boolean												default 0,
	IsPlayerGrowthNeg						boolean												default 0,
	IsPlayerIdeology						boolean												default 0,
	IsPlayerIdeologyNOT						boolean												default 0,
	IsPlayerIdeologyType					text    											default null,
	IsPlayerReligion						boolean												default 0,
	IsPlayerReligionType					boolean												default 0,
	IsPlayerTechnologyPos					boolean												default 0,
	IsPlayerTechnologyNeu					boolean												default 0,
	IsPlayerTechnologyNeg					boolean												default 0,
	IsPlayerTreasuryPos						boolean												default 0,
	IsPlayerTreasuryNeu						boolean												default 0,
	IsPlayerTreasuryNeg						boolean												default 0,
	IsPlayerTreasuryVNeg					boolean												default 0,
	-----------------------------------
	--DIPLOMACY
	-----------------------------------
	IsDiplomacyUs							boolean												default 0,
	IsDiplomacyDefensivePact				boolean												default 0,
	IsDiplomacyDefensivePactNOT				boolean												default 0,
	IsDiplomacyDOF							boolean												default 0,
	IsDiplomacyDOFNOT						boolean												default 0,
	IsDiplomacyEmbassyFrom					boolean												default 0,
	IsDiplomacyEmbassyTo					boolean												default 0,
	IsDiplomacyEmbassyNOT					boolean												default 0,
	IsDiplomacyOpenBordersFrom				boolean												default 0,
	IsDiplomacyOpenBordersTo				boolean												default 0,
	IsDiplomacyOpenBordersNOT				boolean												default 0,
	IsDiplomacyPeace						boolean												default 0,
	IsDiplomacyPeaceForced					boolean												default 0,
	IsDiplomacyRelation						text												default null,
	IsDiplomacyResearchAgreement			boolean												default 0,
	IsDiplomacyResearchAgreementNOT			boolean												default 0,
	IsDiplomacyWar							boolean												default 0);
----------------------------------------------------------------------------------------------------------------------------
-- JFD_OverlayMap_Rankings
----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS
JFD_OverlayMap_Rankings (
    OverlayMapType							text    											default null,
	Description								text    											default null,
	Help									text    											default null,
	IconFont								text    											default null,
	IsNumFood								boolean												default 0,
	IsNumGold								boolean												default 0,
	IsNumHappiness							boolean												default 0,
	IsNumLand								boolean												default 0,
	IsNumMilStrength						boolean												default 0,
	IsNumPopulation							boolean												default 0,
	IsNumProduction							boolean												default 0,
	IsNumTechs								boolean												default 0,
	ColorType								text    											default null,
	ColorTypeAlt							text    											default null,
	ColorTypeAltEqualToValue				integer    											default -1,
	ColorTypeAltGreaterThanValue			integer    											default -1,
	ColorTypeAltGreaterOrEqualToValue		integer    											default -1,
	ColorTypeAltLessThanValue				integer    											default -1,
	ColorTypeAltLessOrEqualToValue			integer    											default -1);
--==========================================================================================================================
--==========================================================================================================================