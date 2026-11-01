# Kitty font choice

**Question.** Is the configured `SauceCodePro Nerd Font Mono` the best choice
for long coding and terminal-reading sessions, and what alternatives are worth
trying?

**Decision informed.** Whether to retain Kitty's current font or replace it.
**Consumer.** Direct configuration follow-up.

## Verified facts

- Kitty is configured in this repository with `SauceCodePro Nerd Font Mono` at
  16 pt ([`.config/kitty/kitty.conf`](../.config/kitty/kitty.conf)).
- SauceCodePro is Nerd Fonts' patched distribution of Adobe Source Code Pro.
  Source Code Pro was designed for UI and coding environments; Nerd Font Mono
  preserves terminal-compatible, single-cell glyph widths. [Adobe Source Code
  Pro](https://github.com/adobe-fonts/source-code-pro), [Nerd Fonts Source Code
  Pro README](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/SourceCodePro/README.md)
- JetBrains Mono intentionally maximizes lowercase height while keeping a
  standard character width and supplies distinguishable ambiguous characters.
  [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
- Iosevka is a configurable coding/terminal family with default, terminal, and
  fixed spacing variants, nine weights, and normal or extended widths.
  [Iosevka](https://github.com/be5invis/Iosevka)
- Fira Code supplies programming ligatures and lists Kitty as compatible.
  [Fira Code](https://github.com/tonsky/FiraCode)
- Digital-eye-strain guidance emphasizes display contrast, room lighting, and
  periodic distance breaks (the 20-20-20 rule), rather than selecting a
  particular font. [American Academy of Ophthalmology EyeWiki](https://eyewiki.aao.org/Computer_Vision_Syndrome_%28Digital_Eye_Strain%29)

## Assessment

There is no objectively best coding font, and no font can guarantee no eye
strain. Source Code Pro is an excellent low-risk default: open, mature,
restrained, clear at 16 pt, and already installed with icon coverage. Keep it
unless its relatively modest lowercase height makes you want a larger point
size.

| Candidate | Advantages for long sessions | Trade-offs | Best fit |
| --- | --- | --- | --- |
| **Source Code Pro** (current) | Calm, conventional forms; clear punctuation; no transition cost | Smaller apparent text than some peers; less distinctive personality | Best default |
| **JetBrains Mono Nerd Font Mono** | Large x-height and highly distinct ambiguous glyphs; robust italics | Wider/taller visual texture may show fewer lines | Best first experiment for readability |
| **Iosevka Term Nerd Font Mono** | Dense, crisp, highly configurable; more code per screen | Narrower shapes can feel crowded or tiring at small sizes | Best for high-density terminal work |
| **FiraCode Nerd Font Mono** | Familiar, good symbols; optional ligatures | Ligatures can conceal the literal characters and distract during debugging/review | Best only if you actively enjoy ligatures |

## Recommended trial

Retain Source Code Pro as the baseline. Compare it with JetBrains Mono for a
full workday using the same size, line spacing, theme, and display brightness;
then choose the one that makes small punctuation and `1`/`l`/`I` easiest to
scan. If Source feels small, try 17 pt before changing families. Treat screen
brightness/contrast, viewing distance, and breaks as more consequential for
comfort than font choice.

## Evidence limits

The perceived comfort of a font is individual. The typeface designers' claims
are useful design intent, not controlled evidence that one font reduces eye
strain more than another.

## Could not verify

No controlled study establishing that any listed programming font prevents or
meaningfully reduces eye strain relative to the others.

## Confidence

**High** for the configured font and supported feature differences; **medium**
for the personal-comfort recommendation because it depends on individual vision,
display, and task mix.

## Open questions

Whether ligatures are desirable in the user's terminal/editor workflow and
whether the current 16 pt rendering feels too small on their display.

## Next

If requested, add a reversible JetBrains Mono option to the Homebrew and Kitty
configuration for an A/B trial.
