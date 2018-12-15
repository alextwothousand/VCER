forward LobbyMapping();
public LobbyMapping() {
	new tmpobjid;
	tmpobjid = CreateDynamicObject(19353, 242.2965, 66.2477, 1003.6406, 0.0000, 0.0000, 0.0000); //wall001
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
	
	tmpobjid = CreateDynamicObject(19353, 246.5264, 72.4376, 1003.6406, 0.0000, 0.0000, 90.0000); //wall001
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
	
	tmpobjid = CreateDynamicObject(19353, 250.5165, 63.2177, 1003.6406, 0.0000, 0.0000, 0.0000); //wall001
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
	
	tmpobjid = CreateDynamicObject(3077, 246.3394, 72.2279, 1002.0538, 0.0000, 0.0000, 0.0000); //nf_blackboard
	
	tmpobjid = CreateDynamicObject(3077, 246.3394, 72.2279, 1002.0538, 0.0000, 0.0000, 0.0000); //nf_blackboard
	SetDynamicObjectMaterialText(tmpobjid, 0, "Vice City Emergency Responders", OBJECT_MATERIAL_SIZE_256x128, "Rage Italic", 24, 0, COLOR_PINK, 0x00000000, 0);
	return 1;
}

forward BugFixMapping();
public BugFixMapping() {
	new tmpobjid;
	CreateDynamicObject(19313, 4550.9482, 69.8443, 9.6169, 0.0000, 0.0000, 88.8000); //a51fensin
	CreateDynamicObject(1358, 4549.5156, 71.9716, 10.7315, 0.0000, 0.0000, -95.9999); //CJ_SKIP_Rubbish
	CreateDynamicObject(2672, 4547.8173, 72.6269, 9.8086, 0.0000, 0.0000, -19.4999); //PROC_RUBBISH_4

	CreateDynamicObject(19313, 4550.9482, 69.8442, 9.6169, 0.0000, 0.0000, 88.8000); //a51fensin
	CreateDynamicObject(1358, 4549.5156, 71.9716, 10.7314, 0.0000, 0.0000, -95.9999); //CJ_SKIP_Rubbish
	CreateDynamicObject(2672, 4547.8173, 72.6268, 9.8086, 0.0000, 0.0000, -19.4999); //PROC_RUBBISH_4

	tmpobjid = CreateDynamicObject(19862, 3827.8110, -1580.6441, 12.9372, 0.0000, 0.0000, 97.8000); //MIHouse1GarageDoor2
	SetDynamicObjectMaterial(tmpobjid, 0, 6522, "cuntclub_law2", "marinawindow1_256", 0x00000000);

	tmpobjid = CreateDynamicObject(19446, 5023.0937, -2278.4426, 13.1159, 0.0998, 0.0000, 84.9999); //wall086
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);

	tmpobjid = CreateDynamicObject(19862, 3827.0905, -1574.8435, 12.9772, 0.0000, 0.0000, 97.8000); //MIHouse1GarageDoor2
	SetDynamicObjectMaterial(tmpobjid, 0, 6522, "cuntclub_law2", "marinawindow1_256", 0x00000000);

	tmpobjid = CreateDynamicObject(19862, 3826.3142, -1568.9454, 12.9273, 0.0000, 0.0000, 100.5999); //MIHouse1GarageDoor2
	SetDynamicObjectMaterial(tmpobjid, 0, 6522, "cuntclub_law2", "marinawindow1_256", 0x00000000);

	tmpobjid = CreateDynamicObject(19862, 3828.9199, -1558.3072, 12.9273, 0.0000, 0.0000, 4.3000); //MIHouse1GarageDoor2
	SetDynamicObjectMaterial(tmpobjid, 0, 6522, "cuntclub_law2", "marinawindow1_256", 0x00000000);

	tmpobjid = CreateDynamicObject(19862, 3825.2028, -1563.0172, 12.8472, 0.0000, 0.0000, 100.5999); //MIHouse1GarageDoor2
	SetDynamicObjectMaterial(tmpobjid, 0, 6522, "cuntclub_law2", "marinawindow1_256", 0x00000000);

	tmpobjid = CreateDynamicObject(19862, 3832.3596, -1558.0291, 12.9673, 0.0000, 0.0000, 5.3000); //MIHouse1GarageDoor2
	SetDynamicObjectMaterial(tmpobjid, 0, 6522, "cuntclub_law2", "marinawindow1_256", 0x00000000);

	tmpobjid = CreateDynamicObject(7922, 3826.2631, -1559.8817, 11.7849, 0.0000, 0.0000, -37.8000); //vgwstnewall6905
	SetDynamicObjectMaterial(tmpobjid, 0, 6522, "cuntclub_law2", "marinawindow1_256", 0x00000000);
	return 1;
}

forward BugFixMappingTwo();
public BugFixMappingTwo() {
	CreateDynamicObject(19428, 5030.0278, -2282.7163, 13.2753, 0.0000, 0.0000, 84.9000); //wall068
	CreateDynamicObject(19428, 5028.4248, -2282.5734, 13.2753, 0.0000, 0.0000, 84.9000); //wall068
	CreateDynamicObject(19428, 5030.0278, -2282.7163, 13.2753, 0.0000, 0.0000, 84.9000); //wall068
	CreateDynamicObject(19428, 5028.4248, -2282.5734, 13.2753, 0.0000, 0.0000, 84.9000); //wall068
	CreateDynamicObject(19428, 5027.7641, -2281.5791, 13.2753, 0.0000, 0.0000, 174.4001); //wall068
	CreateDynamicObject(19428, 5027.9184, -2280.0004, 13.2753, 0.0000, 0.0000, 174.4001); //wall068
	CreateDynamicObject(19428, 5027.9428, -2279.7470, 13.2753, 0.0000, 0.0000, 174.4001); //wall068
	CreateDynamicObject(19446, 5023.1118, -2278.4807, 12.8932, 0.0000, 0.0000, 85.2999); //wall086
	return 1;
}

forward StadiumFix();
public StadiumFix() {
	new tmpobjid;
	tmpobjid = CreateDynamicObject(19912, 3945.1901, 437.6613, 9.9596, 0.0000, 0.0000, 0.0000); //SAMPMetalGate1
	SetDynamicObjectMaterialText(tmpobjid, 0, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 1, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 2, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateDynamicObject(971, 3942.6726, 451.5535, 8.1912, 0.0000, 90.1999, 0.0000); //subwaygate
	SetDynamicObjectMaterialText(tmpobjid, 0, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 1, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 2, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 3, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 4, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateDynamicObject(19912, 3939.4067, 451.6198, 9.9396, 0.0000, 0.0000, 90.1000); //SAMPMetalGate1
	SetDynamicObjectMaterialText(tmpobjid, 0, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 1, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 2, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateDynamicObject(19788, 3933.6140, 430.1616, 8.0355, 0.0000, -89.2000, 0.0000); //15x15RoadCorner1
	SetDynamicObjectMaterialText(tmpobjid, 0, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 1, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 0, "Example Text",  OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateDynamicObject(19912, 3939.3625, 440.2398, 9.9396, 0.0000, 0.0000, 90.1000); //SAMPMetalGate1
	SetDynamicObjectMaterialText(tmpobjid, 0, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 1, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 2, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 3, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetDynamicObjectMaterialText(tmpobjid, 4, "Example Text", OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0xFFFFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(5797, 3946.2243, 380.1224, 11.8502, 0.0000, 90.0000, 0.0999); //road_lawn21
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "-", 1, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "-", 2, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(5797, 3946.2297, 427.8327, 8.1302, 0.0000, 90.0000, 0.0999); //road_lawn21
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "-", 1, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "-", 2, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3939.4897, 319.0641, 8.1856, -90.1999, 94.7999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(5797, 3946.1467, 334.2622, 11.8502, 0.0000, 90.0000, 0.0999); //road_lawn21
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "-", 1, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "-", 2, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(5797, 3909.2612, 426.4035, 12.2602, 0.0000, 90.0000, 89.9001); //road_lawn21
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "-", 1, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "Example Text", 2, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3939.4829, 322.5541, 8.1866, -90.1999, 94.7999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3933.6928, 333.1140, 8.1696, -90.1999, 94.7999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3939.4965, 315.5643, 8.1846, -90.1999, 94.7999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3945.2434, 333.9996, 7.0996, 0.0000, 90.0000, 0.0000); //wall086
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3933.7067, 326.0941, 8.1676, -90.1999, 94.7999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3945.2434, 324.3795, 7.0996, 0.0000, 90.0000, 0.0000); //wall086
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3935.4514, 324.4125, 8.1732, -90.1999, 4.6999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3933.6855, 336.6038, 8.1707, -90.1999, 94.7999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3939.5026, 312.1743, 8.1836, -90.1999, 94.7999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3933.6997, 329.5740, 8.1686, -90.1999, 94.7999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(5797, 3909.2404, 335.6215, 11.8502, 0.0000, 90.0000, -89.9999); //road_lawn21
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "-", 1, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	SetObjectMaterialText(tmpobjid, "Example Text", 2, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3937.6733, 324.4203, 8.1809, -90.1999, 4.6999, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "Example Text", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3944.2395, 310.4954, 8.1996, -90.1999, 4.9000, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);

	tmpobjid = CreateObject(19446, 3941.2072, 310.4954, 8.1890, -90.1999, 4.9000, 94.8999); //wall086
	SetObjectMaterialText(tmpobjid, "-", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 24, 1, 0x00FFFFFF, 0x00000000, 0);
	return 1;
}

forward InitializeMapping();
public InitializeMapping()
{
	LobbyMapping();
	BugFixMapping();
	BugFixMappingTwo();
	StadiumFix();
	return 1;
}