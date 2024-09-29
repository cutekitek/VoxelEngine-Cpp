function place_structures(x, z, w, d, seed, hmap)
    local placements = {}
    for i=1,10 do
        local sx = math.random() * w
        local sz = math.random() * d
        local sy = math.random() * 128
        if sy < hmap:at(sx, sz) * 256 - 6 then
            table.insert(placements, {"coal_ore0", {sx, sy, sz}, math.random()*4})
        end
    end
    return placements
end

function generate_heightmap(x, y, w, h, seed, s)
    local umap = Heightmap(w, h)
    local vmap = Heightmap(w, h)
    umap.noiseSeed = seed
    vmap.noiseSeed = seed
    vmap:noise({x+521, y+70}, 0.1*s, 3, 25.8)
    vmap:noise({x+95, y+246}, 0.15*s, 3, 25.8)

    local map = Heightmap(w, h)
    map.noiseSeed = seed
    map:noise({x, y}, 0.8*s, 4, 0.02)
    map:cellnoise({x, y}, 0.1*s, 3, 0.3, umap, vmap)
    map:add(0.4)

    local rivermap = Heightmap(w, h)
    rivermap.noiseSeed = seed
    rivermap:noise({x+21, y+12}, 0.1*s, 4)
    rivermap:abs()
    rivermap:mul(2.0)
    rivermap:pow(0.15)
    rivermap:max(0.3)
    map:add(0.3)
    map:mul(rivermap)
    return map
end

function generate_biome_parameters(x, y, w, h, seed, s)
    local tempmap = Heightmap(w, h)
    tempmap.noiseSeed = seed + 5324
    tempmap:noise({x, y}, 0.04*s, 6)
    local hummap = Heightmap(w, h)
    hummap.noiseSeed = seed + 953
    hummap:noise({x, y}, 0.04*s, 6)
    tempmap:pow(3)
    hummap:pow(3)
    return tempmap, hummap
end
