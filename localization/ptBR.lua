if( GetLocale() ~= "ptBR" ) then return end
local L = {}
--@localization(locale="ptBR", format="lua_additive_table", handle-unlocalized="ignore")@
local ShadowUF = select(2, ...)
ShadowUF.L = setmetatable(L, {__index = ShadowUF.L})
