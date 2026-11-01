#!/bin/bash
# Puts the Shadowing mini app online for free (GitHub Pages).
# Run:  bash ~/Desktop/shadowing-app/publish.sh      (safe to run again after changes)
set -e
cd "$(dirname "$0")"
command -v gh >/dev/null || brew install gh
gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
U=$(gh api user -q .login)

[ -d .git ] || git init -q -b main
git config user.name >/dev/null || git config user.name "$U"
git config user.email >/dev/null || git config user.email "$U@users.noreply.github.com"
git add -A
git commit -q -m "Shadowing app" || true

if gh repo view "$U/shadowing" >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$U/shadowing.git"
  git push -q -u origin main
else
  gh repo create shadowing --public --source=. --push
fi

# Turn on the free website (only needed the first time)
gh api -X POST "repos/$U/shadowing/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true

echo
echo "DONE. Link (ready in 1-2 minutes):  https://$U.github.io/shadowing/"
