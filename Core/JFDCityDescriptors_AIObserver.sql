--==========================================================================================================================
-- CITY DESCRIPTIONS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- JFD_CityDescriptors
----------------------------------------------------------------------------------------------------------------------------		  
INSERT INTO JFD_CityDescriptors
		(Description,									MinPop, MaxPop)
VALUES	('TXT_KEY_JFD_CITY_DESCRIPTOR_HAMLET',			1,		4),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_VILLAGE',			5,		8),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_TOWN',			9,		12),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_MUNICIPALITY',	13,		16),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_CITY',			17,		20),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_METROPOLIS',		21,		24),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_CONURBATION',		25,		28),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_MEGALOPOLIS',		29,		-1);

INSERT INTO JFD_CityDescriptors
		(Adjective,										IsResistance,   IsColony, IsPuppet)
VALUES	('TXT_KEY_JFD_CITY_DESCRIPTOR_DISPUTED',		1,				0,		  0),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_COLONIAL',		0,				1,		  0),
		('TXT_KEY_JFD_CITY_DESCRIPTOR_AUTONOMOUS',		0,				0,		  1);

INSERT INTO JFD_CityDescriptors
		(Adjective,										IsOccupied)
VALUES	('TXT_KEY_JFD_CITY_DESCRIPTOR_OCCUPIED',		1);
--==========================================================================================================================
--==========================================================================================================================