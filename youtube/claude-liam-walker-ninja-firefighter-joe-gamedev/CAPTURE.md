# CAPTURE

- Engine: Godot 4.7.2.stable.official (macOS), Movie Maker: `godot --path <copy> -s res://film_capture.gd --write-movie <take>.avi --fixed-fps 30 -- take=<route|fire|fall|muted>`.
- Copy: `git archive 241c3f2` of `walker-ninja-firefighter-joe/godot` + `override.cfg` (window 3840×2160) + `film_capture.gd`; `--import` once.
- Takes (all exit 0 with their assertions): route (25.7 s, COMPLETE, 0 deaths), fire (4.2 s, 1 fire death then PLAYING), fall (8.6 s, "You fell."), muted (15.0 s, both buses muted).
- Video MJPEG 3840×2160 @ 30 fps; audio PCM 48 kHz stereo (the game's own mix). One- or two-sample peaks at 0 dBFS (inaudible).
