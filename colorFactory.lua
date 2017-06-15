-- module table
local colorFactory = {
  _VERSION = "0.1",
  _DESCRIPTION = "love2d focused color table library",
  _URL = "",
  _LICENSE = [[
    MIT License

    Copyright (c) 2017 Skeletonxf

    Permission is hereby granted, free of charge, to any person obtaining a 
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
  ]],
  _USAGE = [[
    local cf = require "colorFactory"
    ...
    -- no need to remember if black is 255 or 0
    love.graphics.setColor(cf.BLACK())
    ...
    function love.draw
        ...
        -- this color is remembered for next time so the table
        -- is simply retrieved
        love.graphics.setColor(cf.RGB255(50, 255, 150))
        ...
    end
    -- which means you can do comparisons with == like this
    if love.graphics.getColor() == cf.WHITE() then
      ...
    end
    ...
    -- you can also work in colors in HSL mode
    -- here the hue is cycled by the delta time
    love.graphics.setColor(cf.HSL(math.abs(math.sin(dt)), 0.7, 0.3))
    ...
    -- you can also define colors by hex codes
    love.graphics.setColor(cf.hex "0DEB0C")
    ...
    All CSS colors up to and including rebeccapurple are implemented
    as default named colors to this library and the functions can
    be called by using the relevant name (in all lower or all upper case)
    and then () to call the function, like
    cf.BLACK(); cf.silver(); cf.white(); cf.grey(); cf.GRAY() 
  ]],
}
  
local colors = {}
-- make the values (ie the color tables) weak for the color table
setmetatable(colors, {__mode = "v"})

local function bound(x)
  return (x > 255 or x < 0)
end

-- takes color input in range 0-255
-- to convert to love2d's 0..1 range
function colorFactory.RGB255(r, g, b, a)
  a = a or 255
  if bound(r) or bound(g) or bound(b) or bound(a) then
    error("Invalid input, data not in range 0..255", 2, debug.traceback())
  end
  -- put colors in range 0..1
  r, g, b, a = r/255, g/255, b/255, a/255
  return colorFactory.RGB(r, g, b, a)
end

-- main function that takes r, g, b, a input and
-- fetches the table for that color if it already
-- exists, or creates on and returns that
-- the tables here work in a 0..1 range for each component
-- this means colors can be compared using ==
-- it also means if you modify the returned table you modify all uses of that table!
function colorFactory.RGB(r, g, b, a)
  local colorTextForm = r .. "-" .. g .. "-" .. b .. "-" .. a
  if not colors[colorTextForm] then
    -- create the color if it doesn't already exist
    local colorTable = {r, g, b, a}
    -- add the color to the colors table
    colors[colorTextForm] = colorTable
  end
  -- return the color
  return colors[colorTextForm]
end

-- for compatibility with love2d 10 and below, use this on colors
-- before drawing with them
function colorFactory.to255(color)
  return {
    color[1]*255, color[2]*255, color[3]*255, color[4]*255
  }
end

-- same as RGB function above but uses input in HSL color scheme
-- converts the HSL color to RGB for internal representation
-- working in 0..1 range for each color component
function colorFactory.HSL(h, s, l, a)
  -- by https://en.wikipedia.org/wiki/HSL_and_HSV#From_HSL
  a = a or 1
  local c = (1 - (math.abs(2 * l) - 1)) * s
  -- as in article with h' in range 0..6 to not mess up the modulo
  local x = c * (1 - math.abs(((h * 60) % 2) - 1))
  -- refers to h' in article, only in range 0..1
  -- 'hue' should thus be in range 0..1 with 1/6 intervals
  -- rather than 1 intervals in range 0..6 as on article
  local hue = h / 6
  -- pre lightness adjusted rgb colors
  local r1, g1, b1 = 0, 0, 0
  if h < 1/6 then 
    r1 = c
    g1 = x
  elseif h < 2/6 then
    r1 = x
    g1 = c
  elseif h < 3/6 then
    g1 = c
    b1 = x
  elseif h < 4/6 then
    g1 = x
    b1 = c
  elseif h < 5/6 then
    r1 = x
    b1 = c
  else
    r1 = c
    b1 = x
  end
  -- adjust colors for lightness
  local m = l - c/2
  return colorFactory.RGB(r1 + m, g1 + m, b1 + m, a)
end

-- takes color input in range 0-255
-- to convert to love2d's 0..1 range
function colorFactory.HSL255(r, g, b, a)
  a = a or 255
  if bound(r) or bound(g) or bound(b) or bound(a) then
    error("Invalid input, data not in range 0..255", 2, debug.traceback())
  end
  -- put colors in range 0..1
  r, g, b, a = r/255, g/255, b/255, a/255
  return colorFactory.HSL(r, g, b, a)
end

-- converts a hexadecimal digit represented as a string to a number
local function hexToInt(hex)
  hex = hex:upper()
  if hex == "0" then return 0
  elseif hex == "1" then return 1
  elseif hex == "2" then return 2
  elseif hex == "3" then return 3
  elseif hex == "4" then return 4
  elseif hex == "5" then return 5
  elseif hex == "6" then return 6
  elseif hex == "7" then return 7
  elseif hex == "8" then return 8
  elseif hex == "9" then return 9
  elseif hex == "A" then return 10
  elseif hex == "B" then return 11
  elseif hex == "C" then return 12
  elseif hex == "D" then return 13
  elseif hex == "E" then return 14
  elseif hex == "F" then return 15
  else
    error("string is not a hex digit", 2, debug.traceback())
  end
end

-- converts 2 hex characters to the integer representation selecting them
-- from the hexstring by the ith and i+1th position
local function hexTo255(hexstring, i)
  return hexToInt(hexstring:sub(i, i))*16 + hexToInt(hexstring:sub(i+1, i+1))
end

-- input should be a 6 or 8 character hexadecimal string representing a color
-- returns the color represented by this hexstring
function colorFactory.hex(hexstring)
  local r, g, b, a = colorFactory.hexConvert(hexstring)
  return colorFactory.RGB255(r, g, b, a)
end

-- converts a hex string to r, g, b, a values
function colorFactory.hexConvert(hexstring)
  local length = hexstring:len()
  if length ~= 6 and length ~= 8 then 
    error("hexstring input '" .. hexstring ..  "' is wrong size", 2, debug.traceback())
  end
  local r, g, b, a = 0, 0, 0, 0
  if length == 6 then
    -- default to opaque if alpha left out
    a = 255
  end
  r = hexTo255(hexstring, 1)
  g = hexTo255(hexstring, 3)
  b = hexTo255(hexstring, 5)
  if length == 8 then
    a = hexTo255(hexstring, 7)
  end
  return r, g, b, a
end

-- function to add default colors to colorFactory
local function addDefault(name, hexstring)
  -- remember the converted hex codes in the function
  local r, g, b, a = colorFactory.hexConvert(hexstring)
  local getColor = function()
    return colorFactory.RGB255(r, g, b, a)
  end
  -- so if called with black then
  -- doing colorFactory.black() will return the color
  colorFactory[name] = getColor
  -- and so will colorFactory.BLACK()
  colorFactory[name:upper()] = getColor
end

-- https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#Color_keywords
local defaults = {
  black = "000000",
  silver = "C0C0C0",
  gray = "808080",
  white = "FFFFFF",
  maroon = "800000",
  red = "FF0000",
  purple = "800080",
  fuchsia = "FF00FF",
  green = "008000",
  lime = "00FF00",
  olive = "808000",
  yellow = "FFFF00",
  navy = "000080",
  blue = "0000FF",
  teal = "008080",
  aqua = "00FFFF",
  orange = "FFA500",
  aliceblue = "F0F8FF",
  antiquewhite = "FAEBD7",
  aquamarine = "7FFFD4",
  azure = "F0FFFF",
  beige = "F5F5DC",
  bisque = "FFE4C4",
  blanchedalmond = "FFEBCD",
  blueviolet = "8A2BE2",
  brown = "A52A2A",
  burlywood = "DEB887",
  cadetblue = "5F8EA0",
  chartreuse = "7FFF00",
  chocolate = "D2691E",
  coral = "FF7F50",
  cornflowerblue = "6595ED",
  cornsilk = "FFF8DC",
  crimson = "DC143C",
  cyan = "00FFFF", -- same as aqua
  darkblue = "00008B",
  darkcyan = "008B8B",
  darkgoldonrod = "B8860B",
  darkgray = "A9A9A9",
  darkkhaki = "BDB76B",
  darkmagenta = "8B008B",
  darkolivegreen = "556B2F",
  darkorange = "FF8C00",
  darkorchid = "9932CC",
  darkred = "8B0000",
  darksalmon = "E9967A",
  darkseagreen = "8FBC8F",
  darkslateblue = "483D8B",
  darkslategray = "2F4F4F",
  darkslategrey = "2F4F4F",
  darkturquoise = "00CED1",
  darkviolet = "9400D3",
  deeppink = "FF1493",
  deepskyblue = "00BFFF",
  dimgray = "696969",
  dimgrey = "696969",
  dogerblue = "1E90FF",
  firebrick = "B22222",
  floralwhite = "FFFAF0",
  forestgreen = "228B22",
  gainsboro = "DCDCDC",
  ghostwhite = "F8F8FF",
  gold = "FFD700",
  goldenrod = "DAA520",
  greenyellow = "ADFF2F",
  grey = "808080",
  honeydew = "F0FFF0",
  hotpink = "FF69B4",
  indianred = "CD5C5C",
  indigo = "4B0082",
  ivory = "FFFFF0",
  khaki = "F0E68C",
  lavender = "E6E6FA",
  lavenderblush = "FFF0F5",
  lawngreen = "7CFC00",
  lemonchiffon = "FFFACD",
  lightblue = "ADD8E6",
  lightcoral = "F08080",
  lightcyan = "E0FFFF",
  lightgoldenrodyellow = "FAFAD2",
  lightgray = "D3D3D3",
  lightgreen = "90EE90",
  lightgrey = "D3D3D3",
  lightpink = "FFB6C1",
  lightsalmon = "FFA07A",
  lightseagreen = "20B2AA",
  lightskyblue = "87CEFA",
  lightslategray = "778899",
  lightslategrey = "778899",
  lightsteelblue = "B0C4DE",
  lightyellow = "FFFFE0",
  limegreen = "32CD32",
  linen = "FAF0E6",
  magenta = "FF00FF", -- same as fuchsia
  mediumaquamarine = "66CDAA",
  mediumblue = "0000CD",
  mediumorchid = "BA55D3",
  mediumpurple = "9370DB",
  mediumseagreen = "3CB371",
  mediumslateblue = "7B68EE",
  mediumspringgreen = "00FA9A",
  mediumturquoise = "48D1CC",
  mediumvioletred = "C71585",
  midnightblue = "191970",
  mintcream = "F5FFFA",
  mistyrose = "FFE4E1",
  moccasin = "FFE4B5",
  navajowhite = "FFDEAD",
  oldlace = "FDF5E6",
  olivedrab = "6B7E23",
  orangered = "FF4500",
  orchid = "DA70D6",
  palegoldenrod = "EEE8AA",
  palegreen = "98FB98",
  paleturquoise = "AFEEEE",
  palevioletred = "DB7093",
  papayawhip = "FFEFD5",
  peachpuff = "FFDAB9",
  peru = "CD853F",
  pink = "FFC0CB",
  plum = "DDA0DD",
  powderblue = "B0E0E6",
  rosybrown = "BC8F8F",
  royalblue = "4169E1",
  saddlebrown = "8B4513",
  salmon = "FA8072",
  sandybrown = "F4A460",
  seagreen = "F4A460",
  seashell = "FFF5EE",
  sienna = "A0522D",
  skyblue = "87CEEB",
  slateblue = "6A5ACD",
  slategray = "708090",
  slategrey = "708090",
  snow = "FFFAFA",
  springgreen = "00FF7F",
  steelblue = "4682B4",
  tan = "D2B48C",
  thistle = "D8BFD8",
  tomato = "FF6347",
  turquoise = "40E0D0",
  violet = "EE82EE",
  wheat = "F5DEB3",
  whitesmoke = "F5F5F5",
  yellowgreen = "9ACD32",
  rebeccapurple = "663399",
}

-- do this on file load
for name, hexstring in pairs(defaults) do
  addDefault(name, hexstring)
end

return colorFactory
