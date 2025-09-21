import os
import gg
import rand

@[heap]
struct Game {
mut:
	ctx     &gg.Context = unsafe { nil }
	btn     Button
	clicks  int
	farts   int
	message string
	sounds  []string
	player  &Player = new_player()
}

fn (mut g Game) frame() {
	g.ctx.begin()
	g.btn.draw(g.ctx)
	g.ctx.draw_text(int(g.btn.pos.x), int(g.btn.pos.y) + 80, g.message,
		color: gg.white
		size:  40
		align: .center
	)
	g.ctx.end()
}

fn (mut g Game) event(e &gg.Event, _ voidptr) {
	if e.typ == .key_down && e.key_code == .escape {
		g.ctx.quit()
	}
	if g.btn.clicked(e) {
		g.clicks++
		g.btn.label = 'Clicks: ${g.clicks}'
		g.btn.shaking = 15
		if rand.intn(100) or { 0 } < 50 {
			if s := rand.element(g.sounds) {
				g.farts++
				g.player.play_wav_file(s) or {}
				g.message = 'Farts: ${g.farts}'
			}
		}
	}
}

fn main() {
	mut g := &Game{}
	g.sounds = os.walk_ext(@DIR, '.wav').sorted()
	g.ctx = gg.new_context(
		window_title: 'Button farts'
		width:        800
		height:       600
		bg_color:     gg.black
		sample_count: 2
		frame_fn:     g.frame
		event_fn:     g.event
		user_data:    g
	)
	g.ctx.run()
}
