# Asset pipeline

Rule zero: **supplied files are never edited.** Copy, adapt with a script in `tools/`, write the result
elsewhere, and add one bullet per asset to `docs/ASSET_CREDITS.md` (what, who made it, the tool and
paths, processing steps, "originals preserved").

## 3D models
- The creator generates hero models with **Tripo** (image → 3D). They arrive huge (~2M faces) and unrigged.
- Adapt in **Blender** from the command line with a script:
  `blender -b --python tools/adapt_<thing>.py` — decimate to a few thousand faces, bake/shrink the
  texture to 512 px, set a sensible scale and origin, add simple bones or pivots (head, legs, fingers,
  eyelid shape keys), export GLB to `models/`, save the working `.blend` to `models/source/`.
- Inspect unknown .blend files with a script that never runs their embedded Python.
- Props (hut, boat, coop, door) are built procedurally in Blender scripts so they stay editable.
- Keep the look consistent: weathered, low-poly, texture detail from small painted/noise maps.
- Check every model in-game with a render test from several angles (front and back), especially
  anything with one-sided detail (the eye only shows on the palm side).

## Textures and 2D art
- Procedural textures with Python + Pillow/numpy (`tools/make_*_textures.py [seed]`), seamless, small,
  nearest-filtered. Give each a seed so it can be regenerated.
- Title and heading art (e.g. bloody lettering) as pre-rendered PNGs from a script; a pixel version by
  shrinking ~5× and limiting colours.
- Game icon: the creator picks from options; ship `art/icon.png` and `art/icon.ico`.

## Audio
- The creator supplies an audio pack (music per day/chapter, stingers, ambience, SFX) with a manifest.
  Keep it untouched in `audio/pack/`; processed copies go to `audio/derived/`.
- Fill gaps in this order: synthesize in code (birds, heartbeat) → CC0 recordings (Freesound, credit the
  author) → **ElevenLabs** (sound effects `eleven_text_to_sound_v3`, music `eleven_music_v2_5`,
  screams/voices). Price it first with `estimate_only`; generate 2+ takes when possible and let the creator
  pick; download into the project; loudness-normalize with ffmpeg two-pass `loudnorm` (about -12 LUFS
  for SFX, peaks below -1 dBTP), add fades, make seamless loops with a 2 s crossfade.
- Analyse audio you can't hear: measure the RMS envelope (ffmpeg → numpy, 0.5 s windows) to find build,
  peaks and silences, and say so honestly when you haven't listened.

## Fonts
Ask before downloading. Free OFL fonts only (Google Fonts, rsms/inter). Store them in your fonts folder
(see "Set up for your studio") with their licence. For logos and SVGs, outline text with `scripts/outline_text.gd`.

## Housekeeping
- Generated junk goes to `.devcheck/` (git-ignored) or the session scratchpad, never the project root.
- When cleaning, move unused files to `_to_delete/` with a README (size, why unused) and let the creator
  delete them; never delete the creator's originals (teaser videos, PDFs, packs, plans, .blend sources).
