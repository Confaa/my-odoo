#!/usr/bin/env bash
set -euo pipefail

BRANCH="19.0"
DEST_DIR="addons"

mkdir -p "$DEST_DIR"

clone_repo () {
  local url="$1"
  local name
  name="$(basename "$url" .git)"
  local target="${DEST_DIR}/${name}"

  echo "→ ${name}"

  if [ -d "$target/.git" ]; then
    echo "  Ya existe, salteo: $target"
    return 0
  fi

  # Clona SOLO la rama 18.0, shallow
  git clone --depth 1 --branch "$BRANCH" --single-branch "$url" "$target"
}

# OCA
clone_repo https://github.com/OCA/pos.git
clone_repo https://github.com/OCA/sale-workflow.git
clone_repo https://github.com/OCA/server-tools.git
clone_repo https://github.com/OCA/stock-logistics-workflow.git
clone_repo https://github.com/OCA/web.git
clone_repo https://github.com/OCA/account-invoice-reporting.git

# Ingadhoc
clone_repo https://github.com/ingadhoc/account-financial-tools.git
clone_repo https://github.com/ingadhoc/account-invoicing.git
clone_repo https://github.com/ingadhoc/account-payment.git
clone_repo https://github.com/ingadhoc/argentina-sale.git
clone_repo https://github.com/ingadhoc/miscellaneous.git
clone_repo https://github.com/ingadhoc/multi-company.git
clone_repo https://github.com/ingadhoc/odoo-argentina.git
clone_repo https://github.com/ingadhoc/odoo-argentina-ce.git
clone_repo https://github.com/ingadhoc/product.git
clone_repo https://github.com/ingadhoc/purchase.git
clone_repo https://github.com/ingadhoc/sale.git
clone_repo https://github.com/ingadhoc/stock.git
clone_repo https://github.com/ingadhoc/partner.git

# Propios
clone_repo https://github.com/Confaa/confaa-addons.git
echo
echo "✅ Repos clonados en ./${DEST_DIR}"
