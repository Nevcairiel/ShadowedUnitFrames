if( GetLocale() ~= "esES" ) then return end
local L = {}
--@localization(locale="esES", format="lua_additive_table", handle-unlocalized="ignore")@
local ShadowUF = select(2, ...)
ShadowUF.L = setmetatable(L, {__index = ShadowUF.L})
