import time
import sokol.audio

struct Player {
mut:
	sample_rate int
	samples     []f32
	pos         int
	finished    bool
}

fn new_player() &Player {
	mut player := &Player{}
	player.init()
	return player
}

fn audio_player_callback(mut buffer &f32, num_frames int, num_channels int, mut p Player) {
	unsafe { vmemset(buffer, 0, num_channels * num_frames * 4) }
	if p.finished {
		return
	}
	ntotal := num_channels * num_frames
	nremaining := p.samples.len - p.pos
	nsamples := if nremaining < ntotal { nremaining } else { ntotal }
	if nsamples <= 0 {
		p.finished = true
		return
	}
	unsafe { vmemcpy(buffer, &p.samples[p.pos], nsamples * 4) }
	p.pos += nsamples
}

fn (mut p Player) init() {
	audio.setup(
		sample_rate:        44100
		num_channels:       1
		stream_userdata_cb: audio_player_callback
		user_data:          p
	)
	p.sample_rate = audio.sample_rate()
}

fn (mut p Player) stop() {
	audio.shutdown()
	p.finish()
}

fn (mut p Player) play_wav_file(fpath string) ! {
	samples := read_wav_file_samples(fpath)!
	p.finish()
	p.samples << samples
	spawn fn (mut p Player) {
		for !p.finished {
			time.sleep(2 * time.millisecond)
		}
		p.finish()
	}(mut p)
}

fn (mut p Player) finish() {
	p.finished = false
	p.samples.clear()
	p.pos = 0
}
