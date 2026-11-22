# ps1-horror-games

A Claude skill for making **short, atmospheric indie horror games** in Godot 4: the kind you finish in
under an hour, set in one place, built around one ordinary task while something huge and wrong closes in,
in a low-res PS1 look. It covers the genre craft (finding the idea, the dread ladder, scares that are
earned, sound, writing, length and price) and the full production workflow the author used to ship
**Keep an Eye** (a 5-day horror story on an island watched by a giant hand): game plan, look prototype,
tuning file, headless tests, portable Windows builds, in-engine trailers cut with ffmpeg, and honest
itch.io/Steam pages. It makes original games in the genre, not copies of existing ones.

## What's inside

| Path | What it is |
|---|---|
| `skills/ps1-horror-games/SKILL.md` | The skill: studio setup, the nine-step workflow, studio rules, style DNA |
| `skills/ps1-horror-games/references/horror-playbook.md` | The genre craft: idea formula, dread ladder, scare techniques, look, sound, writing, length, price |
| `skills/ps1-horror-games/references/style-bible.md` | Look, UI, audio and narrative techniques, incl. a soft-tension variant |
| `skills/ps1-horror-games/references/godot-architecture.md` | Project layout, saves, audio director, tests, packaging, versioning |
| `skills/ps1-horror-games/references/asset-pipeline.md` | Tripo + Blender models, procedural textures, audio, fonts, housekeeping |
| `skills/ps1-horror-games/references/trailer-and-store.md` | In-engine trailers, itch.io page kit, AI disclosure |
| `skills/ps1-horror-games/references/brand.md` | How to set up a studio brand, how to make your own marks, palette and credits line |
| `skills/ps1-horror-games/assets/` | Game plan template |
| `skills/ps1-horror-games/scripts/` | Trailer shot director, trailer edit script, Windows packager and launcher, smoke-test pattern, text outliner |
| `.claude-plugin/` | Plugin and marketplace manifests |

## Install

**a) Claude Code plugin**

```
/plugin marketplace add marwanfarid3/ps1-horror-games
/plugin install ps1-horror-games@ps1-horror-games
```

**b) Manual (Claude Code skill)**: copy `skills/ps1-horror-games` into `~/.claude/skills/`.

**c) claude.ai**: download `ps1-horror-games.skill` from this repo's Releases and upload it under
Settings, Capabilities, Skills.

**d) Other AI tools**: give the assistant `skills/ps1-horror-games/SKILL.md` plus the files in `references/`
as context.

On first use the skill asks for your studio name, the language to talk to you in, your Godot path, your
fonts folder and whether you have a brand kit.

## Example prompts

- "I have an idea for a short sad story game about a lighthouse. Plan it the PS1 horror way."
- "Add a night-time watcher mechanic and write a smoke test for it."
- "Package the game as a portable Windows ZIP."
- "Make a 50-second in-engine trailer with no endings shown."
- "Prepare my itch.io page: cover, screenshots, GIFs, description and AI disclosure."
- "Help me design a studio logo with one central image."

## Requirements

- Godot 4.x (the tools are written for Windows; set `GODOT_PATH` or pass your Godot executable)
- Windows PowerShell and the .NET Framework C# compiler for `package_game.ps1`
- Python 3 with Pillow and numpy, and ffmpeg on PATH, for textures and trailer editing
- Optional: Blender (model adaptation) and Chrome (store page work)
- Optional paid services mentioned in the workflow: Tripo, ElevenLabs

## About

Made by Marwan Farid; the workflow was learned from building the game Keep an Eye.

## License

MIT, see [LICENSE](LICENSE). The brand guidance in `references/brand.md` is a method; make your own marks.
