#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Clonado de repos para Odoo 19
# - OCA + Ingadhoc -> ./addons/<repo>
# - Confaa (propios) -> ./custom-addons/<repo>
# ------------------------------------------------------------------------------

BRANCH="19.0"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADDONS_DIR="${BASE_DIR}/addons"
CUSTOM_ADDONS_DIR="${BASE_DIR}/custom-addons"

mkdir -p "$ADDONS_DIR" "$CUSTOM_ADDONS_DIR"

clone_repo () {
  local url="$1"
  local dest_root="$2"
  local name
  name="$(basename "$url" .git)"
  local target="${dest_root}/${name}"

  echo "→ ${name}  (${dest_root})"

  if [ -d "$target/.git" ]; then
    echo "  Ya existe, salteo: $target"
    return 0
  fi

  git clone --depth 1 --branch "$BRANCH" --single-branch "$url" "$target"
}

# --- OCA (van en ./addons) ---
clone_repo https://github.com/OCA/pos.git "$ADDONS_DIR"
clone_repo https://github.com/OCA/sale-workflow.git "$ADDONS_DIR"
clone_repo https://github.com/OCA/server-tools.git "$ADDONS_DIR"
clone_repo https://github.com/OCA/stock-logistics-workflow.git "$ADDONS_DIR"
clone_repo https://github.com/OCA/web.git "$ADDONS_DIR"
clone_repo https://github.com/OCA/account-invoice-reporting.git "$ADDONS_DIR"

# --- Ingadhoc (van en ./addons) ---
clone_repo https://github.com/ingadhoc/account-financial-tools.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/account-invoicing.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/account-payment.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/argentina-sale.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/miscellaneous.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/multi-company.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/odoo-argentina.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/odoo-argentina-ce.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/product.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/purchase.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/sale.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/stock.git "$ADDONS_DIR"
clone_repo https://github.com/ingadhoc/partner.git "$ADDONS_DIR"

# --- Propios (Confaa) -> ./custom-addons ---
clone_repo https://github.com/Confaa/my-odoo-addons.git "$CUSTOM_ADDONS_DIR"

echo
echo "✅ Repos clonados en:"
echo "   - $ADDONS_DIR"
echo "   - $CUSTOM_ADDONS_DIR"
