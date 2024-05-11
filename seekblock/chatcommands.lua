
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