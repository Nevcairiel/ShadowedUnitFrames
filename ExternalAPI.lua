--[[
	API overrides from external addons that augment the data missing in the Classic API
]]
ShadowUF = select(2, ...)
ShadowUF.API = {}

-- Threat colors
function ShadowUF.API.GetThreatStatusColor(state)
	if( state == 3 ) then
		return 1, 0, 0
	elseif( state == 2 ) then
		return 1, 0.6, 0
	elseif( state == 1 ) then
		return 1, 1, 0.47
	else
		return 0.69, 0.69, 0.69
	end
end
