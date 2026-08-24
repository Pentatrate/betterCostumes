-- forwards compat
if type(mod.config.liveRealCostumes) ~= "string" then
	mod.config.liveRealCostumes = mod.config.liveRealCostumes and "parallel" or "never"
end
