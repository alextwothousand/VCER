//#include <YSI\y_hooks>

forward CreateVCPlayerModels();
public CreateVCPlayerModels()
{
	AddSimpleModel(-1, 19379, -12000, "vcmisc/login/object.dff", "vcmisc/login/vcer.txd");
	AddCharModel(280, 20000, "vcskins/vc_cop/vccop.dff", "vcskins/vc_cop/vccop.txd"); // previously in skins.pwn

	return 1;
}