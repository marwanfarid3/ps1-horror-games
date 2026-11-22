# Studio brand

How to give your studio a small, consistent identity that every game carries. Follow the steps, make your own
marks, and keep everything in one folder.

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
