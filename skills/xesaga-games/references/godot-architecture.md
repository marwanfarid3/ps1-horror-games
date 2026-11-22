# Godot architecture, tests and packaging

Engine: **Godot 4.x** (Keep an Eye used 4.7.2) at your Godot path (keep the `_console.exe`
wrapper beside it for headless runs). GDScript only. No autoloads, no plugins unless the creator agrees.

## Project setup
`project.godot`: main scene `res://scenes/main.tscn` (the only scene), `config/version="X.Y.Z"`,
viewport 640×360, window override 1280×720, stretch mode `viewport`, aspect `keep`,
`rendering_method="gl_compatibility"` for desktop and mobile, default texture filter nearest.

Folders:
```
scenes/main.tscn          one scene; everything else is built in code
scripts/main.gd           loop, input, HUD, menus, notes; _ready calls the _create_* builders in order
scripts/game/*.gd         an inheritance chain, one concern per file:
                          game_base (state, tuning, helpers, post shader)
                          -> world builder (terrain, props, animals, player)
                          -> world life (light, creatures, sound mix)
                          -> rules (work, items, sleep, death, saves)
                          -> endings -> main.gd
scripts/audio_director.gd buses, manifest groups, music crossfades, ambience layers
data/tuning.json          every gameplay number (flat dict; per-day arrays)
data/*.json               cue timings (e.g. ending_audio.json)
audio/pack/               creator's audio pack + audio_manifest.json (never edited)
audio/derived/            processed copies made by tools/
art/, models/, models/source/*.blend, shaders/
tools/                    python/Blender/ps1 generators and adapters
tests/                    *_smoke.gd (headless) and render_*.gd (screenshots)
docs/                     decisions.md, UI_DIRECTION.md, VALIDATION.md, ASSET_CREDITS.md, BUILD_NOTES.md
store/itch/ (+ store/.gdignore), trailer/ (git-ignored outputs)
```
Every script starts with a `##` one-line purpose comment. `.gitignore`: `.godot/`, `.devcheck/`, `build/`,
`*.zip`, `*.mp4`, `_to_delete/`.

## State and saves
- Read tuning with `tuning.get("key", default)`.
- Checkpoint at dawn to `user://dawn.json`; death restores that dawn; finishing an ending deletes it.
  Old saves migrate (never crash on an older format).
- Settings in `user://settings.cfg`; a playtest diary in `user://playtest_log.txt` (start, sleep with what
  was eaten/drunk, deaths with cause, key progress, endings, with day/clock/health at that moment).

## Audio director pattern
Manifest: `{files:{id:{path, group, category, bus, loop, positional, duration_s, suggested_gain_db}},
groups:{name:[ids]}}`. `play(group, gain, at)` picks a variant without immediate repeats (3D if
`positional`); `music(id, fade, db)` crossfades two players; `layer(id, db, delta)` for ambience beds.
Buses: Music, Ambience, SFX, UI, Movement, Animals + a MusicDynamics bus for ducking + a CinematicGate.

## Tests
- `tests/<feature>_<version>_smoke.gd`: `extends SceneTree`, `_initialize` → `call_deferred("_run")`,
  a 40-60 s deadline timer that quits with 1, instantiate `res://scenes/main.tscn`, drive state with
  `call("_method")`, `_check(cond, msg)`, print `PASS <what>` lines, `quit(0)` / `quit(1)`.
  Run: `godot --headless --path . --script res://tests/x_smoke.gd`.
- `tests/render_*.gd`: real renderer (not headless), set state, aim the camera, wait a few frames and
  `RenderingServer.frame_post_draw`, then `root.get_texture().get_image().save_png()` into
  `res://.devcheck/<prefix>-<label>.png` (or `--output-prefix`). Open and look at the images.
- Run tests with isolated user data (point APPDATA at `.devcheck/...`) so the creator's saves are untouched.
- `docs/VALIDATION.md`: header with the version, every test that ran, visual checks, and a **Limits**
  section ("not a human playthrough"). Keep older versions below.
- Fail the run on any `SCRIPT ERROR:`, `Parse Error:` or `ERROR:` in the output.

## Packaging (portable Windows build)
`tools/package_game.ps1` (template in `scripts/build/`, run with `-GameName` and `-GameFileName`): isolated APPDATA → `--headless --editor --quit`
(import) → `--export-pack "Windows Portable" <Game>.pck` → copy the engine to `runtime/engine.exe` →
compile `launcher.cs` with `csc.exe /target:winexe /win32icon:art/icon.ico` → run the pack smoke test
and write engine licences → `READ ME.txt` → `build-manifest.json` (version, sha256) → ZIP.
Export preset include filter: `data/*.json, audio/pack/audio_manifest.json`; exclude docs, tests, tools,
models/source, store, *.blend, *.md. A "Windows Release" preset with an embedded pck needs Godot's
export templates (≈1 GB download: ask first).

## Versions and handover
- Version = `X.Y.Z` in project.godot, README title "<Game> — Windows playtest X.Y.Z", one paragraph per
  version at the top of the README starting "Version X.Y.Z …" describing what changed for the player.
- Commit message `X.Y.Z: summary`. Corrections the creator gives go into `docs/decisions.md` (dated).
- After each version: tell the creator, in their language, what changed, where the build is, and 3-6 things to try by hand.
