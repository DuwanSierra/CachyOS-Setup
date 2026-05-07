#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[..] $1${NC}"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  CachyOS Setup"
echo "  ============="
echo ""

[[ $EUID -eq 0 ]] && err "No corras este script como root. Usa tu usuario normal."

if command -v yay &>/dev/null; then
  ok "yay ya instalado"
else
  warn "yay no encontrado. Instalando desde AUR..."
  sudo pacman -S --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay-install
  (cd /tmp/yay-install && makepkg -si --noconfirm)
  rm -rf /tmp/yay-install
  ok "yay instalado"
fi

if command -v ansible &>/dev/null; then
  ok "ansible ya instalado ($(ansible --version | head -1))"
else
  warn "Instalando ansible..."
  sudo pacman -S --noconfirm ansible
  ok "ansible instalado"
fi

if command -v curl &>/dev/null; then
  ok "curl ya instalado"
else
  warn "Instalando curl..."
  sudo pacman -S --noconfirm curl
  ok "curl instalado"
fi

warn "Instalando colecciones de Ansible..."
ansible-galaxy collection install -r "$REPO_DIR/ansible/requirements.yml" -p ~/.ansible/collections
ok "Colecciones instaladas"

echo ""
warn "Corriendo playbook..."
echo ""

(cd "$REPO_DIR/ansible" && ansible-playbook playbooks/setup.yml)

echo ""
ok "Instalacion completa."
