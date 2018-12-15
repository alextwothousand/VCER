//#include <YSI\y_hooks>

/*
	Notice:
	
	- Use "Rage Italic" as the font
*/
forward CreateMapping();
public CreateMapping() {
	
	tmpobjid = CreateObject(19353, 242.2965, 66.2477, 1003.6406, 0.0000, 0.0000, 0.0000); //wall001
	SetObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
	
	tmpobjid = CreateObject(19353, 246.5264, 72.4376, 1003.6406, 0.0000, 0.0000, 90.0000); //wall001
	SetObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
	
	tmpobjid = CreateObject(19353, 250.5165, 63.2177, 1003.6406, 0.0000, 0.0000, 0.0000); //wall001
	SetObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
	
	tmpobjid = CreateObject(3077, 246.3394, 72.2279, 1002.0538, 0.0000, 0.0000, 0.0000); //nf_blackboard
	
	tmpobjid = CreateObject(3077, 246.3394, 72.2279, 1002.0538, 0.0000, 0.0000, 0.0000); //nf_blackboard
	SetObjectMaterialText(tmpobjid, "Vice City Emergency Responders", 0, OBJECT_MATERIAL_SIZE_256x128, "Rage Italic", 24, 0, COLOR_PINK, 0x00000000, 0);
	return 1;
} //Old font is called Small Fonts
