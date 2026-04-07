#!/usr/bin/env bash
# check-deps.sh — verify that all required dependencies for moulti-wizard are installed

set -euo pipefail

DEPS_OK=true
WARNINGS=()

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_cmd() {
    local cmd=$1
    local install_hint=$2
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}✗${NC} Missing: ${cmd}"
        if [[ -n "$install_hint" ]]; then
            echo -e "  ${YELLOW}→${NC} Install with: $install_hint"
        fi
        DEPS_OK=false
        return 1
    else
        local version_output=""
        case "$cmd" in
            python3)
                version_output=$("$cmd" --version 2>&1 | head -1)
                ;;
            ansible-playbook)
                version_output=$("$cmd" --version 2>&1 | head -1)
                ;;
            moulti)
                version_output=$("$cmd" --version 2>&1)
                ;;
        esac
        echo -e "${GREEN}✓${NC} $cmd installed${version_output:+ ($version_output)}"
        return 0
    fi
}

check_python_module() {
    local module=$1
    local install_hint=$2
    # Try the ansible python first (it should have pyyaml)
    if ! /usr/bin/python3 -c "import $module" 2>/dev/null && \
       ! python3 -c "import $module" 2>/dev/null; then
        WARNINGS+=("Missing Python module: $module. Install with: $install_hint")
        return 1
    else
        echo -e "${GREEN}✓${NC} Python module '$module' available"
        return 0
    fi
}

echo "Checking dependencies for moulti-wizard..."
echo ""

# Required commands
echo "Required tools:"
check_cmd "python3" "apt install python3 (Ubuntu/Debian) or brew install python (macOS)"
check_cmd "ansible-playbook" "pipx install ansible-core  OR  pip install ansible"
check_cmd "moulti" "pipx install moulti"
check_cmd "bash" ""

echo ""
echo "Python modules (managed by Ansible):"
check_python_module "yaml" "pip install pyyaml  (or comes with: pipx install ansible-core)"

echo ""
if $DEPS_OK; then
    echo -e "${GREEN}✓ All dependencies satisfied!${NC}"
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}Warnings:${NC}"
        for warning in "${WARNINGS[@]}"; do
            echo "  • $warning"
        done
    fi
    exit 0
else
    echo -e "${RED}✗ Some dependencies are missing.${NC}"
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}Additional notes:${NC}"
        for warning in "${WARNINGS[@]}"; do
            echo "  • $warning"
        done
    fi
    exit 1
fi
