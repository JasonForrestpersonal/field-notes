#!/usr/bin/env bash
# Field Notes — create the repo, push, and switch on GitHub Pages.
#   bash setup.sh [repo-name] [public|private]
set -euo pipefail

REPO="${1:-field-notes}"
VIS="${2:-public}"

command -v git >/dev/null || { echo "git not found"; exit 1; }
command -v gh  >/dev/null || { echo "gh not found — run: brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "not signed in — run: gh auth login"; exit 1; }

# git refuses to commit without an identity; borrow the GitHub one if it's unset
git config user.name  >/dev/null 2>&1 || git config --global user.name  "$(gh api user --jq '.name // .login')"
git config user.email >/dev/null 2>&1 || git config --global user.email "$(gh api user --jq '.id')+$(gh api user --jq .login)@users.noreply.github.com"

[ -d .git ] || git init -q
git add -A
git diff --cached --quiet || git commit -qm "Field Notes: five rendering and animation experiments"
git branch -M main

gh repo create "$REPO" --"$VIS" --source=. --remote=origin --push

OWNER=$(gh api user --jq .login)
echo '{"source":{"branch":"main","path":"/"}}' \
  | gh api -X POST "repos/$OWNER/$REPO/pages" --input - >/dev/null 2>&1 \
  || echo '{"source":{"branch":"main","path":"/"}}' | gh api -X PUT "repos/$OWNER/$REPO/pages" --input - >/dev/null 2>&1 \
  || echo "note: enable Pages by hand — Settings → Pages → main → / (root)"

LOWER=$(printf '%s' "$OWNER" | tr '[:upper:]' '[:lower:]')
echo
echo "Repo : https://github.com/$OWNER/$REPO"
echo "Site : https://$LOWER.github.io/$REPO/   (first build takes a minute or two)"
