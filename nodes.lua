minetest.register_node("seekblock:wall", {
    description = "Wall and floor",
    tiles = {"seekblock_wall.png"},
    use_texture_alpha = "",
    climbable = false,
    walkable = true,  -- If true, objects collide with node
    pointable = false,
    diggable = false,  -- If false, can never be dug
    -- Can be `true` if
    -- groups = {
        -- falling_node=1,
        -- dig_immediate=3,
        -- oddly_breakable_by_hand=1
    -- }
})
minetest.register_node("seekblock:fall", {
    description = "Hide obstacles",
    tiles = {"seekblock_fall.png"},
    -- groups = {falling_node = 1},
    use_texture_alpha = "",
    climbable = false,
    palette = "seekblock_palette1.png",
    -- The node's `param2` is used to select a pixel from the image.
    -- Pixels are arranged from left to right and from top to bottom.
    -- The node's color will be multiplied with the selected pixel's color.
    -- Tiles can override this behavior.
    -- Only when `paramtype2` supports palettes.
    paramtype2 = "color",
    param2 = 0, --    tells which color is picked from the palette. The palette should have 256 pixels.
    walkable = true,  -- If true, objects collide with node
    pointable = true,
    diggable = true,  -- If false, can never be dug
    -- Can be `true` if
    groups = {
        falling_node=1,
        float=1,
        dig_immediate=3,
        oddly_breakable_by_hand=1
    }, 
    sounds = {
        dug = {
            name = "seekblock_pop"
        }
    }
})
minetest.register_node("seekblock:hide", {
    description = "Hiding block",
    tiles = {"seekblock_hider.png"},
    use_texture_alpha = "",
    climbable = false,
    palette = "seekblock_palette1.png",
    -- The node's `param2` is used to select a pixel from the image.
    -- Pixels are arranged from left to right and from top to bottom.
    -- The node's color will be multiplied with the selected pixel's color.
    -- Tiles can override this behavior.
    -- Only when `paramtype2` supports palettes.
    paramtype2 = "color",
    param2 = 128, --    tells which color is picked from the palette. The palette should have 256 pixels.
    -- place_param2 = 128,
    walkable = true,  -- If true, objects collide with node
    pointable = true,
    diggable = true,  -- If false, can never be dug
    -- Can be `true` if
    groups = {
        falling_node=1,
        float=1,
        dig_immediate=3,
        oddly_breakable_by_hand=1
    },
    sounds = {
        dug = {
            name = "seekblock_gong",
            gain = 2,
        }
    },
    after_dig_node = function (pos, oldnode, oldmetadata, digger) 
        local seekblock = oldmetadata.fields.seekblock
        -- minetest.log("action", "WE HAVE A WINNER ".. seekblock)
        if seekblock ~= nil then             
            -- minetest.log("action", "WE HAVE A WINNER ".. seekblock)
            seekblock = minetest.deserialize(seekblock)
            clean_seekblock(seekblock.player, seekblock.pos, seekblock.size, seekblock.id, digger)
        end
    end
})
