
local function make_level(name, pos, size, percent, time)
    -- This function creates the game area for seekblock
    if seekblock_storage:get_string(name) ~= "" then
        minetest.log("action", "seekblock: User '"..name.."' tried to start another game but has active game, no spamming, doing nothing!")
        return
    end
    
    -- Get voxel center of players position    
    pos = get_voxel_center(pos)

    minetest.log("action", "seekblock: User '"..name.."' started game with size "..size.." percent filled "..percent.." and timeout "..time.."m at "..minetest.serialize(pos))

    -- Sanitize inputs
    size = math.min(size, 32)
    percent = math.min(51200 / (size * size * size), percent)  -- find percent such that max number blocks is 512
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

    -- Initialize the voxel data and the color data
    local data = vm:get_data()
    local color_data = vm:get_param2_data()  -- used to color the blocks based on the palette

    -- These are the blocks that matter
    local fallblock = minetest.get_content_id("seekblock:fall")
    local hideblock = minetest.get_content_id("seekblock:hide")
    local wallblock = minetest.get_content_id("seekblock:wall")
    local airblock = minetest.get_content_id("air")

    -- Place the hiding block, randomly
    local currblock = fallblock -- initialize, we can only place the hideblock on an airblock, so randomly find one
    local x, y, z, col, idx
    local count = 100  -- Avoid infinite loop
    while currblock ~= airblock do
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
        -- infinite loop protection
        count = count - 1
        if count == 0 then
            minetest.log('action', 'seekblock: Cannot place the hideblock after 100 tried, quitting.')
            return
        end
    end
    col = math.random(0, 255)  -- hideblock is randomly colored
    data[idx] = hideblock
    color_data[idx] = col
    local hidepos = {x=x, y=y, z=z}
    local meta = minetest.get_meta(hidepos)
    local meta_table = {player=name,pos=pos,size=size, id=os.time()}
    meta:set_string("seekblock", minetest.serialize(meta_table))
    
    -- add the floor nodes
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
    -- add the clutter nodes
    for x = p1.x, p2.x do
        for y = p1.y, p2.y do
            for z = p1.z, p2.z do
                for key, mypos in pairs(positions) do                    
                    if x == mypos.x and z == mypos.z then goto continue end
                end
                idx = a:index(x, y, z)
                local thisblock = data[idx]
                if thisblock ~= airblock then goto continue end
                
                local test = math.random(0, 10000) / 10000 * 100  -- 100 for percent
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

    -- trigger nodes to fall
    for x = p1.x, p2.x do
        for y = p1.y, p2.y do
            for z = p1.z, p2.z do
                idx = a:index(x, y, z)
                local thisblock = data[idx]
                if thisblock == fallblock or thisblock == hideblock then
                    minetest.check_for_falling({x=x, y=y, z=z})
                end
            end
        end
    end

    -- Register this game so player cannot make anothe rone
    seekblock_storage:set_string(name, minetest.serialize(meta_table))
    
    -- set a timer to end game after interval even if no one finds the block
    minetest.after(
        time * 60, 
        function(name, pos, size, id)
            minetest.log("action", "seekblock: Timer expired. If no winner then clean up.")
            clean_seekblock(name, pos, size, id, nil)
            return false
        end, 
        name, pos, size, meta_table.id
    )

    minetest.log("action", "seekblock: Done starting game for "..name..".")
    -- vm:calc_lighting(nil, nil, false)
end

minetest.register_chatcommand("seekblock", {
    params = "<xyzsize> <percent>",
    description = "Atest level",
    -- privs = {}
    func = function(name, params)
        local paramss = params:split(" ")
        local size = 8 -- 17 x 8 x 17 game area
        local fillpercent = 16 -- percent
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


