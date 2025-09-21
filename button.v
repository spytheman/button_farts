module main

import gg
import rand
import math.vec

type Vec2 = vec.Vec2[f32]

fn rint(volume int) int {
	return -volume + rand.intn(volume * 2) or { 0 }
}

struct Button {
mut:
	pos     Vec2     = Vec2{400, 300}
	size    Vec2     = Vec2{400, 100}
	label   string   = 'Click me!'
	color   gg.Color = gg.white
	shaking int
}

fn (btn &Button) contains(x f32, y f32) bool {
	o := btn.size.div_scalar(2)
	return x > btn.pos.x - o.x && x < btn.pos.x + o.x && y > btn.pos.y - o.y && y < btn.pos.y + o.y
}

fn (mut btn Button) clicked(e &gg.Event) bool {
	inside := btn.contains(e.mouse_x, e.mouse_y)
	if e.typ == .mouse_move {
		if inside {
			btn.color = gg.light_green
		} else {
			btn.color = gg.white
		}
	}
	if inside {
		if e.typ == .mouse_down {
			return true
		}
	}
	return false
}

fn (mut btn Button) draw(ctx &gg.Context) {
	cx, cy := btn.pos.x - btn.size.x / 2, btn.pos.y - btn.size.y / 2
	mut tx, mut ty := cx, cy
	if btn.shaking > 0 {
		btn.shaking--
		tx += rint(5)
		ty += rint(5)
	}
	ctx.draw_rounded_rect_filled(tx, ty, btn.size.x, btn.size.y, 10, gg.dark_gray)
	ctx.draw_rounded_rect_filled(tx + 3, ty + 3, btn.size.x - 6, btn.size.y - 6, 10, btn.color)
	ctx.draw_text(int(btn.pos.x), int(btn.pos.y) - 10, btn.label,
		color: gg.black
		size:  20
		align: .center
	)
}
