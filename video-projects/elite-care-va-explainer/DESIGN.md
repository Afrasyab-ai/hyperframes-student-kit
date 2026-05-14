# DESIGN — Elite Care VA Explainer: iOS Liquid Glass

## Style
iOS Liquid Glass — frosted translucent panels with deep navy canvas. Premium,
clinical, and trustworthy. Overlays float on the left third of the widescreen
frame without touching the subject. Every glass surface refracts slightly —
depth without heaviness.

## Colors
- `#08122a`               — deep navy canvas (base)
- `rgba(8,18,50,0.62)`    — glass card background (dark navy + opacity)
- `rgba(255,255,255,0.18)`— glass border
- `rgba(255,255,255,0.28)`— glass inner highlight (inset top)
- `#4A9EFF`               — iOS blue accent (badges, chips, phone number)
- `#F0F8FF`               — primary white text
- `rgba(240,248,255,0.65)`— secondary muted text

## Typography
- **Barlow Condensed 800** — step badges, card headlines, CTA phone number, tagline
- **Figtree 600**          — caption text, chip labels, card eyebrows, card sub-text

## Motion
- Overlays enter LEFT → RESTING (x: -40→0) + fade, 0.45-0.5s, `power3.out`
- Cards enter BELOW → RESTING (y: 24→0) + fade, 0.45s, `power2.out`
- Chips stagger in from left (x: -20→0) 0.4s, `expo.out`, 200ms apart
- Captions: set (y:8, opacity:0) → to (y:0, opacity:1), 0.18s, `power2.out`
- Final scene (CTA): fade out allowed, 0.5s `power2.in`

## What NOT to Do
- No gradient text (background-clip hack)
- No left-edge accent stripe on cards
- No neon blue — keep `#4A9EFF`, not `#00FFFF` or oversaturated
- No dramatic zoom or slam — calm, authoritative, medical
- No text over the subject's face — all overlays stay in the left column (x < 650)
