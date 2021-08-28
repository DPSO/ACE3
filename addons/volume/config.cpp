#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_common"};
        author = ECSTRING(common,ACETeam);
        authors[] = {"Kingsley"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };

    class XADDON: ADDON {};
};

#include "CfgEventHandlers.hpp"
#include "ACE_Settings.hpp"
