local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

inair = true
ready = false
target = -1

ARGS = ARGS or {}
local dropitem = ARGS
if SAVED_DATA.item then
    dropitem.id = item.index(SAVED_DATA.item)
    dropitem.count = SAVED_DATA.count
end

local scale = {1, 1, 1}
local rotation = mat4.rotate({
    math.random(), math.random(), math.random()
}, 360)

function on_save()
    SAVED_DATA.item = item.name(dropitem.id)
    SAVED_DATA.count = dropitem.count
end

do -- setup visuals
    local matrix = mat4.idt()
    local icon = item.icon(dropitem.id)
    if icon:find("^block%-previews%:") then
        local bid = block.index(icon:sub(16))
        model = block.get_model(bid)
        if model == "X" then
            body:set_size(vec3.mul(body:get_size(), {1.0, 0.3, 1.0}))
            rig:set_model(0, "drop-item")
            rig:set_texture("$0", icon)
        else
            if model == "aabb" then
                local rot = block.get_rotation_profile(bid) == "pipe" and 4 or 0
                scale = block.get_hitbox(bid, rot)[2]
                body:set_size(vec3.mul(body:get_size(), {1.0, 0.7, 1.0}))
                vec3.mul(scale, 1.5, scale)
            end
            local textures = block.get_textures(bid)
            for i,t in ipairs(textures) do
                rig:set_texture("$"..tostring(i-1), "blocks:"..textures[i])
            end
        end
    else
        body:set_size(vec3.mul(body:get_size(), {1.0, 0.3, 1.0}))
        rig:set_model(0, "drop-item")
        rig:set_texture("$0", icon)
    end
    mat4.mul(matrix, rotation, matrix)
    mat4.scale(matrix, scale, matrix)
    rig:set_matrix(0, matrix)
end

function on_grounded(force)
    local matrix = mat4.idt()
    mat4.rotate(matrix, {0, 1, 0}, math.random()*360, matrix)
    if model == "aabb" then
        mat4.rotate(matrix, {1, 0, 0}, 90, matrix)
    end
    mat4.scale(matrix, scale, matrix)
    rig:set_matrix(0, matrix)
    inair = false
    ready = true
end

function on_fall()
    inair = true
end

function on_sensor_enter(index, oid)
    local playerentity = player.get_entity(hud.get_player())
    if ready and oid == playerentity and index == 0 then
        entity:despawn()
        inventory.add(player.get_inventory(oid), dropitem.id, dropitem.count)
        audio.play_sound_2d("events/pickup", 0.5, 0.8+math.random()*0.4, "regular")
    end
    if index == 1 and ready and oid == playerentity then
        target = oid
    end
end

function on_sensor_exit(index, oid)
    if oid == target and index == 1 then
        target = -1
    end
end

function on_render()
    if inair then
        local dt = time.delta();

        mat4.rotate(rotation, {0, 1, 0}, 240*dt, rotation)
        mat4.rotate(rotation, {0, 0, 1}, 240*dt, rotation)

        local matrix = mat4.idt()
        mat4.mul(matrix, rotation, matrix)
        mat4.scale(matrix, scale, matrix)
        rig:set_matrix(0, matrix)
    end
end

function on_update()
    if target ~= -1 then
        local dir = vec3.sub(entities.get(target).transform:get_pos(), tsf:get_pos())
        vec3.normalize(dir, dir)
        vec3.mul(dir, 10.0, dir)
        body:set_vel(dir)
    end
end

function on_attacked(attacker, pid)
    body:set_vel({0, 10, 0})
end