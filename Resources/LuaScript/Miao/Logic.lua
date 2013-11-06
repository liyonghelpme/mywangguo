Logic = {}
Logic.resource = {silver=0, food=0, wood=0, stone=0}
function doGain(r)
    for k, v in pairs(r) do
        Logic.resource[k] = Logic.resource[k]+v
    end
end

