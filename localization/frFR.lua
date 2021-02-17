if( GetLocale() ~= "frFR" ) then return end
local L = {}
--@localization(locale="frFR", format="lua_additive_table", handle-unlocalized="ignore")@
local ShadowUF = select(2, ...)
ShadowUF.L = setmetatable(L, {__index = ShadowUF.L})
