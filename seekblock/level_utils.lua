function init(pos1, pos2)
    -- Function for initializing the voxel manipulator used to add blocks
    local manip = minetest.get_voxel_manip()
    local emerged_pos1, emerged_pos2 = manip:read_from_map(pos1, pos2)
    local area = VoxelArea:new({ MinEdge = emerged_pos1, MaxEdge = emerged_pos2 })
    return manip, area
end

function get_seekblock_extents(pos, size)
    -- Get the extents of the game area for seekblock based on the "size" parameter
    -- and the player position
    local p1 = {x=pos.x-size, y=pos.y, z=pos.z-size}
    local p2 = {x=pos.x+size, y=pos.y+size, z=pos.z+size}
    return p1, p2
end

function get_voxel_center(pos)
    -- Helper utility for finding the voxel coordinates from the player coordinates
    -- The player coordinates has decimals that we want to remove
    return {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.5),z=math.floor(pos.z+0.5)}
end

function clean_seekblock(name, pos, size, id, winner)
    -- This very critical function cleans up the seekblock blocks when a game finishes
    -- It *should* leave no trace of the original game

    -- Because games can be cleaned up using multiple mechanisms, we need to check
    -- to make sure that it hasn't been cleaned up already. We do that with a 
    -- mod storage table
    local meta_table = seekblock_storage:get_string(name)
    if meta_table == nil or meta_table == "" then  -- not sure if nil or "" is correct, check for either
        -- This game was already cleaned up -- just return
        return
    else
        meta_table = minetest.deserialize(meta_table)
        if id ~= meta_table.id then  -- Maybe check for <?
            --- this is likely the timer timeout for a previous game at the same location
            --- so don't do anything
            return
        end
    end
    -- We really do have to clean up this game, so get to it!

    seekblock_storage:set_string(name, "")  -- Remove the mod storage so this player can create a new game again

    -- Get the ids of the blocks we care about
    local fallblock = minetest.get_content_id("seekblock:fall")
    local hideblock = minetest.get_content_id("seekblock:hide")
    local wallblock = minetest.get_content_id("seekblock:wall")
    local airblock = minetest.get_content_id("air")

    -- This is *almost* the reverse of the generation -- mostly simpler
    -- During generation we ONLY replaced air blocks, so any seekblocks need to
    -- be overwritten by air blocks

    -- initialize the voxel manipulator
    local p1, p2
    p1, p2 = get_seekblock_extents(pos, size)
    local vm, a = init(p1, p2)

    local data = vm:get_data()

    -- Replace our blocks with air blocks
    for x = p1.x, p2.x do
        for y = p2.y, p1.y - 1, -1 do  -- p1.y-1 to clean up the floor as well and -1 step to do floor last
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
    vm:write_to_map()
    vm:update_map()
    minetest.log("action", "seekblock: DONE CLEANING LEVEL!")

    if winner == nil then  -- either timeout, or seekblockclear was called
        return
    end

    -- After cleaning up, give the winner their prize, currently a particle effect
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
        texture="seekblock_palette1.png",
        glow=10,
    }
    minetest.add_particlespawner(particle_spawner)

end

minetest.register_chatcommand("seekblockclear", {
    params = "",
    description = "seekblock: Clear your current game.",
    -- privs = {}
    func = function(name, params)
        local meta_table = seekblock_storage:get_string(name)
        if  meta_table == nil or meta_table == "" then
            -- no active games, doing nothing
            return
        end
        local meta_table = minetest.deserialize(meta_table)

        if meta_table == nil then -- needed this for a bug, can't remember what it was
            seekblock_storage:set_string(name, "")
            return
        end
        clean_seekblock(name, meta_table.pos, meta_table.size, meta_table.id)
    end
}
)