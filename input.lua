function Input(p,dt)
	-- Rotating Left
	if love.keyboard.isDown('q') then
		p.a = p.a + dt * p.speed_r
		p.a = FixAngle(p.a)
		p.dx, p.dy = math.cos(ToRad(p.a)), -math.sin(ToRad(p.a))
	end
	-- Rotating Right
	if love.keyboard.isDown('d') then
		p.a = p.a - dt * p.speed_r
		p.a = FixAngle(p.a)
		p.dx, p.dy = math.cos(ToRad(p.a)), -math.sin(ToRad(p.a))
	end
	-- Collision Management
	local xo, yo = 0, 0
	if p.dx < 0 then xo = -20 else xo = 20 end
	if p.dy < 0 then yo = -20 else yo = 20 end
	local ipx, ipx_add_xo, ipx_sub_xo = math.ceil(p.x/64),
	math.ceil((p.x+xo)/64), math.ceil((p.x-xo)/64)
	local ipy, ipy_add_yo, ipy_sub_yo = math.ceil(p.y/64),
	math.ceil((p.y+yo)/64), math.ceil((p.y-yo)/64)
	-- Moving Forward
	if love.keyboard.isDown('z') then
		if mapW[(ipy-1)*mapX+ipx_add_xo] == 0 then p.x = p.x + p.dx * p.speed_w end
		if mapW[(ipy_add_yo-1)*mapX+ipx] == 0 then p.y = p.y + p.dy * p.speed_w end
	end
	-- Moving Backward
	if love.keyboard.isDown('s') then
		if mapW[(ipy-1)*mapX+ipx_sub_xo] == 0 then p.x = p.x - p.dx * p.speed_w end
		if mapW[(ipy_sub_yo-1)*mapX+ipx] == 0 then p.y = p.y - p.dy * p.speed_w end
	end
	-- Open Door
	if love.keyboard.isDown('e') then
		local xo, yo = 0, 0
		if p.dx < 0 then xo = -25 else xo = 25 end
		if p.dy < 0 then yo = -25 else yo = 25 end
		local ipx, ipx_add_xo, ipx_sub_xo = math.ceil(p.x/64),
		math.ceil((p.x+xo)/64), math.ceil((p.x-xo)/64)
		local ipy, ipy_add_yo, ipy_sub_yo = math.ceil(p.y/64),
		math.ceil((p.y+yo)/64), math.ceil((p.y-yo)/64)
		if mapW[(ipy_add_yo-1)*mapX+ipx_add_xo] == 4 then mapW[(ipy_add_yo-1)*mapX+ipx_add_xo] = 0 end
	end
end