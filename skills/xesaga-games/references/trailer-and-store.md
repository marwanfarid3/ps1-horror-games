# Trailer and store page

## Trailer (made from inside the game)
Shots are recorded from the real game with Godot's movie writer, one shot per run, then cut
with ffmpeg. Keep an Eye's versions are the reference implementation:
- `tools/trailer/trailer_shot.gd` — shot director. Each `_shot_<name>()` sets day/time/state,
  moves the camera with eased paths (`_aim_angles`, `_angles_to`), triggers events on exact frames,
  mutes the Music bus (the score is laid in the edit) and keeps game SFX.
  Run: `godot --path . --write-movie OUT.avi --fixed-fps 30 --script res://tools/trailer/trailer_shot.gd -- --shot NAME --seconds S`
- `tools/trailer/edit_trailer_v2.py` — a CUTS list (shot, start, seconds kept, game-sound gain, fade),
  nearest-neighbour x3 upscale to 1920x1080, colour grade + vignette, day cards from `art/dayN.png`,
  title logo over the last shot, score bed + hit cue, loudnorm -15 LUFS.
- Trim ~0.35 s from the start of every shot: the first frames show the title menu.

### Trailer rules (learned the hard way)
- **Never show an ending** in a trailer, GIF, screenshot or store image. Endings are spoilers.
- **Respect the world's physics.** Keep an Eye's hand rises out of the sea; an early teaser lifted it
  12 m so it floated, and that was rejected. Keep every object at its real in-game placement.
- **Open strong and specific.** Example that was approved: camera starts on the grass at ground level,
  tilts and rises to the horizon while the hand comes up out of the water and the eye appears.
- **Show the stakes on camera**: the ground dying as the shadow passes, an animal falling, a tree losing
  its leaves, creatures rising. If the game kills things, film them dying, not just the aftermath.
- **Strong montage on a musical structure**: calm (0-13 s) → build with faster cuts → the scream →
  1.5-2 s of true silence → a hit on the hero shot → title. ~50 s total.
- **Music**: if the creator's pack doesn't fit, generate a score with ElevenLabs Music
  (`eleven_music_v2_5`, instrumental) as two pieces: a ~40 s build and a ~9 s hit + tail.
  Measure the loudness envelope; if the build peaks early, offset it so its climax lands on the
  silence cut (`edit_trailer_v2.py SHOTS OUT BUILD HIT <peak-in-build> <hit-lead>`).
- Review every shot as a contact sheet (ffmpeg `select=not(mod(n\,20)),tile=4x2`) before cutting.
  Fix occlusion (trees in front of the subject), subjects too small, or moments the camera misses.

## Store page (itch.io first, Steam later)
itch.io is free; Steam costs $100 (recouped after $1,000 sales). Prepare everything in `store/itch/`
(add `store/.gdignore` so Godot doesn't import it):
- `cover-630x500.png` (hero shot + title art), `banner-960x300.png`
- `screenshots/` 6 × 1920×1080 (render at 640×360, upscale ×3 nearest) — gameplay only, no endings
- `gifs/` 3 × ~480 px wide, 12 fps, < 3 MB, cut from the trailer
- `PAGE_TEXT.md`: title, URL slug, tagline, description (hook, story, features, controls, how to run,
  "More info → Run anyway" note for the unsigned exe, system requirements, "Made by XeSaga, a Xeravon studio"),
  genre, 10 tags, content warning, page colours
- `HOW_TO_UPLOAD.md` in the creator's language, field by field, stopping before the game file upload
  until the build is final. Release status "In development", visibility "Draft" until launch.

### AI disclosure (be honest)
itch.io asks. Answer Yes and list what applies: Tripo models (adapted in Blender), ElevenLabs sounds,
screams or music, code written with an AI assistant. Let the creator decide about text they wrote.

The creator signs up and handles passwords, captchas and payments themselves; prepare the files and the
guide, don't fill those in.
