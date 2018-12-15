#include <YSI\y_hooks>

hook OnGameModeInit()
{
	AddCharModel(280, 20000, "vcskins/vc_cop/vccop.dff", "vcskins/vc_cop/vccop.txd");

	return 1;
}