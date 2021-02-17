if( GetLocale() ~= "koKR" ) then return end
local L = {}
--@localization(locale="koKR", format="lua_additive_table", handle-unlocalized="ignore")@
local ShadowUF = select(2, ...)
ShadowUF.L = setmetatable(L, {__index = ShadowUF.L})
