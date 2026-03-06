#!/usr/bin/env bash

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}🚀 Claude config installer starting...${NC}"

SOURCE_DIR="./claude"
TARGET_DIR="$HOME/.claude"

# Check if source exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo -e "${RED}❌ Source directory '$SOURCE_DIR' not found.${NC}"
  echo -e "${RED}Make sure you're running this script from the repo root.${NC}"
  exit 1
fi

# Check if ~/.claude exists
if [ -d "$TARGET_DIR" ]; then
  echo -e "${YELLOW}⚠️  ~/.claude already exists.${NC}"
  echo -e "${YELLOW}Merging files from repo into existing directory...${NC}"
else
  echo -e "${BLUE}📁 ~/.claude not found. Creating it...${NC}"
  mkdir -p "$TARGET_DIR"
  echo -e "${GREEN}✅ Directory created.${NC}"
fi

# Copy files
echo -e "${BLUE}📦 Syncing Claude configuration...${NC}"
rsync -av "$SOURCE_DIR"/ "$TARGET_DIR"/

echo -e "${GREEN}🎉 Done! Claude config is now synced to ~/.claude${NC}"
