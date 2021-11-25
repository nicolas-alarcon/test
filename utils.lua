function round(n)
	return math.floor(n+0.5)
end

function ToRad(a)
	return a * math.pi / 180.0
end

function FixAngle(angle)
	local a = angle
	if a > 360 then a = a - 360 end
	if a < 0 then a = a + 360 end
	return a
end

function Distance(ax, ay, bx, by, a)
	return math.cos(ToRad(a))*(bx-ax) - math.sin(ToRad(a))*(by-ay)
end

-- function ToDeg(a)
-- 	return a * 180.0 / math.pi
-- end

-- function FixAngleRad(angle)
-- 	local a = angle
-- 	if a > math.pi * 2 then a = a - math.pi * 2 end
-- 	if a < 0 then a = a + math.pi * 2 end
-- 	return a
-- end
