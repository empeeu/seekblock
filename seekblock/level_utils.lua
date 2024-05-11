function init(pos1, pos2)
    local manip = minetest.get_voxel_manip()
    local emerged_pos1, emerged_pos2 = manip:read_from_map(pos1, pos2)
    local area = VoxelArea:new({ MinEdge = emerged_pos1, MaxEdge = emerged_pos2 })
    return manip, area
end

function get_seekblock_extents(pos, size)
    local p1 = {x=pos.x-size, y=pos.y, z=pos.z-size}
    local p2 = {x=pos.x+size, y=pos.y+size, z=pos.z+size}
    return p1, p2
end

function get_voxel_center(pos)
    return {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.5),z=math.floor(pos.z+0.5)}
end

function clean_seekblock(name, pos, size, winner)
    if seekblock_storage:get_string(name) == nil then
        -- This game was already cleaned up -- just return
        return
    end
    -- local pos = registered_seekblock_games[name].pos
    -- local size = registered_seekblock_games[name].size

    seekblock_storage:set_string(name, "")
    local fallblock = minetest.get_content_id("seekblock:fall")
    local hideblock = minetest.get_content_id("seekblock:hide")
    local wallblock = minetest.get_content_id("seekblock:wall")
    local airblock = minetest.get_content_id("air")

    local p1, p2
    p1, p2 = get_seekblock_extents(pos, size)
    local vm, a = init(p1, p2)

    local data = vm:get_data()

    for x = p1.x, p2.x do
        for y = p1.y - 1, p2.y do  -- -1 to clean up the floor as well
            for z = p1.z, p2.z do
                local idx = a:index(x, y, z)
                local thisblock = data[idx]
                if thisblock == fallblock or thisblock == wallblock or thisblock == hideblock then
                    data[idx] = airblock
                end
            end
        end
    end

    vm:set_data(data)
    -- vm:set_param2_data(color_data)
    vm:write_to_map()
    vm:update_map()
    minetest.log("action", "DONE CLEANING LEVEL!~!")

    if winner == nil then
        return
    end

    local particle_spawner = {
        amount=300, 
        time=5,
        exptime=5,
        -- collisiondetection=true,
        acc={x=0, y=0.1, z=0},
        bounce=0.5,
        jitter=.1,
        vel={x=0, y=1, z=0},
        radius=.6,
        attached=winner,
        texture="palette1.png",
        glow=10,
    }
    minetest.add_particlespawner(particle_spawner)

end

minetest.register_chatcommand("seekblockclear", {
    params = "",
    description = "Atest level",
    -- privs = {}
    func = function(name, params)
        if seekblock_storage:get_string(name) == nil then
            -- no active games, doing nothing
            return
        end
        local meta_table = minetest.deserialize(seekblock_storage:get_string(name))
        minetest.log('action', name.."  "..seekblock_storage:get_string(name))
        if meta_table == nil then
            seekblock_storage:set_string(name, "")
            return
        end
        clean_seekblock(name, meta_table.pos, meta_table.size)
    end
}
)