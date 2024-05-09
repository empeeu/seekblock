minetest.register_node("seekblock:wall", {
    description = "Wall and floor",
    tiles = {"wall.png"},
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
    tiles = {"fall.png"},
    -- groups = {falling_node = 1},
    use_texture_alpha = "",
    climbable = false,
    palette = "palette1.png",
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
        dig_immediate=3,
        oddly_breakable_by_hand=1
    }
})
minetest.register_node("seekblock:hide", {
    description = "Hiding block",
    tiles = {"hider.png"},
    use_texture_alpha = "",
    climbable = false,
    palette = "palette1.png",
    -- The node's `param2` is used to select a pixel from the image.
    -- Pixels are arranged from left to right and from top to bottom.
    -- The node's color will be multiplied with the selected pixel's color.
    -- Tiles can override this behavior.
    -- Only when `paramtype2` supports palettes.
    paramtype2 = "color",
    param2 = 128, --    tells which color is picked from the palette. The palette should have 256 pixels.
    place_param2 = 128,
    walkable = true,  -- If true, objects collide with node
    pointable = true,
    diggable = true,  -- If false, can never be dug
    -- Can be `true` if
    groups = {
        falling_node=1,
        dig_immediate=3,
        oddly_breakable_by_hand=1
    },
    after_dig_node = function (pos, oldnode, oldmetadata, digger) 
        local seekblock = minetest.deserialize(oldmetadata.fields.seekblock)
        clean_seekblock(seekblock.player, seekblock.pos, seekblock.size, digger)
    end
})
