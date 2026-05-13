# Video Editing Studio — Full Pipeline

This workspace is a complete video editing studio: drop in raw footage, remove filler words, add motion graphics, render `final.mp4`.

Two tools do the work:
- **`video-use`** — editing brain (transcription, filler removal, cut decisions, color grade, subtitle burn)
- **HyperFrames** (this repo) — motion graphics layer (HTML/CSS/GSAP overlays, kinetic type, shader transitions)

---

## One-time setup

```bash
bash scripts/setup-studio.sh
```

Then paste your ElevenLabs API key when prompted (free tier works — get one at https://elevenlabs.io/app/settings/api-keys).

---

## Session workflow

### Step 1 — Point Claude at your footage

```bash
cd /path/to/your/raw/videos
claude
```

First message in the session:
> edit these — remove filler words and dead air, then let's talk motion graphics

### Step 2 — Transcription (automatic)

Claude runs `transcribe_batch.py` on the folder. ElevenLabs Scribe returns word-level timestamps, speaker diarization, and audio events (`(laughs)`, `(sigh)`, etc.). Results cache to `edit/transcripts/` — never re-billed.

### Step 3 — Filler word removal + cut strategy

Claude reads `edit/takes_packed.md` (the compressed transcript) and proposes a strategy:
- Which segments to keep
- Where to cut `umm`, `uh`, false starts, dead pauses
- Take selection if you have multiple clips of the same beat
- Rough runtime estimate

**You confirm before anything is touched.**

### Step 4 — Edit execution

Claude produces `edit/edl.json` and runs `render.py --preview`. All cuts snap to word boundaries with 30ms audio fades — no pops.

Preview lands at `edit/preview.mp4`. Claude self-evaluates at every cut boundary (visual jump check, waveform spike check) before showing you.

### Step 5 — Motion graphics (HyperFrames)

Once the cut is approved, tell Claude what motion graphics you want:

> add a kinetic text overlay for the key stats, whip-pan transitions between sections, and lower thirds

Claude will:
1. Read `MOTION_PHILOSOPHY.md` to get your aesthetic baseline
2. Build each animation as an isolated HyperFrames composition in `edit/animations/slot_N/`
3. Run `npx hyperframes lint` + `npx hyperframes render` per slot
4. Composite them into the edited footage via `render.py`

All animation slots run in parallel — total time ≈ slowest slot.

### Step 6 — Final render

```
edit/final.mp4
```

Subtitles are burned last (never hidden by overlays). Grade applied per-segment during extraction, not post-concat.

---

## Directory layout during a session

```
/path/to/your/videos/
├── raw_clip.mp4                ← your source, untouched
└── edit/
    ├── project.md              ← session memory (appended each session)
    ├── takes_packed.md         ← transcript reading view
    ├── edl.json                ← cut decisions
    ├── transcripts/            ← cached Scribe JSON
    ├── animations/
    │   ├── slot_1/             ← HyperFrames composition + render
    │   └── slot_2/
    ├── clips_graded/           ← per-segment extracts
    ├── master.srt              ← output-timeline subtitles
    ├── preview.mp4
    └── final.mp4
```

The `video-use` repo and this workspace stay clean — all session outputs live next to your footage.

---

## Motion graphics style guide

Read `MOTION_PHILOSOPHY.md` before brainstorming any composition. It's the deconstructed Infinite Global Payments 30s spot — your gold standard.

Key defaults:
- Black canvas + perspective grid + crosshairs + vignette + grain on every scene
- Chrome-gradient text with halo glow
- Motion-blurred whip transitions (never hard cuts)
- ~1.5s average scene length
- ≤5 symbolic colors
- Outro held 4–6s

Available HyperFrames registry blocks for overlays:
- **Transitions:** `whip-pan`, `cinematic-zoom`, `glitch`, `flash-through-white`, `light-leak`, `cross-warp-morph`, `domain-warp-dissolve`, and 8 more shader transitions
- **Text/social:** `yt-lower-third`, `macos-notification`, `x-post`, `instagram-follow`, `spotify-card`
- **Data/product:** `data-chart`, `flowchart`, `app-showcase`, `ui-3d-reveal`
- **Outros:** `logo-outro`
- **Components:** `grain-overlay`, `shimmer-sweep`, `grid-pixelate-wipe`

Browse: `npx hyperframes catalog --type block`

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `ELEVENLABS_API_KEY not set` | `echo 'ELEVENLABS_API_KEY=...' >> ~/Developer/video-use/.env` |
| `ffmpeg not found` | `brew install ffmpeg` (macOS) or `sudo apt install ffmpeg` |
| `python helpers/... not found` | `cd ~/Developer/video-use && uv sync` |
| HyperFrames render fails | `npx hyperframes doctor` from inside the slot directory |
| Node version error | Install Node.js 22+ via `nvm install 22` |
| Subtitles hidden by overlay | Hard rule violation — Claude re-renders with subtitles last |

---

## Skills loaded in this workspace

| Skill | Purpose |
|---|---|
| `video-use` | Full editing pipeline (transcribe → cut → grade → render) |
| `hyperframes` | Composition authoring, captions, TTS, audio-reactive animation |
| `hyperframes-cli` | CLI: init, lint, preview, render, transcribe, tts, doctor |
| `gsap` | GSAP timelines, easing, stagger, ScrollTrigger |
| `hyperframes-registry` | Installing catalog blocks via `npx hyperframes add` |
| `website-to-hyperframes` | Turn a URL into a HyperFrames composition |
