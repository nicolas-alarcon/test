 io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest", "nearest")

require 'utils'
require 'input'
require 'map'

function love.load()
	player = { x = 128, y = 400, a = 90, speed_w = 5, speed_r = 180 }
	player.dx = math.cos(ToRad(player.a))
	player.dy = -math.sin(ToRad(player.a))
	raycaster = require 'raycaster'()
end

function love.update(dt)
	Input(player,dt)
end

function love.draw()
	raycaster:draw(player,true)

	-- Debug
	love.graphics.setColor(1,1,1)
	love.graphics.print(
		"DEBUG"
		.."\n--------------"
		.."\nFPS: "..love.timer.getFPS(), 778, 10)
end

function love.keypressed(key, scancode, isrepeat)
	-- Reset
	if key == 'escape' then love.event.quit('restart') end
end