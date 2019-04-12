-- Copyright (C) 2019 Ren Finkle
--
-- Version: Beta 2 Public, April 12, 2019
local version = "Beta 2 Public"
-- Check is UI available
if not app.isUIAvailable then
    return
end

-- Perlin code start --
-- https://stackoverflow.com/questions/33425333/lua-perlin-noise-generation-getting-bars-rather-than-squares
local function BitAND(a, b) --Bitwise and
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra + rb > 1 then
            c = c + p
        end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
end
--

--https://gist.github.com/SilentSpike/25758d37f8e3872e1636d90ad41fe2ed

--[[
    Implemented as described here:
    http://flafla2.github.io/2014/08/09/perlinnoise.html
]] perlin = {}
perlin.p = {}

-- Hash lookup table as defined by Ken Perlin
-- This is a randomly arranged array of all numbers from 0-255 inclusive
local permutation = {
    151,
    160,
    137,
    91,
    90,
    15,
    131,
    13,
    201,
    95,
    96,
    53,
    194,
    233,
    7,
    225,
    140,
    36,
    103,
    30,
    69,
    142,
    8,
    99,
    37,
    240,
    21,
    10,
    23,
    190,
    6,
    148,
    247,
    120,
    234,
    75,
    0,
    26,
    197,
    62,
    94,
    252,
    219,
    203,
    117,
    35,
    11,
    32,
    57,
    177,
    33,
    88,
    237,
    149,
    56,
    87,
    174,
    20,
    125,
    136,
    171,
    168,
    68,
    175,
    74,
    165,
    71,
    134,
    139,
    48,
    27,
    166,
    77,
    146,
    158,
    231,
    83,
    111,
    229,
    122,
    60,
    211,
    133,
    230,
    220,
    105,
    92,
    41,
    55,
    46,
    245,
    40,
    244,
    102,
    143,
    54,
    65,
    25,
    63,
    161,
    1,
    216,
    80,
    73,
    209,
    76,
    132,
    187,
    208,
    89,
    18,
    169,
    200,
    196,
    135,
    130,
    116,
    188,
    159,
    86,
    164,
    100,
    109,
    198,
    173,
    186,
    3,
    64,
    52,
    217,
    226,
    250,
    124,
    123,
    5,
    202,
    38,
    147,
    118,
    126,
    255,
    82,
    85,
    212,
    207,
    206,
    59,
    227,
    47,
    16,
    58,
    17,
    182,
    189,
    28,
    42,
    223,
    183,
    170,
    213,
    119,
    248,
    152,
    2,
    44,
    154,
    163,
    70,
    221,
    153,
    101,
    155,
    167,
    43,
    172,
    9,
    129,
    22,
    39,
    253,
    19,
    98,
    108,
    110,
    79,
    113,
    224,
    232,
    178,
    185,
    112,
    104,
    218,
    246,
    97,
    228,
    251,
    34,
    242,
    193,
    238,
    210,
    144,
    12,
    191,
    179,
    162,
    241,
    81,
    51,
    145,
    235,
    249,
    14,
    239,
    107,
    49,
    192,
    214,
    31,
    181,
    199,
    106,
    157,
    184,
    84,
    204,
    176,
    115,
    121,
    50,
    45,
    127,
    4,
    150,
    254,
    138,
    236,
    205,
    93,
    222,
    114,
    67,
    29,
    24,
    72,
    243,
    141,
    128,
    195,
    78,
    66,
    215,
    61,
    156,
    180
}

-- p is used to hash unit cube coordinates to [0, 255]
for i = 0, 255 do
    -- Convert to 0 based index table
    perlin.p[i] = permutation[i + 1]
    -- Repeat the array to avoid buffer overflow in hash function
    perlin.p[i + 256] = permutation[i + 1]
end

-- Return range: [-1, 1]
function perlin:noise(x, y, z)
    y = y or 0
    z = z or 0

    -- Calculate the "unit cube" that the point asked will be located in
    local xi = BitAND(math.floor(x), 255)
    local yi = BitAND(math.floor(y), 255)
    local zi = BitAND(math.floor(z), 255)

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

    -- We also fade the location to smooth the result
    local u = self.fade(x)
    local v = self.fade(y)
    local w = self.fade(z)

    -- Hash all 8 unit cube coordinates surrounding input coordinate
    local p = self.p
    local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
    A = p[xi] + yi
    AA = p[A] + zi
    AB = p[A + 1] + zi
    AAA = p[AA]
    ABA = p[AB]
    AAB = p[AA + 1]
    ABB = p[AB + 1]

    B = p[xi + 1] + yi
    BA = p[B] + zi
    BB = p[B + 1] + zi
    BAA = p[BA]
    BBA = p[BB]
    BAB = p[BA + 1]
    BBB = p[BB + 1]

    -- Take the weighted average between all 8 unit cube coordinates
    return self.lerp(
        w,
        self.lerp(
            v,
            self.lerp(u, self:grad(AAA, x, y, z), self:grad(BAA, x - 1, y, z)),
            self.lerp(u, self:grad(ABA, x, y - 1, z), self:grad(BBA, x - 1, y - 1, z))
        ),
        self.lerp(
            v,
            self.lerp(u, self:grad(AAB, x, y, z - 1), self:grad(BAB, x - 1, y, z - 1)),
            self.lerp(u, self:grad(ABB, x, y - 1, z - 1), self:grad(BBB, x - 1, y - 1, z - 1))
        )
    )
end

-- Gradient function finds dot product between pseudorandom gradient vector
-- and the vector from input coordinate to a unit cube vertex
perlin.dot_product = {
    [0x0] = function(x, y, z)
        return x + y
    end,
    [0x1] = function(x, y, z)
        return -x + y
    end,
    [0x2] = function(x, y, z)
        return x - y
    end,
    [0x3] = function(x, y, z)
        return -x - y
    end,
    [0x4] = function(x, y, z)
        return x + z
    end,
    [0x5] = function(x, y, z)
        return -x + z
    end,
    [0x6] = function(x, y, z)
        return x - z
    end,
    [0x7] = function(x, y, z)
        return -x - z
    end,
    [0x8] = function(x, y, z)
        return y + z
    end,
    [0x9] = function(x, y, z)
        return -y + z
    end,
    [0xA] = function(x, y, z)
        return y - z
    end,
    [0xB] = function(x, y, z)
        return -y - z
    end,
    [0xC] = function(x, y, z)
        return y + x
    end,
    [0xD] = function(x, y, z)
        return -y + z
    end,
    [0xE] = function(x, y, z)
        return y - x
    end,
    [0xF] = function(x, y, z)
        return -y - z
    end
}
function perlin:grad(hash, x, y, z)
    return self.dot_product[BitAND(hash, 0xF)](x, y, z)
end

-- Fade function is used to smooth final output
function perlin.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(t, a, b, color, balance)
    if color then
        --res = res*balance
        --res = res*(1.5-balance)
        --res = res*255
        res = a + ((t + 1) / 2) * (b - a)
    else
        --res = (res+1)/2
        res = a + t * (b - a)
    end
    return res
end
-- Perlin Code end --

-- Noise render function
-- scale, float: Scale of noise
-- color, bool: Whether to generate in color
-- innerColor/centerColor, Color: Color occupying upper range of balance
-- outerColor, Color: Color occupying lower range of balance
-- balance, float: Lower bound of innerColor range (percentage)
-- borderSize, float: Size of border between innerColor/outerColor
-- NOTE: The color of the border is automatically lerped
-- seed, float: Offset from origin
-- bumpgen, boole: Whether to generate a bump map (Experimental)
-- colorStops, table (int): Table of color stop balances
-- colorStopColors, table (Color): Table of colors to use for color stops
-- cstop_bounds, table (float): Upper and lower bounds of color stops
-- NOTE: Color stops can override innerColor/outerColor 
function gen(
    scale,
    color,
    innerColor,
    outerColor,
    balance,
    borderSize,
    seed,
    bumpgen,
    colorStops,
    colorStopColors,
    cstop_bounds)
    -- Calculate border color
    if color then
        r = perlin.lerp(0.5, innerColor.red, outerColor.red, true, balance)
        g = perlin.lerp(0.5, innerColor.green, outerColor.green, true, balance)
        b = perlin.lerp(0.5, innerColor.blue, outerColor.blue, true, balance)
        borderColor = app.pixelColor.rgba(r, g, b)
    end
    -- cstop_range, table (float): Table of 'normalized' color stop balances, global contextualization
    -- Begin contextualization --
    local cstops_range = {cstop_bounds.lower}
    if colorStops and color then
        local cstop_mult = (cstop_bounds.upper - cstop_bounds.lower) / (#colorStops - 1)
        for it, cstop in ipairs(colorStops) do
            local addbound = (cstop / 100) * cstop_mult
            table.insert(cstops_range, cstops_range[it] + addbound)
        end
        cstops_range[#cstops_range] = cstop_bounds.upper
    end
    -- End conxtextualization
    height = app.activeImage.height
    width = app.activeImage.width
    -- Begin rendering, iterate over pixels --
    for y = 0, height do
        for x = 0, width do
            -- pcol, float: Contextualized perlin noise value
            pcol = perlin:noise((y / height * scale) + seed, (x / width * scale) + seed) * 255
            -- fcolor, Color: Final color value to use for pixel
            fcolor = {}
            -- Begin colorful rendering calculation --
            if color then
                -- npcol, float: Decontextualized/normalized perlin noise value
                npcol = (((pcol / 255) + 1) / 2)
                -- Begin color stops sensitive calculation --
                if colorStops then
                    local cstopfound = false
                    for it, cstop in ipairs(cstops_range) do
                        if cstop ~= cstop_bounds.lower then
                            if npcol >= cstops_range[it - 1] and npcol < cstop then
                                fcolor = colorStopColors[it - 1]
                                cstopfound = true
                                break
                            end
                        end
                    end
                    if not cstopfound then
                        if npcol >= (balance + borderSize / 2) then
                            fcolor = innerColor
                        elseif npcol < (balance - borderSize / 2) then
                            fcolor = outerColor
                        else
                            fcolor = borderColor
                        end
                    end
                -- End color stops sensitive calculation --
                -- Begin color stops insensitive calcuation --
                else
                    if npcol >= (balance + (borderSize / 2)) then
                        fcolor = innerColor
                    elseif npcol < (balance - (borderSize / 2)) then
                        fcolor = outerColor
                    else
                        fcolor = borderColor
                    end
                -- End color stops insensitive calcuation --
                end
            -- End colorful rendering calculation --
            else
                fcolor = app.pixelColor.rgba(pcol, pcol, pcol)
            end
            if bumpgen then
                -- Place black/white perline noise map (bumpmap)
                app.activeLayer:cel(app.activeFrame.frameNumber).image:drawPixel(x, y, fcolor)
            else
                --Place the pixel
                app.activeImage:drawPixel(x, y, fcolor)
            end
        end
    end
    -- End rendering --
    -- End rendering function and return nothing --
    return
end

-- Fills cel on layer with given icolor
function fill(layer, cel, icolor)
    for y = 0, app.activeSprite.layers[layer].cels[cel].image.height do
        for x = 0, app.activeSprite.layers[layer].cels[cel].image.width do
            app.activeSprite.layers[1].cels[1].image:drawPixel(x, y, icolor)
        end
    end
end

-- dlg, Dialog: Main dialog object
local dlg = {}
-- cStopDlg, Dialog: Color stop dialog object
local cStopDlg = nil

-- TODO
-- Context aware modular dialog refreshment
function refreshDLG()
end

-- Creates main dialog object, used to initialize and refresh dialog
function createDLG(
    scale,
    seed,
    bumpgen,
    randomseed,
    color,
    centercolor,
    edgecolor,
    balance,
    borderSize,
    addstop,
    bounding)
    -- NOTE: Initializing Dialog with string gives the window a title
    dlg = Dialog("Noise")
    -- If given bounding box, set bounding coordinates for dlg
    if bounding then
        dlg.bounds = bounding
    end
    dlg:entry {id = "scale", label = "Scale:", text = scale or "1.0"}
    dlg:entry {id = "seed", label = "Seed:", text = seed or "0"}
    dlg:check {
        id = "bumpgen",
        label = "Generate Bumpmap (on new frame): ",
        text = "Yes",
        selected = false or bumpgen
    }
    dlg:check {
        id = "randomseed",
        label = "Random Seed: ",
        text = "Yes",
        selected = false or randomseed
    }
    dlg:check {
        id = "color",
        label = "Use color: ",
        text = "Yes",
        selected = false or color
    }
    -- NOTE: Also referred to as innerColor for reasons beyond comprehension and also because I was too lazy to update it in this version
    dlg:color {
        id = "centercolor",
        label = "Center color:",
        color = centercolor or Color {r = 255, g = 255, b = 0, a = 255}
    }
    dlg:color {
        id = "edgecolor",
        label = "Edge color:",
        color = edgecolor or Color {r = 0, g = 255, b = 255, a = 255}
    }
    dlg:slider {
        id = "balance",
        label = "Bias (lower bound of center color):",
        min = 0,
        max = 100,
        value = balance or 50
    }
    dlg:slider {
        id = "borderSize",
        label = "Border Size:",
        min = 0,
        max = 100,
        value = borderSize or 50
    }
    -- noisePresets, table (table): 2D table containing different presets to make life easy
    -- NOTE: Currently only contains Starscape preset but when the filepicker is implemented in the Aseprite API user presets will be allowed and a preset file will be included
    local noisePresets = {
        Starscape = {
            scale = 100,
            centercolor = Color {r = 0, g = 0, b = 0, a = 255},
            edgecolor = Color {r = 255, g = 255, b = 255, a = 255},
            balance = 0.26,
            borderSize = 0
        }
    }
    -- poptions, table (string): List of preset options including "Choose" in order to allow users to not use a preset (better method forthcoming on API updates)
    poptions = {"Choose"}
    for name, entry in pairs(noisePresets) do
        table.insert(poptions, name)
    end
    dlg:combobox {
        id = "presetl",
        label = "Presets:",
        options = poptions
    }
    dlg:newrow()
    -- aoptions, table (mixed): Table of addstop options, varies on whether addstop value exists
    local aoptions = {}
    if addstop and addstop ~= "Choose" then
        aoptions = {addstop, "Choose", 1, 2, 3, 4, 5, 6}
        table.remove(aoptions, addstop+2)
    else
        aoptions = {"Choose", 1, 2, 3, 4, 5, 6}
    end
    -- NOTE: Better options setup forthcoming on API updates
    -- NOTE: If extra color stops is set to choose and addstops is clicked the color stops dialog is closed
    dlg:combobox {
        id = "addstop",
        label = "Extra color stops:",
        options = aoptions
    }
    -- Clicking button adds stops
    dlg:button {
        id = "addstops",
        text = "Add stops",
        onclick = function()
            -- addstop_tmp, string: Retains old addstop setting for use in color stops dialog creation
            -- NOTE: While name refers to older usage, variable is still in use for purpose of shorthand 
            local addstop_tmp = dlg.data.addstop
            -- oldbounds, table (int): Contains old x and y coordinates of color stop dialog for refresh
            local oldbounds = nil
            -- old_lower/old_upper, int: Contains lower and upper bounds respectively of color stop dialog for refresh
            local old_lower = nil
            local old_upper = nil
            -- If a color stop dialog exists pull coordinates/values for refresh
            if cStopDlg then
                cStopDlg:close()
                oldbounds = {x = cStopDlg.bounds.x, y = cStopDlg.bounds.y}
                old_lower = cStopDlg.data.cstop_bound_lower
                old_upper = cStopDlg.data.cstop_bound_upper
            end
            -- If the add stops option is set to Choose and there is an existing color stop dialog, set it to nil (effectively destroys it)
            if dlg.data.addstop == "Choose" then
                if cStopDlg then
                    cStopDlg = nil
                end
            else
                cStopDlg = Dialog("Noise: Color Stops")
                cStopDlg:slider {
                    id = "cstop_bound_lower",
                    label = "Color Stop Lower Bound:",
                    min = 0,
                    max = 100,
                    value = old_lower or 20
                }
                cStopDlg:slider {
                    id = "cstop_bound_upper",
                    label = "Color Stop Upper Bound:",
                    min = 0,
                    max = 100,
                    value = old_upper or 60
                }
                -- Create color stops and corresponding balance sliders
                for it = 1, addstop_tmp do
                    cStopDlg:color {
                        id = "newcolor_" .. tostring(it),
                        label = "Color Stop " .. tostring(it) .. ":",
                        color = Color {r = 0, g = 255, b = 255, a = 255}
                    }
                    cStopDlg:slider {
                        id = "ncolorbalance_" .. tostring(it),
                        label = "Bias " .. tostring(it) .. ":",
                        min = 0,
                        max = 100,
                        value = 50
                    }
                end
                -- Shows then close color stop dialog, this makes sure the bounds width and height wise are set before we set the coordinates
                cStopDlg:show {wait = false}
                cStopDlg:close()
                if oldbounds then
                    -- Sets the coordinates to last coordinates, effectively making it seem unmoved
                    cStopDlg.bounds = Rectangle(oldbounds.x, oldbounds.y, cStopDlg.bounds.width, cStopDlg.bounds.height)
                else
                    -- Sets the coordinates to snap to the top right point of the main dialog
                    cStopDlg.bounds =
                        Rectangle(
                        dlg.bounds.x + dlg.bounds.width,
                        dlg.bounds.y,
                        cStopDlg.bounds.width,
                        cStopDlg.bounds.height
                    )
                end
                -- Actually show the color stop dialog
                -- NOTE: wait=false ensures that the users can still manipulate the canvas even with the noise plugin in use
                cStopDlg:show {wait = false}
            end
        end
    }
    dlg:button {
        id = "ok",
        text = "OK",
        onclick = function()
            local colorStops = nil
            local colorStopColors = nil
            -- Short hand, save a decimal and three characters for the duration of the function
            local data = dlg.data
            -- refreshSeed, bool: Whether to refresh the seed value in the main dialog, this is used in case of a user choosing the random seed option so that they may use the seed in the future
            local refreshSeed = false
            -- If a preset is not chosen, pull the values from the dialog
            if data.presetl == "Choose" then
                scale = tonumber(data.scale)
                color = data.color
                centercolor = data.centercolor
                edgecolor = data.edgecolor
                -- Normalize balance
                balance = tonumber(data.balance / 100)
                -- Normalize border size (border size is necessarily small)
                borderSize = data.borderSize / 1000
                -- Generate random seed
                if data.randomseed then
                    seed = math.random() + math.random(1, 99)
                    refreshSeed = true
                -- Use user defined seed (or 0, the default seed)
                else
                    seed = tonumber(data.seed) / (10 ^ string.len(data.seed)) * 100
                end
                -- Color stops data gathering and bounds normalization
                if
                    data.addstop ~= "Choose" and cStopDlg and
                        cStopDlg.data.cstop_bound_lower < cStopDlg.data.cstop_bound_upper
                 then
                    colorStops = {}
                    colorStopColors = {}
                    for it = 1, tonumber(data.addstop) do
                        table.insert(colorStopColors, cStopDlg.data["newcolor_" .. tostring(it)])
                        table.insert(colorStops, cStopDlg.data["ncolorbalance_" .. tostring(it)])
                    end
                    cstop_bounds = {
                        lower = cStopDlg.data.cstop_bound_lower / 100,
                        upper = cStopDlg.data.cstop_bound_upper / 100
                    }
                end
            -- If a preset Is chosen, use the values from the preset for rendering/generation
            else
                preset = noisePresets[data.presetl]
                scale = preset.scale
                color = true
                centercolor = preset.centercolor
                edgecolor = preset.edgecolor
                balance = preset.balance
                borderSize = preset.borderSize
                -- Seed is always random at this time 
                -- NOTE: Revisit when filepicker implemented
                seed = math.random(0.01, 99.99)
            end
            -- Render/generation call
            gen(
                scale,
                color,
                centercolor,
                edgecolor,
                balance,
                borderSize,
                seed,
                false,
                colorStops,
                colorStopColors,
                cstop_bounds
            )
            -- Additional call for bump generation if required
            if data.bumpgen then
                app.activeSprite:newFrame()
                gen(scale, false, nil, nil, balance, borderSize, seed, true)
            end
            -- Hard refreshes canvas to update, revisit on API updates
            app.refresh()
            -- Sets seed in main dialog
            if refreshSeed then
                local bounding = Rectangle(dlg.bounds.x, dlg.bounds.y, dlg.bounds.width, dlg.bounds.height)
                dlg:close()
                createDLG(
                    dlg.data.scale,
                    tostring(math.floor(seed * (10 ^ 12))),
                    dlg.data.bumpgen,
                    dlg.data.randomseed,
                    dlg.data.color,
                    dlg.data.centercolor,
                    dlg.data.edgecolor,
                    dlg.data.balance,
                    dlg.data.borderSize,
                    tostring(dlg.data.addstop)
                )
                dlg:show {wait = false}
                dlg:close()
                dlg.bounds = bounding
                dlg:show {wait = false}
            end
        end
    }
    dlg:button {id = "cancel", text = "Cancel"}
    -- Info button, pop up contains version information and link to repository/readme
    dlg:button {
        id = "info",
        text = "Info",
        onclick = function()
            if not infoDlg then
                infoDlg = Dialog("Info")
            else
                infoDlg:close()
                infoDlg = Dialog("Info")
            end
            infoDlg:entry{id="repo", label="Repository:", text="https://github.com/RenFinkle/noisy"}
            infoDlg:label{id="version", label="Version:", text=version}
            infoDlg:show{wait=false}
        end
    }
end
-- Create main dialog and show it
createDLG()
dlg:show {wait = false}