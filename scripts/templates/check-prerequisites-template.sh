#!/bin/bash

# {{PROJECT_NAME}} - Prerequisites Check Script
# This script checks if all required software is installed
# Generated from template for {{PRIMARY_LANGUAGE}} project

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}$1${NC}"
    echo "----------------------------------------"
}

check_command() {
    local cmd=$1
    local min_version=$2
    local version_cmd=$3
    
    if command -v $cmd &> /dev/null; then
        if [ -n "$min_version" ] && [ -n "$version_cmd" ]; then
            current_version=$(eval $version_cmd 2>/dev/null || echo "unknown")
            echo -e "${GREEN}✓${NC} $cmd: $current_version"
            # TODO: Add version comparison logic if needed
        else
            echo -e "${GREEN}✓${NC} $cmd: installed"
        fi
        return 0
    else
        echo -e "${RED}✗${NC} $cmd: not installed"
        return 1
    fi
}

# Header
echo "=================================================="
echo "{{PROJECT_NAME}} Prerequisites Check"
echo "=================================================="
echo ""

ALL_GOOD=1

# Core Requirements
print_header "Core Requirements"

# Language-specific checks
{{#if_language_nodejs}}
# Node.js
if check_command node "{{NODE_MIN_VERSION}}" "node --version | cut -d 'v' -f 2"; then
    NODE_VERSION=$(node --version | cut -d 'v' -f 2)
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d '.' -f 1)
    if [ "$MAJOR_VERSION" -lt {{NODE_MAJOR_VERSION}} ]; then
        echo -e "  ${YELLOW}⚠${NC}  Node.js version should be {{NODE_MIN_VERSION}} or higher"
        ALL_GOOD=0
    fi
else
    echo -e "  ${RED}Install:${NC} https://nodejs.org/ or use nvm"
    ALL_GOOD=0
fi

# Package Manager
if ! check_command {{PACKAGE_MANAGER}} "" "{{PACKAGE_MANAGER}} --version"; then
    echo -e "  ${RED}Install:${NC} {{PACKAGE_MANAGER_INSTALL}}"
    ALL_GOOD=0
fi
{{/if_language_nodejs}}

{{#if_language_python}}
# Python
if check_command python3 "{{PYTHON_MIN_VERSION}}" "python3 --version | awk '{print \$2}'"; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    MAJOR=$(echo $PYTHON_VERSION | cut -d '.' -f 1)
    MINOR=$(echo $PYTHON_VERSION | cut -d '.' -f 2)
    if [ "$MAJOR" -lt {{PYTHON_MAJOR}} ] || ([ "$MAJOR" -eq {{PYTHON_MAJOR}} ] && [ "$MINOR" -lt {{PYTHON_MINOR}} ]); then
        echo -e "  ${YELLOW}⚠${NC}  Python version should be {{PYTHON_MIN_VERSION}} or higher"
        ALL_GOOD=0
    fi
else
    echo -e "  ${RED}Install:${NC} https://www.python.org/"
    ALL_GOOD=0
fi

# Package Manager
if ! check_command {{PACKAGE_MANAGER}} "" "{{PACKAGE_MANAGER}} --version"; then
    echo -e "  ${RED}Install:${NC} {{PACKAGE_MANAGER_INSTALL}}"
    ALL_GOOD=0
fi
{{/if_language_python}}

{{#if_language_go}}
# Go
if check_command go "{{GO_MIN_VERSION}}" "go version | awk '{print \$3}' | sed 's/go//'"; then
    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    # TODO: Add version comparison
else
    echo -e "  ${RED}Install:${NC} https://golang.org/dl/"
    ALL_GOOD=0
fi
{{/if_language_go}}

{{#if_language_rust}}
# Rust
if check_command rustc "{{RUST_MIN_VERSION}}" "rustc --version | awk '{print \$2}'"; then
    :
else
    echo -e "  ${RED}Install:${NC} https://www.rust-lang.org/tools/install"
    ALL_GOOD=0
fi

if ! check_command cargo "" "cargo --version | awk '{print \$2}'"; then
    echo -e "  ${RED}Install:${NC} Comes with Rust"
    ALL_GOOD=0
fi
{{/if_language_rust}}

# Git
if ! check_command git "" "git --version | awk '{print \$3}'"; then
    echo -e "  ${RED}Install:${NC} https://git-scm.com/"
    ALL_GOOD=0
fi

echo ""

{{#if_docker_required}}
# Docker
print_header "Container Runtime"

if check_command docker "" "docker --version | awk '{print \$3}' | sed 's/,//'"; then
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        echo -e "  ${YELLOW}⚠${NC}  Docker daemon is not running"
        echo -e "  ${YELLOW}Fix:${NC} Start Docker Desktop"
        ALL_GOOD=0
    fi
else
    echo -e "  ${RED}Install:${NC} https://www.docker.com/products/docker-desktop"
    ALL_GOOD=0
fi

# Docker Compose
if ! check_command docker-compose "" "docker-compose --version | awk '{print \$4}' | sed 's/,//'"; then
    # Check for docker compose (v2)
    if docker compose version &> /dev/null; then
        echo -e "${GREEN}✓${NC} docker compose: installed (v2)"
    else
        echo -e "  ${YELLOW}Note:${NC} docker-compose not found, but 'docker compose' might work"
    fi
fi

echo ""
{{/if_docker_required}}

{{#if_database_mongodb}}
# MongoDB Tools
print_header "MongoDB Tools"

if ! check_command mongosh "" "mongosh --version"; then
    echo -e "  ${RED}Install:${NC} {{MONGODB_INSTALL_COMMAND}}"
    ALL_GOOD=0
fi

echo ""
{{/if_database_mongodb}}

{{#if_database_postgresql}}
# PostgreSQL Tools
print_header "PostgreSQL Tools"

if ! check_command psql "" "psql --version | awk '{print \$3}'"; then
    echo -e "  ${RED}Install:${NC} {{POSTGRESQL_INSTALL_COMMAND}}"
    ALL_GOOD=0
fi

echo ""
{{/if_database_postgresql}}

{{#if_database_mysql}}
# MySQL Tools
print_header "MySQL Tools"

if ! check_command mysql "" "mysql --version"; then
    echo -e "  ${RED}Install:${NC} {{MYSQL_INSTALL_COMMAND}}"
    ALL_GOOD=0
fi

echo ""
{{/if_database_mysql}}

{{#if_ssh_required}}
# SSH
print_header "SSH Configuration"

if check_command ssh "" "ssh -V 2>&1 | awk '{print \$1}'"; then
    # Check for SSH key
    if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ]; then
        echo -e "${GREEN}✓${NC} SSH key: found"
    else
        echo -e "${YELLOW}⚠${NC}  No SSH key found"
        echo -e "  ${YELLOW}Generate:${NC} ssh-keygen -t ed25519 -C \"your-email@example.com\""
    fi
else
    echo -e "  ${RED}Install:${NC} Should be pre-installed on most systems"
    ALL_GOOD=0
fi

echo ""
{{/if_ssh_required}}

# Custom Requirements
{{#each REQUIRED_TOOLS}}
if ! check_command {{name}} "{{version}}" "{{version_command}}"; then
    echo -e "  ${RED}Install:${NC} {{install_command}}"
    ALL_GOOD=0
fi
{{/each}}

# Optional but Recommended
print_header "Optional Tools"

{{#each OPTIONAL_TOOLS}}
if check_command {{name}} "" "{{version_command}}"; then
    :
else
    echo -e "  ${YELLOW}Install:${NC} {{install_command}}"
fi
{{/each}}

echo ""

# System Information
print_header "System Information"

echo "OS: $(uname -s) $(uname -r)"
echo "Architecture: $(uname -m)"
echo "User: $(whoami)"
echo "Shell: $SHELL"

if [ -f /proc/meminfo ]; then
    TOTAL_MEM=$(awk '/MemTotal/ {printf "%.1f", $2/1024/1024}' /proc/meminfo)
    echo "Memory: ${TOTAL_MEM} GB"
elif command -v sysctl &> /dev/null; then
    TOTAL_MEM=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.1f", $1/1024/1024/1024}')
    [ -n "$TOTAL_MEM" ] && echo "Memory: ${TOTAL_MEM} GB"
fi

# Disk space
if command -v df &> /dev/null; then
    DISK_AVAIL=$(df -h . | awk 'NR==2 {print $4}')
    echo "Disk available: $DISK_AVAIL"
fi

echo ""

# Summary
echo "=================================================="
if [ $ALL_GOOD -eq 1 ]; then
    echo -e "${GREEN}✓ All prerequisites are installed!${NC}"
    echo ""
    echo "Next step: {{NEXT_STEP_MESSAGE}}"
else
    echo -e "${RED}✗ Some prerequisites are missing${NC}"
    echo ""
    echo "Please install missing components before proceeding."
    echo "See {{SETUP_DOCS_PATH}} for detailed instructions."
fi
echo "=================================================="

exit $((1 - $ALL_GOOD))