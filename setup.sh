#!/usr/bin/env bash
# 🎯 Finds the repo location automatically (so you can run it from anywhere)
# 🧠 Verifies the claude/ directory exists
# 💾 Backs up ~/.claude before modifying it
# 📦 Uses rsync for safe merging
# 🌈 Colored output + status messages

set -e

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}🚀 Claude config installer${NC}"
echo

# Detect repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/claude"
TARGET_DIR="$HOME/.claude"

echo -e "${BLUE}📍 Repo location:${NC} $SCRIPT_DIR"

# Verify source exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Could not find 'claude/' directory in repo.${NC}"
    echo -e "${RED}Expected location: $SOURCE_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found Claude config directory${NC}"
echo

# Backup existing ~/.claude
if [ -d "$TARGET_DIR" ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_DIR="$HOME/.claude.backup.$TIMESTAMP"

    echo -e "${YELLOW}⚠️  Existing ~/.claude detected${NC}"
    echo -e "${BLUE}💾 Creating backup:${NC} $BACKUP_DIR"

    cp -rp "$TARGET_DIR" "$BACKUP_DIR"

    echo -e "${GREEN}✅ Backup created${NC}"
    echo
else
    echo -e "${BLUE}📁 ~/.claude does not exist — creating it${NC}"
    mkdir -p "$TARGET_DIR"
    echo -e "${GREEN}✅ Directory created${NC}"
    echo
fi

# Sync files
echo -e "${BLUE}📦 Syncing configuration...${NC}"

rsync -av "$SOURCE_DIR"/ "$TARGET_DIR"/

echo
echo -e "${GREEN}🎉 Claude configuration installed successfully!${NC}"
echo -e "${BLUE}📂 Location:${NC} $TARGET_DIR"

# If something breaks, you just:
# mv ~/.claude.backup.TIMESTAMP ~/.claude
