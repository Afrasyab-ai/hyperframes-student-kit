#!/usr/bin/env bash
# setup-studio.sh — one-command install for the full video editing studio
# Run from anywhere: bash scripts/setup-studio.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()  { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }
die() { echo -e "${RED}✗${NC} $*" >&2; exit 1; }

echo ""
echo "=== Video Editing Studio Setup ==="
echo ""

# ── 1. Clone or update video-use ─────────────────────────────────────────────
VIDEO_USE_DIR="$HOME/Developer/video-use"

if [ -d "$VIDEO_USE_DIR/.git" ]; then
  echo "Updating video-use..."
  git -C "$VIDEO_USE_DIR" pull --ff-only --quiet
  ok "video-use up to date at $VIDEO_USE_DIR"
else
  echo "Cloning video-use..."
  mkdir -p "$HOME/Developer"
  git clone --quiet https://github.com/browser-use/video-use "$VIDEO_USE_DIR"
  ok "video-use cloned to $VIDEO_USE_DIR"
fi

# ── 2. Python deps ────────────────────────────────────────────────────────────
echo "Installing Python dependencies..."
cd "$VIDEO_USE_DIR"
if command -v uv &>/dev/null; then
  uv sync --quiet
  ok "Python deps installed via uv"
elif command -v pip &>/dev/null; then
  pip install -e . -q
  ok "Python deps installed via pip"
else
  die "Neither uv nor pip found. Install Python 3.10+ first."
fi
cd - >/dev/null

# ── 3. ffmpeg ─────────────────────────────────────────────────────────────────
if command -v ffmpeg &>/dev/null; then
  ok "ffmpeg already on PATH ($(ffmpeg -version 2>&1 | head -1 | cut -d' ' -f3))"
else
  warn "ffmpeg not found."
  if command -v brew &>/dev/null; then
    echo "Installing ffmpeg via Homebrew (this takes a minute)..."
    brew install ffmpeg --quiet
    ok "ffmpeg installed"
  elif command -v apt-get &>/dev/null; then
    echo "Run: sudo apt-get install -y ffmpeg"
    warn "Skipping ffmpeg install (requires sudo). Run the command above, then re-run this script."
  else
    warn "Install ffmpeg manually from https://ffmpeg.org/download.html and re-run."
  fi
fi

# ── 4. Node.js version check ──────────────────────────────────────────────────
if command -v node &>/dev/null; then
  NODE_VER=$(node --version | sed 's/v//' | cut -d. -f1)
  if [ "$NODE_VER" -ge 22 ]; then
    ok "Node.js $(node --version) — HyperFrames compatible"
  else
    warn "Node.js $(node --version) found, but HyperFrames requires 22+."
    warn "Install via: nvm install 22 && nvm use 22"
  fi
else
  warn "Node.js not found. Install Node.js 22+ for HyperFrames motion graphics."
  warn "Recommended: https://github.com/nvm-sh/nvm"
fi

# ── 5. Register video-use skill with Claude Code ─────────────────────────────
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"
if [ -L "$SKILLS_DIR/video-use" ] || [ -d "$SKILLS_DIR/video-use" ]; then
  ok "video-use skill already linked at $SKILLS_DIR/video-use"
else
  ln -sfn "$VIDEO_USE_DIR" "$SKILLS_DIR/video-use"
  ok "video-use skill linked at $SKILLS_DIR/video-use"
fi

# ── 6. ElevenLabs API key ─────────────────────────────────────────────────────
ENV_FILE="$VIDEO_USE_DIR/.env"

KEY_SET=false
if [ -n "${ELEVENLABS_API_KEY:-}" ]; then
  ok "ELEVENLABS_API_KEY already in environment"
  KEY_SET=true
elif [ -f "$ENV_FILE" ] && grep -q '^ELEVENLABS_API_KEY=..' "$ENV_FILE" 2>/dev/null; then
  ok "ELEVENLABS_API_KEY already in $ENV_FILE"
  KEY_SET=true
fi

if [ "$KEY_SET" = false ]; then
  echo ""
  echo -e "${YELLOW}ElevenLabs API key needed for transcription.${NC}"
  echo "Get one at: https://elevenlabs.io/app/settings/api-keys (free tier works)"
  echo ""
  read -rp "Paste your ElevenLabs API key (or press Enter to skip): " USER_KEY
  if [ -n "$USER_KEY" ]; then
    printf 'ELEVENLABS_API_KEY=%s\n' "$USER_KEY" > "$ENV_FILE"
    chmod 600 "$ENV_FILE"
    ok "API key saved to $ENV_FILE"
  else
    warn "Skipped — transcription won't work until you add the key."
    warn "Run: echo 'ELEVENLABS_API_KEY=your_key' >> $ENV_FILE"
  fi
fi

# ── 7. Verify helpers ─────────────────────────────────────────────────────────
if python "$VIDEO_USE_DIR/helpers/timeline_view.py" --help &>/dev/null 2>&1; then
  ok "Python helpers verified"
else
  warn "Helper check failed — try: cd $VIDEO_USE_DIR && uv sync"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}=== Studio ready ===${NC}"
echo ""
echo "To start editing:"
echo "  cd /path/to/your/raw/videos"
echo "  claude"
echo ""
echo "First message: \"edit these — remove filler words and let's add motion graphics\""
echo ""
echo "Read PIPELINE.md for the full workflow."
echo ""
