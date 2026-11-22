# Studio brand

How to give your studio a small, consistent identity that every game carries. The first half is the
method; the second half is XeSaga's own brand, kept as a clearly labelled example.

## Setting up a studio brand

1. **Name and one-line tagline.** Short, pronounceable, easy to find as a handle on every platform
   (check it is free and keep it identical everywhere).
2. **Logo with one central image.** Pick one picture that says what the studio is about, not a bent
   letter or a stock icon. Offer 3-4 genuinely different concepts with a one-line meaning each, show
   them visually (inline SVG mockups), recommend one, let the creator choose. Expect a second round.
   Rules to write down: which way up, never stretched, never recoloured, no drop shadows.
3. **Variants.** Dark (default), light, mono-black, mono-white; each as mark only, horizontal,
   horizontal-no-tagline and stacked, in SVG and PNG.
4. **Palette.** 6-8 named roles: background, panel, text, muted, plus 3-4 accents. Give a light-theme
   variant. Studio colours are for the studio splash, credits block, "about the studio" text and social
   posts, not for a game's own UI; each game has its own palette and title art.
5. **Fonts.** One display font for the name and short headlines, one text font for tagline, body and UI.
   Free OFL fonts only, stored in your fonts folder with their licence. Never set long text in the
   display font. For logos and SVGs, outline text with `scripts/outline_text.gd`.
6. **Credits line.** Every game's credits start with `A game by — <Studio>`.
7. **Studio splash (optional).** 2-3 s on the background colour: the mark centred, one small animation
   tied to the logo idea, the name in the display font, fade to black, then the game's title.

## Credits and AI disclosure (honest, always)

- The first credits line is the studio, never the AI tools.
- Assets the studio made or supplied are credited to the studio ("<Studio> models, made with Tripo;
  adapted in Blender", "the <Studio> <game> audio pack").
- Third-party assets keep their real author and licence (for example "'Axe chopping wood' by xkeril,
  Freesound 753925 (CC0)"), plus "Godot Engine, MIT licence".
- AI generation is disclosed honestly on store pages (see `trailer-and-store.md`); in-game credits name
  the studio rather than assistant products. Never hide or deny AI use when a store asks.

## Example: the XeSaga brand

XeSaga is "a Xeravon studio". Tagline: **Stories that become worlds.**

**Logo: the hourglass of worlds.** A moonlit aurora sky with a crescent moon and stars in the top bulb,
golden sand falling through the neck, an island (coral mountain) rising out of the sea in the bottom
bulb. Never flip it (sky on top, island below), never stretch, recolour or add shadows. Themes: dark
(default), light, mono-black, mono-white. Reference SVGs: `assets/xesaga-mark-dark.svg` and
`assets/xesaga-horizontal-dark.svg`. These are XeSaga's own marks; use them as a pattern, make your own.

**Palette: Moonlit sea.**

| Role | Hex |
|---|---|
| Background | #071A22 |
| Panel | #0E2A35 |
| Text | #E6F2F2 |
| Muted | #8FB9C2 |
| Teal (glass) | #4FB6C9 |
| Aqua (aurora, sea) | #9AD7E0 |
| Coral (island) | #FF8A7A |
| Sand (moon, stars) | #F2D7A0 |

Light theme: glass #1F7F91, text #0B2A33, sand #C99A3E, coral #E8685A, background #EEF6F6.

**Fonts.** Name and short headlines: Pixelify Sans Bold, tracking +10% (variable font, weight 700).
Tagline, body and UI copy: Inter Medium/Bold.

**Credits line.** `A game by — XeSaga, a Xeravon studio`.

**Splash.** The dark hourglass mark centred, sand animating down, "XESAGA" in Pixelify Sans below, fade
to black, then the game's title.
