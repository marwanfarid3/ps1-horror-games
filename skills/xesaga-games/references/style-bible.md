# Style bible

Studio-wide rules first, then Keep an Eye's specifics as a worked example. A new game picks its own
palette, tone and central image, but keeps the studio rules.

## Studio-wide look
- Internal resolution **640×360**, window 1280×720 by default, stretch `viewport` + `keep`, default
  texture filter **nearest**. Render method `gl_compatibility`.
- Low-poly models (a few thousand faces each), 64-512 px textures, nearest filtering.
- **One global grade.** Choose a narrow palette per game (Keep an Eye: everything between #0F0805 and
  #D53A09, one yellow #F7B61C for the sun, one cool grey #A69694 for HUD text). Write it in the plan.
- Post shader on the final image: slight gamma/contrast, a tint, colour quantize (~48 levels) with
  dither, animated grain (~12 Hz), vignette. Keep it subtle enough that text stays readable.
- Hard, readable shapes for gameplay information (Keep an Eye's shadow edge is pixel-stepped, never
  soft). The player should read danger from the picture.

## Studio-wide UI
- Title: illustrated logo (pre-rendered PNG) over the live game view, plain text menu below it:
  Start / Continue / New game / Settings & controls / Credits / Exit. Arrows, W/S, mouse, Enter.
- No button rectangles; selection is shown by a mark or colour.
- HUD: tiny corner indicators, 2 px dot crosshair, one contextual action prompt with its key near the
  object you look at, a thin progress stroke for held actions. Inventory only while Tab is held.
- Feedback lines appear lower on screen with a typed reveal, sentence case.
- Readable notes on paper (texture + dark serif body + illustrated heading). Notes hint, never instruct.
- Chapter/day cards between days with their own stinger.
- Settings: separate volume sliders (master, movement, animals, music...), mouse sensitivity,
  graphics (windowed/fullscreen, 1280×720 / 1600×900 / 1920×1080, VSync) saved in `user://settings.cfg`.
  F11 toggles fullscreen. Credits screen reachable from title and pause.
- Runtime fonts via SystemFont (Georgia for narrative/reading, Consolas for HUD numbers) unless a font
  file is approved; title/heading art is pre-rendered.

## Studio-wide audio
- Silence carries the day; music swells only at dawn/chapter start, at the last light and at climaxes.
- Ambience reacts to danger (insects and birds fall silent near it; heartbeat while in danger).
- Every scripted beat has a sound (a door creak, a tree dying, a goat falling, a note rustling).
- Never touch the player's volume sliders for drama: duck through a separate dynamics bus.
- Endings and big beats use true silence before the hit.
- Variant groups with no immediate repeats; positional 3D sound for world events.

## Narrative techniques that worked (Keep an Eye)
- **One central watcher** that is always visible and reacts to the player (the eye darts, finds you,
  stares back, blinks).
- **Days as acts**: each day shorter, harsher, with one new note and one overnight change in the world
  (wet sand, claw marks, fingerprints inside the door, a crack that widens, a tree that leans).
- **Previous person's trail**: notes from the last islander, each placed where its story happened and
  marked by a red rag.
- **Looking has a cost and a power**: creatures freeze while watched; watchers rise where you are not
  looking; one scare is earned exactly once (the eye in the well).
- **Everything competes**: the same food and water keep you alive or feed the threat.
- **Short and sharp**: 5 days, ~10 minutes of real play per run, two endings, no padding.
- Endings are directed to the music clock, with silence, a final hit and the title.

## Soft tension (for sad / gentle story games)
When a game should be moving rather than scary, keep the same toolkit but turn it down:
- Pressure from loss, not death: a light that fades, a boat that doesn't come back, a voice that stops.
- Sound narrows instead of screaming: ambience muffles, music thins to one instrument, a held breath.
- Colour drains toward grey near the threat and returns when it's pushed back.
- The "watcher" is a presence with a want (lonely, curious), not a monster; it reacts to the player.
- Fail states rewind gently (the night replays) instead of a death screen.
- No jump scares; one quiet surprise per act is the equivalent of Keep an Eye's well eye.

## Tone options for new games
Keep an Eye is weird, surreal horror with no combat. Your next games are "story games" first
(story mode first, not necessarily horror). Keep: quiet atmosphere, one strong image, a world
that changes as the story moves, choices that cost something, short runtime. Change freely: palette,
setting, threat, genre mood.
