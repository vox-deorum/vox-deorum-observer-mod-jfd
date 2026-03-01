--==========================================================================================================================
-- CUSTOM MOD OPTIONS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- CustomModOptions
----------------------------------------------------------------------------------------------------------------------------	
CREATE TABLE IF NOT EXISTS CustomModOptions(Name Text, Value INTEGER, Class INTEGER, DbUpdates INTEGER);

INSERT OR REPLACE INTO CustomModOptions(Name, Value) VALUES('API_EXTENSIONS', 1);
INSERT OR REPLACE INTO CustomModOptions(Name, Value) VALUES('API_LUA_EXTENSIONS', 1);
--==========================================================================================================================
-- CITY DESCRIPTIONS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- JFD_CityDescriptors
----------------------------------------------------------------------------------------------------------------------------		  
CREATE TABLE IF NOT EXISTS 
	JFD_CityDescriptors (
	Description								text 												default null,
	Adjective								text 												default null,
	MinPop									integer												default 0,
	MaxPop									integer												default 0,
	IsResistance							boolean												default 0,
	IsColony								boolean												default 0,
	IsPuppet								boolean												default 0,
	IsOccupied								boolean												default 0,
	PrereqCiv								text												default null);	
--==========================================================================================================================
-- MINI MAP OVERLAYS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- JFD_MinimapOverlays
----------------------------------------------------------------------------------------------------------------------------		  
CREATE TABLE IF NOT EXISTS 
	JFD_MinimapOverlays (
	ID  									integer 							   primary key autoincrement,
	Type 									text												default null,
	Description								text 												default null,
	IsDefault								boolean												default 0,
	IsCultureTypes							boolean												default 0,
	IsEras									boolean												default 0,
	IsFactions								boolean												default 0,
	IsGovernments							boolean												default 0,
	IsIdeologies							boolean												default 0,
	IsRelations								boolean												default 0,
	IsReligions								boolean												default 0,
	IsStability								boolean												default 0);	
----------------------------------------------------------------------------------------------------------------------------
-- JFD_MinimapOverlay_Legends
----------------------------------------------------------------------------------------------------------------------------		  
CREATE TABLE IF NOT EXISTS 
	JFD_MinimapOverlay_Legends (
	LegendType 								text												default null,
	MinimapOverlayType 						text												default null,
	Description								text 												default null,
	FontIcon								text 												default null,
	UseFilterPlayerIcon						boolean												default 0,
	ColorType								text 												default null,
	UseFilterPlayerColor					boolean												default 0,
	IsPlayer								boolean												default 0,
	IsType									boolean												default 0,
	IsTypeRequired							boolean												default 0);	
--==========================================================================================================================
-- POLICY BRANCHES
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- PolicyBranchTypes
----------------------------------------------------------------------------------------------------------------------------
ALTER TABLE PolicyBranchTypes ADD TitleShort text default null;
--==========================================================================================================================
-- RELIGIONS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- Religion_MapColors
----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS
Religion_MapColors (
    ReligionType							text    											default null,
	ColorType								text    REFERENCES Colors(Type)						default null);
--==========================================================================================================================
--==========================================================================================================================