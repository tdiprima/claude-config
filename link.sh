#!/usr/bin/env bash

set -e

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}🔗 Claude config symlink setup${NC}"
echo

# Find repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/claude"
TARGET_DIR="$HOME/.claude"

echo -e "${BLUE}📍 Repo location:${NC} $SCRIPT_DIR"

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Could not find 'claude/' directory.${NC}"
    echo -e "${RED}Expected: $SOURCE_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found Claude config directory${NC}"
echo

# If ~/.claude already exists
if [ -e "$TARGET_DIR" ]; then

    # If it's already the correct symlink
    if [ -L "$TARGET_DIR" ] && [ "$(readlink "$TARGET_DIR")" = "$SOURCE_DIR" ]; then
        echo -e "${GREEN}✅ ~/.claude already correctly linked${NC}"
        exit 0
    fi

    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_DIR="$HOME/.claude.backup.$TIMESTAMP"

    echo -e "${YELLOW}⚠️  Existing ~/.claude detected${NC}"
    echo -e "${BLUE}💾 Backing it up to:${NC} $BACKUP_DIR"

    mv "$TARGET_DIR" "$BACKUP_DIR"

    echo -e "${GREEN}✅ Backup created${NC}"
    echo
fi

# Create symlink
echo -e "${BLUE}🔗 Creating symlink${NC}"
ln -s "$SOURCE_DIR" "$TARGET_DIR"

echo
echo -e "${GREEN}🎉 Done!${NC}"
echo -e "${BLUE}~/.claude now points to:${NC} $SOURCE_DIR"
