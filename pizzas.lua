local S = core.get_translator("pizzas")

local worldpath = minetest.get_worldpath()
local pizzas_file = worldpath .. "/pizzas.lua"

pizzas = {}
pizzas.registered = {}

--==========
-- Registration
--==========

function pizzas.register_pizza(name, def)
    local nodename = ":pizzas:" .. name
    minetest.register_node(nodename, {
        description = def.description or "Pizza",
        drawtype = "mesh",
        mesh = def.mesh or "pizzas_big.obj",
        tiles = def.tiles or {"pizzas_base.png"},
		palette = def.palette or "pizzas_bake_palette.png",
        paramtype = "light",
        paramtype2 = "colordegrotate",
        groups = def.groups or {oddly_breakable_by_hand = 3},
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
        },
        collision_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
			use_texture_alpha = "blend"
        },
    })
    pizzas.registered[name] = def
    pizzas.save()
end

--==========
-- Save
--==========
function pizzas.save()
    local f = io.open(pizzas_file, "w")
    if not f then
        minetest.log("error", "[pizzas] Can't open pizzas.lua for write")
        return
    end
    f:write("return {\n")
    for name, def in pairs(pizzas.registered) do
        f:write("  [\"" .. name .. "\"] = {\n")
        f:write("    description = " .. minetest.serialize(def.description) .. ",\n")
        f:write("    mesh = " .. minetest.serialize(def.mesh) .. ",\n")
        f:write("    tiles = " .. minetest.serialize(def.tiles) .. ",\n")
        f:write("    palette = " .. minetest.serialize(def.palette) .. ",\n")
        f:write("  },\n")
    end
    f:write("}\n")
    f:close()
end

--==========
-- Load
--==========
local loaded = {}
local ok, data = pcall(dofile, pizzas_file)
if ok and type(data) == "table" then
    loaded = data
end

for name, def in pairs(loaded) do
    pizzas.register_pizza(name, def)
end

--==========
-- Example base pizza
--==========

pizzas.register_pizza("base", {description = "Base pizza",mesh = "pizzas_big.obj",tiles = {"pizzas_base.png"},palette = nil})
