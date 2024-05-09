
-- Load the data
local function make_level(name, pos, size, percent, time)
    if seekblock_storage:get_string(name) ~= "" then
        minetest.log("action", "User has active game, no spamming!")
        return
    end
    -- Get voxel center    
    pos = get_voxel_center(pos)

    -- Sanitize inputs
    size = math.min(size, 32)
    percent = math.min(51200 / (size * size * size), percent)
    time = math.max(math.min(10, time), 5/60)

    -- Get all players in the vicinity -- no blocks on top of players
    local allplayers = minetest.get_objects_inside_radius(pos, size)
    local positions = {}
    for key, player in pairs(allplayers) do
        local mypos = get_voxel_center(player:get_pos())
        positions[key] = mypos
    end

    -- find the extents of the play area
    local p1, p2
    p1, p2 = get_seekblock_extents(pos, size)
    minetest.log("action", 'pos='..minetest.serialize(pos).." P1="..minetest.serialize(p1).." P2="..minetest.serialize(p2)) 
    local vm, a = init(p1, p2)

    local data = vm:get_data()
    local color_data = vm:get_param2_data()

    -- These are the blocks that matter
    local fallblock = minetest.get_content_id("hideandseekblock:fall")
    local hideblock = minetest.get_content_id("hideandseekblock:hide")
    local wallblock = minetest.get_content_id("hideandseekblock:wall")
    local airblock = minetest.get_content_id("air")

    -- Place the hiding block
    local currblock = fallblock
    local x, y, z, col, idx
    while currblock ~=airblock do
        x = math.random(p1.x, p2.x)
        y = math.random(p1.y, p2.y)
        z = math.random(p1.z, p2.z)
        idx = a:index(x, y, z)
        currblock = data[idx]
        for key, mypos in pairs(positions) do                    
            if x == mypos.x and z == mypos.z then 
                currblock = fallblock
            end
        end        
    end
    col = math.random(0, 255)
    data[idx] = hideblock
    color_data[idx] = col
    local hidepos = {x=x, y=y, z=z}
    local meta = minetest.get_meta(hidepos)
    local meta_table = {player=name,pos=pos,size=size}
    meta:set_string("seekblock", minetest.serialize(meta_table))
    
    -- draw the floor
    y = p1.y - 1
    for x = p1.x, p2.x do
        for z = p1.z, p2.z do
            idx = a:index(x, y, z)
            local thisblock = data[idx]
            if thisblock == airblock then 
                data[idx] = wallblock
            end
        end
    end
    -- draw the clutter blocks
    for x = p1.x, p2.x do
        for y = p1.y, p2.y do
            for z = p1.z, p2.z do
                for key, mypos in pairs(positions) do                    
                    if x == mypos.x and z == mypos.z then goto continue end
                end
                idx = a:index(x, y, z)
                local thisblock = data[idx]
                if thisblock ~= airblock then goto continue end
                
                local test = math.random(0, 10000) / 10000 * 100  -- percent
                if test > percent then goto continue end
                
                data[idx] = fallblock
                col = math.random(0, 255)
                color_data[idx] = col 
                ::continue::
            end
        end
    end

    vm:set_data(data)
    vm:set_param2_data(color_data)
    vm:write_to_map()
    vm:update_map()

    
    -- trigger blocks to fall
    for x = p1.x, p2.x do
        for y = p1.y, p2.y do
            for z = p1.z, p2.z do
                idx = a:index(x, y, z)
                local thisblock = data[idx]
                if thisblock == fallblock then
                    minetest.check_for_falling({x=x, y=y, z=z})
                end
                if thisblock == hideblock then
                    minetest.check_for_falling({x=x, y=y, z=z})
                end
            end
        end
    end

    -- Register this game
    seekblock_storage:set_string(name, minetest.serialize(meta_table))
    
    -- set a timer to end game after interval even if no one finds the block
    minetest.after(
        time * 60, 
        function(name, pos, size)
            minetest.log("action", "TIMER EXPIRED, if no winner, clean up")
            clean_seekblock(name, pos, size, nil)
            return false
        end, 
        name, pos, size
    )

    -- meta = minetest.get_meta(pos)
    -- meta_table = {player=name,pos=pos,size=size}
    -- meta:set_string("seekblock", minetest.serialize(meta_table))    
    -- local timer = minetest.get_node_timer(pos)
    -- timer:start(5)
    -- if timer:is_started() then
    --     minetest.log("action", "TIME STARTED!" .. minetest.serialize(hidepos).." "..timer:get_elapsed())
    -- else
    --     minetest.log("action", "TIME NOT NOT NOT STARTED!")
    -- end
    minetest.log("action", "DONE BUILDING LEVEL!~!")
    -- vm:calc_lighting(nil, nil, false)
end

minetest.register_chatcommand("seekblock", {
    params = "<xyzsize> <percent>",
    description = "Atest level",
    -- privs = {}
    func = function(name, params)
        local paramss = params:split(" ")
        local size = 8
        local fillpercent = 16
        local time = 4 -- minutes
        if paramss[1] ~= nil then 
            size = tonumber(paramss[1])
        end
        if paramss[2] ~= nil then 
            fillpercent = tonumber(paramss[2])
        end
        if paramss[3] ~= nil then 
            time = tonumber(paramss[3])
        end
        local player = minetest.get_player_by_name(name)
        local pos = player:get_pos()
        make_level(name, pos, size, fillpercent, time)
    end
}
)


