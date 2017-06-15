-- example love2d program

local cf = require "colorFactory"

local timer = 0

local font = love.graphics.newFont(24)

love.window.setMode(370, 30)

function love.update(dt)
  timer = timer + dt*25
  timer = timer % 255
end

function love.draw()
  love.graphics.setFont(font)
  local mx = love.mouse.getPosition()
  local sx = love.graphics.getDimensions()
  local color = cf.HSL255(math.floor(timer/10)*10,
    150,
    200
  )
  -- from love 11 and onwards this conversion will be unnecessary
  love.graphics.setColor(cf.to255(color))
  love.graphics.print "I'm colored text!"
  if color == cf.HSL255(150, 150, 200) then
    love.graphics.print "                          so am I"
  end
  love.graphics.setColor(cf.to255(cf.silver()))
  love.graphics.print "I'm"
  love.graphics.setColor(cf.to255(cf.hex("FFC0CB")))
  love.graphics.print "                        !"
end

