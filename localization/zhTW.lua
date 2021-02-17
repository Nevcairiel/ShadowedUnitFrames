if( GetLocale() ~= "zhTW" ) then return end
local L = {}
--@localization(locale="zhTW", format="lua_additive_table", handle-unlocalized="ignore")@
local ShadowUF = select(2, ...)
ShadowUF.L = setmetatable(L, {__index = ShadowUF.L})
