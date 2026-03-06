#!/usr/bin/env bash

set -e

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}🚀 Machine bootstrap starting${NC}"
echo

# Detect repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}📍 Repo location:${NC} $SCRIPT_DIR"
echo

############################################
# Check dependencies
############################################

echo -e "${BLUE}🔍 Checking dependencies...${NC}"

if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}❌ git is not installed${NC}"
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    echo -e "${RED}❌ rsync is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies look good${NC}"
echo

############################################
# Claude config
############################################

echo -e "${BLUE}🤖 Installing Claude configuration...${NC}"

"$SCRIPT_DIR/link.sh"

echo

############################################
# Optional future sections
############################################

# Example sections I might add later:
#
# - install Homebrew
# - install CLI tools
# - install dotfiles
# - install dev environments
#

echo -e "${GREEN}🎉 Bootstrap complete!${NC}"
echo
echo -e "${BLUE}Your machine is ready.${NC}"
