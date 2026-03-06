#!/usr/bin/env bash

###############################################################################
# bootstrap.sh
#
# 🚀 Machine bootstrap script
#
# This script prepares a new machine for working with Claude by:
#   1. Checking required dependencies
#   2. Installing Claude Code
#   3. Linking this repository's Claude configuration to ~/.claude
#
# After running this script, your Claude environment should be ready to use.
###############################################################################

set -e

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}🚀 Starting machine bootstrap${NC}"
echo

# Detect repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}📍 Repo location:${NC} $SCRIPT_DIR"
echo

############################################
# Check dependencies
############################################

echo -e "${BLUE}🔍 Checking dependencies...${NC}"

for cmd in git curl rsync; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}❌ Required command not found: $cmd${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ Dependencies look good${NC}"
echo

############################################
# Install Claude Code
############################################

echo -e "${BLUE}🤖 Installing Claude Code...${NC}"

if command -v claude >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Claude already installed${NC}"
else
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo -e "${GREEN}✅ Claude Code installed${NC}"
echo

############################################
# Install Claude config
############################################

echo -e "${BLUE}🔧 Linking Claude configuration...${NC}"

"$SCRIPT_DIR/link.sh"

echo
echo -e "${GREEN}🎉 Bootstrap complete!${NC}"
echo -e "${BLUE}Claude should now be ready to use.${NC}"
echo
