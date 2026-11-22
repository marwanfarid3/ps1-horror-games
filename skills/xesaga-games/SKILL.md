---
name: xesaga-games
description: The XeSaga way of making story-driven indie games in Godot 4, learned from building the horror game Keep an Eye. Covers planning with a game plan, look and feel, code layout, Tripo/Blender/ElevenLabs asset pipeline, headless tests, Windows packaging, in-engine trailers, itch.io store pages and studio branding. Use it when someone wants to plan, build, extend, test, package, make a trailer for, or publish an indie game with Godot, mentions XeSaga, story games, itch.io pages or in-engine trailers, or says things like new game idea, add a mechanic, make a trailer or publish on itch.
---

# The XeSaga way of making story-driven games

XeSaga ("a Xeravon studio") makes short, atmospheric, story-first games with one unforgettable central
image. This skill is the workflow it used to build **Keep an Eye**, a 5-day first-person horror survival
story on a dying island watched by a giant hand with an eye in its palm (Godot 4, low-res PS1 look, two
endings, about 10 minutes per run). Use Keep an Eye as the worked example of **how** to work and **how
polished** things must be, not as a template to clone. Your next game can be gentler, stranger or sadder.

## Set up for your studio (fill in once, then keep in your notes or project memory)

If these are not known yet, ask for them in one short message before starting.

| Setting | Your value |
|---|---|
| Studio name (used in credits and store pages) | `<Studio>` (example: XeSaga, a Xeravon studio) |
| Language to talk to the creator in | `<language>` (example: Arabic, Spanish, English). Code, docs, comments and in-game text stay English unless told otherwise |
| Godot 4 executable ("your Godot path"); keep the `_console.exe` wrapper beside it | `<path>` (also usable as the `GODOT_PATH` environment variable) |
| Fonts folder (free OFL fonts only) | `<path>` |
| Studio brand kit exists? | yes/no. If no, follow `references/brand.md` to make one |

Talk to the creator in their language, in short plain words, no jargon.

## The way we work (in this order)

1. **Plan before code.** Write `<GAME>_GAME_PLAN.md` from `assets/game-plan-template.md`. Tag every line
   `[CONFIRMED]` (the creator said it; don't change without asking), `[PROPOSED]` (build it, easy to
   change) or `[TBD]` (pick the simplest default, log it in `docs/decisions.md`). Write 4-5 design
   pillars and use them to cut features ("when in doubt, cut").
2. **Look prototype first (M0).** Camera, render size, colour grade, one hero object and the UI style on
   screen before systems. The creator judges by eye; show screenshots early.
3. **Grey-box the loop, then layer.** Milestones of one playable step each; the project runs at every
   commit; one milestone (version) per commit: `0.7.2: short summary`.
4. **Every number in `data/tuning.json`.** Per-day values as arrays. Prune unused keys.
5. **Assets through scripts.** Supplied models and sounds are never edited; tools in `tools/` adapt
   copies and record each step in `docs/ASSET_CREDITS.md`. See `references/asset-pipeline.md`.
6. **Test what you build.** A headless smoke test per feature and `render_*.gd` screenshots for anything
   visual; look at the screenshots yourself before claiming a visual change works. Run the whole suite
   before every version. See `references/godot-architecture.md`.
7. **Package and hand over.** Portable ZIP via `scripts/build/package_game.ps1`; the README gets a new
   version paragraph at the top; `docs/VALIDATION.md` lists what ran and its limits; give the creator a
   short hand-test list in their language.
8. **Playtest loop.** The game writes a playtest diary (`user://playtest_log.txt`); ask for it after a
   real playthrough and tune from real deaths, not guesses.
9. **Trailer, store, brand** at the end: `references/trailer-and-store.md`, `references/brand.md`.

### Starting a brand-new game
- One project folder per game, with `<GAME>_GAME_PLAN.md` at its root and `docs/decisions.md` beside it
  (log TBD defaults from day one). First version is `0.1.0` = the M0 look prototype.
- Write the whole plan in one go. Where the creator must choose (central image, ending, title), put 3-4
  options in the plan with a recommendation, mark it [TBD], then ask at most 4 short questions.
- Show visual choices visually: an inline SVG/HTML mockup for logos, palettes and layouts, or in-engine
  screenshots once a prototype exists. Text-only is a fallback.
- Ask before downloading anything or adding plugins. Check the cost with `estimate_only` before spending
  paid-API credits (for example ElevenLabs).

## Studio rules (hard-won lessons)

- **Physical truth.** Things sit where the world says they are: the hand rises out of the sea, it never
  floats. Doors swing on hinges, animals walk on the ground, a carried hen is a real hen.
- **Show it, don't tell it.** Danger is readable from picture and sound alone; notes hint rather than
  instruct; no captions over endings.
- **Creative, not generic.** Reject "software-looking" ideas (logos that just bend a letter, stock
  layouts). Offer 3-4 genuinely different concepts with a one-line meaning each, show them visually,
  recommend one, let the creator pick. Expect a second round.
- **Strong and complete.** If the creator describes a scene (camera from the ground up, animals dying,
  trees losing leaves), every beat must be on screen. Re-check against their words before saying done.
- **No endings in marketing.** Endings never appear in trailers, GIFs, screenshots or store art.
- **Credit the studio.** In-game credits start with "A game by — <Studio>"; AI use is disclosed honestly
  on store pages, not buried and not in the credits line.
- **Honest reports.** Say what you did not verify ("I measured the music's loudness but did not listen
  to it"). Never claim a test passed or a file exists without checking.
- **Storage matters.** No big temp files lying around; when cleaning up, move unused files to
  `_to_delete/` with a README (size, why unused) instead of deleting, and never touch originals.

## Style DNA (all XeSaga games)

- Low-res render (640×360 internal, nearest upscale), OpenGL compatibility renderer so it runs on weak
  laptops, low-poly / PS1-era models with small nearest-filtered textures, one strong colour grade, a
  post shader (quantize + dither + grain + vignette).
- Minimal diegetic UI: text menus without button boxes, quiet corner indicators, one contextual prompt,
  paper notes, illustrated day/chapter cards.
- Sound tells the story: silence is a tool, music at key moments only, ambience reacts to danger, every
  scripted beat has a sound.
- One unforgettable central image that appears in the game, the icon, the trailer and the store page.
Details and the techniques that worked: `references/style-bible.md`.

## Reference files (read when the task touches them)

| File | Read when |
|---|---|
| `references/style-bible.md` | designing look, UI, audio, narrative or scare beats |
| `references/godot-architecture.md` | creating a project, adding systems, tests, saves, packaging |
| `references/asset-pipeline.md` | adding models (Tripo/Blender), textures, sounds, music, credits |
| `references/trailer-and-store.md` | trailers, GIFs, screenshots, itch.io/Steam pages, AI disclosure |
| `references/brand.md` | setting up a studio brand: logo, colours, fonts, credits text |
| `assets/game-plan-template.md` | starting a new game |
| `scripts/README.md` | trailer director, edit script, packager, test pattern, text outliner |

The scripts and templates are Keep an Eye's own tools, generalised. A finished project following this
workflow has: a game plan, `docs/decisions.md`, `docs/VALIDATION.md`, `docs/ASSET_CREDITS.md`, `tests/`
and `tools/`; use that as the checklist for what "complete" looks like.
