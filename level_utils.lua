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

