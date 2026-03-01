--==========================================================================================================================
-- GAME OPTIONS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- GameOptions
----------------------------------------------------------------------------------------------------------------------------
INSERT OR REPLACE INTO GameOptions 
		(Type, 												Description,												Help)
VALUES	('GAMEOPTION_JFD_AIOBSERVER_AUTORESOLVE_WC',		'TXT_KEY_GAMEOPTION_JFD_AIOBSERVER_AUTORESOLVE_WC',			'TXT_KEY_GAMEOPTION_JFD_AIOBSERVER_AUTORESOLVE_WC_HELP'),
		--('GAMEOPTION_JFD_AIOBSERVER_ENABLE_CITYDESCS',		'TXT_KEY_GAMEOPTION_JFD_AIOBSERVER_ENABLE_CITYDESCS',		'TXT_KEY_GAMEOPTION_JFD_AIOBSERVER_ENABLE_CITYDESCS_HELP'),
		('GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS',		'TXT_KEY_GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS',		'TXT_KEY_GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS_HELP'),
		('GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS',		'TXT_KEY_GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS',		'TXT_KEY_GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS_HELP');

--UPDATE GameOptions
--SET Default = 1
--WHERE Type IN ('GAMEOPTION_JFD_AIOBSERVER_AUTORESOLVE_WC', 
--'GAMEOPTION_JFD_AIOBSERVER_ENABLE_CITYDESCS', 'GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS',
--'GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS');
--==========================================================================================================================
--==========================================================================================================================