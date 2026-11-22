# Bundled scripts (worked examples from Keep an Eye; rename before use)

Copy what you need into your game project's `tools/` and `tests/` folders. Each script starts with a
comment saying what to rename.

| File | Use |
|---|---|
| `trailer/trailer_shot.gd` | In-engine trailer shot director (Godot movie writer). Keep the helpers (`_aim`, `_aim_angles`, `_angles_to`, `_move`, `_sweep`, `_shadow_for_x`, `_spawn_rings`, `_tick`) and write new `_shot_*` functions for your game. The `v_*` shots are Keep an Eye examples: crane-up reveal, eye lock, shadow killing ground/goat/tree with falling leaves, creatures rising, final hero shot. Rename the scene fields it reads. |
| `trailer/edit_trailer_v2.py` | ffmpeg edit: CUTS list, x3 nearest upscale, grade + vignette, day cards, logo over the last shot, score + hit cue, optional separate build/hit music with climax alignment. Replace shot names, card art, logo and music paths and the timing constants. |
| `build/package_game.ps1` + `build/launcher.cs` | Portable Windows package: exports the .pck, copies the Godot runtime as `runtime/engine.exe`, compiles a GUI launcher exe with the game icon, writes a README and a ZIP. Usage: `./tools/package_game.ps1 -GameName "My Game" -GameFileName "MyGame"`. Godot path: `-GodotPath` or the `GODOT_PATH` environment variable (keep the matching `_console.exe` beside it). The packager fills the names into `launcher.cs` for you; edit the controls text inside the script. |
| `example_smoke_test.gd` | Pattern for a headless SceneTree test: instantiate `scenes/main.tscn`, drive it with `call()`, `_check()` conditions, print `PASS <name>`, `quit(1)` on failure, a hard deadline timer. |
| `outline_text.gd` | Turns a line of text into one SVG path with any TTF/OTF (variable fonts via a weight argument). Used for logos and title art: `godot --headless -s outline_text.gd -- FONT SIZE TRACKING_EM "TEXT" OUT.json [WEIGHT]`. |

Requirements: Godot 4.x, PowerShell and the .NET Framework C# compiler (Windows), Python 3 with
Pillow and numpy, ffmpeg on PATH.
