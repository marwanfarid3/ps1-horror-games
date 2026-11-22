# xesaga-games

The workflow XeSaga used to build **Keep an Eye**, packaged as a Claude skill. It teaches Claude how to
plan, build, test, package, trail and publish a short, story-driven indie game in Godot 4: a game plan
with confirmed/proposed/TBD tags, a look prototype first, every number in a tuning file, headless smoke
tests, portable Windows builds, in-engine trailers cut with ffmpeg, and honest itch.io pages. Keep an
Eye (a 5-day first-person horror story on an island watched by a giant hand) is the worked example.

## What's inside

| Path | What it is |
|---|---|
| `skills/xesaga-games/SKILL.md` | The skill: studio setup, the nine-step workflow, studio rules, style DNA |
| `skills/xesaga-games/references/style-bible.md` | Look, UI, audio and narrative techniques, incl. a soft-tension variant |
| `skills/xesaga-games/references/godot-architecture.md` | Project layout, saves, audio director, tests, packaging, versioning |
| `skills/xesaga-games/references/asset-pipeline.md` | Tripo + Blender models, procedural textures, audio, fonts, housekeeping |
| `skills/xesaga-games/references/trailer-and-store.md` | In-engine trailers, itch.io page kit, AI disclosure |
| `skills/xesaga-games/references/brand.md` | How to set up a studio brand, with XeSaga's brand as an example |
| `skills/xesaga-games/assets/` | Game plan template and XeSaga's example logo SVGs |
| `skills/xesaga-games/scripts/` | Trailer shot director, trailer edit script, Windows packager and launcher, smoke-test pattern, text outliner |
| `.claude-plugin/` | Plugin and marketplace manifests |

## Install

**a) Claude Code plugin**

```
/plugin marketplace add marwanfarid3/xesaga-games
/plugin install xesaga-games@xesaga-games
```

**b) Manual (Claude Code skill)**: copy `skills/xesaga-games` into `~/.claude/skills/`.

**c) claude.ai**: download `xesaga-games.skill` from this repo's Releases and upload it under
Settings, Capabilities, Skills.

**d) Other AI tools**: give the assistant `skills/xesaga-games/SKILL.md` plus the files in `references/`
as context.

On first use the skill asks for your studio name, the language to talk to you in, your Godot path, your
fonts folder and whether you have a brand kit.

## Example prompts

- "I have an idea for a short sad story game about a lighthouse. Plan it the XeSaga way."
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

Made by XeSaga, a Xeravon studio.

## License

MIT, see [LICENSE](LICENSE). The XeSaga name and logo files in `assets/` are examples of a brand;
make your own for your studio.
