#!/usr/bin/env bash
set -euo pipefail

BRANCH="19.0"
ADDONS_DIR="addons"
CUSTOM_ADDONS_DIR="custom-addons"

die() { echo "ERROR: $*" >&2; exit 1; }

ensure_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Ejecutá esto dentro de un repo git."
}

ensure_gitmodules_present() {
  # Si .gitmodules está trackeado pero no existe, lo restaura
  if git ls-files --error-unmatch .gitmodules >/dev/null 2>&1; then
    if [ ! -f .gitmodules ]; then
      git checkout -- .gitmodules || true
    fi
  fi
  # Si sigue sin existir, lo crea vacío (esto evita el fatal de submodule add)
  [ -f .gitmodules ] || : > .gitmodules
  # Si está trackeado, dejalo coherente en el index
  git add .gitmodules >/dev/null 2>&1 || true
}

rm_submodule_path() {
  local path="$1"

  git submodule deinit -f -- "$path" 2>/dev/null || true
  git rm -f --cached -- "$path" 2>/dev/null || true
  rm -rf ".git/modules/$path" 2>/dev/null || true
  rm -rf "$path" 2>/dev/null || true
}

clean_all_submodules() {
  echo "Limpiando submodules previos..."

  # Asegura .gitmodules para poder leerlo si existe/tracked
  ensure_gitmodules_present

  if [ -s .gitmodules ]; then
    while IFS= read -r key; do
      local path
      path="$(git config -f .gitmodules "$key" || true)"
      [ -n "${path:-}" ] || continue
      echo "  - removiendo: $path"
      rm_submodule_path "$path"
    done < <(git config -f .gitmodules --name-only --get-regexp '^submodule\..*\.path$' 2>/dev/null || true)
  fi

  # Ahora dejamos .gitmodules vacío y coherente
  : > .gitmodules
  git add .gitmodules >/dev/null 2>&1 || true

  # Limpieza física (por si quedaron restos)
  rm -rf "$ADDONS_DIR" "$CUSTOM_ADDONS_DIR" 2>/dev/null || true

  echo
}

add_submodule() {
  local url="$1"
  local dest_root="$2"

  local name target
  name="$(basename "$url" .git)"
  target="${dest_root}/${name}"

  echo "→ ${name}  (${dest_root})"

  # ya existe en .gitmodules
  if git config -f .gitmodules --get "submodule.${target}.url" >/dev/null 2>&1; then
    echo "  Ya estaba en .gitmodules, salteo: $target"
    return 0
  fi

  # si existe en disco, no pisar
  if [ -e "$target" ]; then
    die "El path ya existe en el filesystem: $target (borrá o mové esa carpeta)."
  fi

  mkdir -p "$dest_root"

  ensure_gitmodules_present

  git submodule add -b "$BRANCH" "$url" "$target"

  # shallow + branch en .gitmodules
  git config -f .gitmodules "submodule.${target}.shallow" true
  git config -f .gitmodules "submodule.${target}.branch" "$BRANCH"
  git add .gitmodules >/dev/null 2>&1 || true
}

main() {
  ensure_repo

  # Opcional: si querés forzar que corra solo con working tree limpio, descomentá:
  # git diff --quiet || die "Tenés cambios sin commit. Commit/stash antes de correr."
  # git diff --cached --quiet || die "Tenés cambios staged. Commit/stash antes de correr."

  clean_all_submodules

  mkdir -p "$ADDONS_DIR" "$CUSTOM_ADDONS_DIR"

  # --- OCA ---
  add_submodule https://github.com/OCA/pos.git "$ADDONS_DIR"
  add_submodule https://github.com/OCA/sale-workflow.git "$ADDONS_DIR"
  add_submodule https://github.com/OCA/server-tools.git "$ADDONS_DIR"
  add_submodule https://github.com/OCA/stock-logistics-workflow.git "$ADDONS_DIR"
  add_submodule https://github.com/OCA/web.git "$ADDONS_DIR"
  add_submodule https://github.com/OCA/account-invoice-reporting.git "$ADDONS_DIR"

  # --- Ingadhoc ---
  add_submodule https://github.com/ingadhoc/account-financial-tools.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/account-invoicing.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/account-payment.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/argentina-sale.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/miscellaneous.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/multi-company.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/odoo-argentina.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/odoo-argentina-ce.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/product.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/purchase.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/sale.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/stock.git "$ADDONS_DIR"
  add_submodule https://github.com/ingadhoc/partner.git "$ADDONS_DIR"

  # --- Propios ---
  add_submodule https://github.com/Confaa/my-odoo-addons.git "$CUSTOM_ADDONS_DIR"

  echo
  echo "Listo. Ahora inicializá en shallow:"
  echo "  git submodule update --init --depth 1 --jobs 8"
  echo
  echo "Y commiteá los cambios:"
  echo "  git add .gitmodules"
  echo "  git commit -m \"chore: reset submodules\""
}

main "$@"
