# Color factory

This is a utility to manage and remember tables of colors, targeted at love2d.

## Usage

```lua
-- require the library as usual
local cf = require "colorFactory"
...
-- no need to remember if black is all 255 or all 0
love.graphics.setColor(cf.BLACK())
...
function love.draw
    -- this color is remembered internally for next time so
    -- the table is simply retrieved
    love.graphics.setColor(cf.RGB255(50, 255, 150))
end
...
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
```
All CSS colors up to and including rebeccapurple are implemented as default named colors to this library and the functions can be called by using the relevant name (in all lower or all upper case)

```lua
cf.BLACK(); cf.silver(); cf.white();
if cf.grey() == cf.GRAY() then
  -- this is true
end
```

## Methods

```lua
colorFactory.RGB(red, green, blue, alpha)
```

RGB takes red, green, blue and optional alpha values bounded by 0 and 1 as input to retrieve the appropriate table of colors, which will have numbered entries 1 to 4 corresponding to the input. This is so you can then hand the table directly to love.grahpics.setColor() and apply it.


```lua
colorFactory.RGB255(r, g, b, a)
```

RGB255 takes input bounded by 0 and 255, as love2d used to work prior to 11. The input does not have to be integers. RGB255 then calls RGB and behaves the same.

```lua
colorFactory.HSL(h, s, l, a)
```

HSL uses Hue/Saturation/Lightness/Alpha instead of the RGBA color scheme, and converts each 0..1 input to the RGBA color scheme to then use internally as RGB works.

```lua
colorFactory.HSL255(r, g, b, a)
```

HSL255 converts the 0 to 255 input down to 0 to 1 and then calls HSL just like RGB255.


```lua
colorFactory.hex(hexstring)
```

hex takes a 6 or 8 digit string of hex characters, such as "FFFFFF" or "FFFFFFFF" as input. It converts this to input for RGB255 and calls that.

```lua
colorFactory.white
```

This is one of [many](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#Color_keywords) functions with identical names to the CSS colors that will call RGB255 with the rgba values of the hex code when used. Note that you will need `()` at the end of the function to actually call it, `cf.white` will give you the function, not the value it returns. If a hexcode in this project does not match the hex code listed on MDN that is a bug and you should make an issue or pull request.

### Very misc methods

```lua
colorFactory.hexConvert(hexstring)
```

This converts a hex string and returns the r, g, b, a values as numbers rather than a table. The hex conversion is probably quite expensive compared to most of the other ways to define a color so you may want to use this method to avoid performing the hex conversion every frame, by recording the rgba numbers you want and then using RGB255 each frame to get the associated table.

```
colorFactory.to255(color)
```

This multiplies all the 4 values in the color table by 255 to return a new table that will work in love2d 10 and earlier for drawing. If you are using love2d 11 or later this should be irrelevant.

## Notes

The colors internally stored are in a weak table so they do not stay around forever if no references to them are maintained. When you try to get a table for a color you will get back the table that already exists if it does, which means you can use == to compare color tables without the need of meta tables and checking all fields. This also means modifying a color returned by the methods in this module (excluding to255) will modify the color stored by this module and affect all uses of that color!

## License

This library is under the MIT license.
