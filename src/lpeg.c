#include "luagrapheme.h"

int luaopen_luagrapheme_lpeg(lua_State *L)
{
    // If we named _lpeg.lua simply lpeg.lua, it could be loaded instead
    // of LPeg during development if src is in the package.path.
    // To work around this, we call it _lpeg.lua and use this shim to
    // allow users to load it as "luagrapheme.lpeg".

    lua_getglobal(L, "require");
    lua_pushliteral(L, "luagrapheme._lpeg");
    lua_call(L, 1, 1);

    return 1;
}
