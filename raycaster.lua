RES = 1
SCALE = 2
NRAYS = 64
LINEH_R = 384
LINEO_R = 192
LINEX = 768
TEXS = 32

require 'textures'

local _PATH = (...):match('^(.*[%./])[^%.%/]+$') or ''

local Raycaster = {}
Raycaster.__index = Raycaster

local function new()
	return setmetatable({
		 
		}, Raycaster)
end

function Raycaster:draw(p,map)

	if map then
		-- Map
		love.graphics.setBackgroundColor(.3,.3,.3)
		for y = 0, mapY-1  do
			for x = 0, mapX-1 do
				love.graphics.setColor(unpack(mapW[y*mapX+x+1] > 0 and {1,1,1} or {0,0,0}))
				love.graphics.rectangle('fill', x*mapS + 1, y*mapS + 1, mapS - 1, mapS - 1)
			end
		end	
	end
	
	local mx, my, mp, dof, vx, vy, rx, ry, xo, yo, disV, disH
	local ra = FixAngle(p.a+(NRAYS/2))
	
	for r = 0, (NRAYS*RES)-1 do

		local vmt, hmt = 0, 0
		
		-- Check Vertical Lines
		local Tan = math.tan(ToRad(ra))
		dof, disV = 0, 100000
		if math.cos(ToRad(ra)) > .1 then
			rx = bit.lshift(bit.rshift(math.ceil(p.x),6),6)+mapS
			ry = (p.x-rx)*Tan+p.y
			xo = mapS
			yo = -xo*Tan
		elseif math.cos(ToRad(ra)) < -.1 then
			rx = bit.lshift(bit.rshift(math.ceil(p.x),6),6)-.001
			ry = (p.x-rx)*Tan+p.y
			xo = -mapS
			yo = -xo*Tan
		else
			xo, yo = 0, 0
			rx, ry, dof = p.x, p.y, mapX
		end

		-- Loop
		while dof < mapX do
			mx = bit.rshift(math.floor(rx),6)+1
			my = bit.rshift(math.floor(ry),6)+1
			mp = ((my-1)*mapX+mx)
			if mp > 0 and mp < mapX*mapY and mapW[mp] > 0 then
				vmt = mapW[mp]-1
				dof = mapX
				disV = math.cos(ToRad(ra))*(rx-p.x) - math.sin(ToRad(ra))*(ry-p.y)
			else
				rx = rx + xo
				ry = ry + yo
				dof = dof + 1
			end
		end
		vx, vy = rx, ry
		
		-- Check Horizontal Lines
		Tan = 1/Tan
		dof, disH = 0, 100000
		if math.sin(ToRad(ra)) > .1 then
			ry = bit.lshift(bit.rshift(math.ceil(p.y),6),6)-.001
			rx = (p.y-ry)*Tan+p.x
			yo = -mapS
			xo = -yo*Tan
		elseif math.sin(ToRad(ra)) < -.1 then
			ry = bit.lshift(bit.rshift(math.ceil(p.y),6),6)+mapS
			rx = (p.y-ry)*Tan+p.x
			yo = mapS
			xo = -yo*Tan
		else
			xo, yo = 0, 0
			rx, ry, dof = p.x, p.y, mapY
		end
		-- Loop
		while dof < mapY do
			mx = bit.rshift(math.floor(rx),6)+1
			my = bit.rshift(math.floor(ry),6)+1
			mp = ((my-1)*mapX+mx)
			if mp > 0 and mp < mapX*mapY and mapW[mp] > 0 then
				hmt = mapW[mp]-1
				dof = mapY
				disH = math.cos(ToRad(ra))*(rx-p.x) - math.sin(ToRad(ra))*(ry-p.y)
			else
				rx = rx + xo
				ry = ry + yo
				dof = dof + 1
			end
		end
		
		-- Hit
		local shade = 1
		if disV<disH then
			rx = vx
			ry = vy
			disH = disV
			hmt = vmt
			shade = .5
		end
		
		-- Line Settings
		local ca = FixAngle(p.a-ra)
		disH = disH*math.cos(ToRad(ca))
		local lineH = round((mapS*LINEH_R)/disH)
		local ty_step = TEXS/lineH
		local ty_off = 0

		if lineH > LINEH_R then
			ty_off = (lineH-LINEH_R)/2
			lineH = LINEH_R
		end
		local lineO = LINEO_R - bit.rshift(lineH,1)

		if map then
			love.graphics.setColor(0,1,0)
			love.graphics.setLineWidth(1)
			love.graphics.line(p.x, p.y, rx, ry)
		end
		
		-- Drawing Preparation
		local tx = 1
		local ty = ty_off*ty_step + hmt*(TEXS) + 1
		if shade == 1 then
			tx = tx + math.floor(rx/2)%TEXS
			if ra > 180 then tx = (TEXS+1) - tx end
		else
			tx = tx + math.floor(ry/2)%TEXS
			if ra > 90 and ra < 270 then tx = (TEXS+1) - tx end
		end
		
		love.graphics.push()
		love.graphics.scale(SCALE)
		
		for y = 0, lineH - 1 do
			-- Draw Walls
			local c = Textures[math.floor(ty-1)*TEXS +tx]*shade
			if hmt == 0 then love.graphics.setColor(c,c/2,c/2) end
			if hmt == 1 then love.graphics.setColor(c,c,c/2) end
			if hmt == 2 then love.graphics.setColor(c/2,c/2,c) end
			if hmt == 3 then love.graphics.setColor(c/2,c,c/2) end
			love.graphics.rectangle('fill',
				r*(8/RES)+(LINEX/SCALE), y+lineO, 8, 8)
			ty = ty + ty_step
		end

		for y = lineO+lineH, LINEH_R - 1 do
			-- Draw Floors
			local dy, deg, raFix = y-(LINEH_R/2), ToRad(FixAngle(ra)), math.cos(ToRad(FixAngle(p.a-ra)))
			tx = p.x/2 + math.cos(deg)*LINEO_R*TEXS/dy/raFix
			ty = p.y/2 - math.sin(deg)*LINEO_R*TEXS/dy/raFix
			local mp = mapF[math.min((math.floor(ty/32)*mapX+math.floor(tx/32)+1),mapX*mapY)]*32*32
			local c = Textures[bit.band(math.floor(ty),31)*32 + bit.band(math.floor(tx),31) + mp +1]*.7
			love.graphics.setColor(c,c,c)
			love.graphics.rectangle('fill', r*(8/RES)+(LINEX/SCALE), y, 8, 8)
			-- Draw Ceiling
			mp = mapC[math.min((math.floor(ty/32)*mapX+math.floor(tx/32)+1),mapX*mapY)]*32*32
			c = Textures[bit.band(math.floor(ty),31)*32 + bit.band(math.floor(tx),31) + mp +1]
			love.graphics.rectangle('fill', r*(8/RES)+(LINEX/SCALE), LINEH_R-y, 8, 8)
  		end

		love.graphics.pop()

		-- Increment Angle / Next Ray
		ra = FixAngle(ra-(1/RES))
	end

	if map then
		-- Player
		love.graphics.setColor(1,1,1)
		love.graphics.ellipse('fill', p.x, p.y, 4, 4)
	end

end

return setmetatable({new = new},{__call = function(_, ...) return new(...) end})