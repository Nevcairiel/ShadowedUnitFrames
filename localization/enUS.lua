local ShadowUF = select(2, ...)
local L = {}
--@localization(locale="enUS", format="lua_additive_table")@

ShadowUF.L = L
--@debug@
ShadowUF.L = setmetatable(ShadowUF.L, {
	__index = function(tbl, value)
		rawset(tbl, value, value)
		return value
	end,
})
--@end-debug@
