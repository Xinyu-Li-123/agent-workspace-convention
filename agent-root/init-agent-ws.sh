#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <workspace-name>" >&2
  exit 1
fi

workspace_name="$1"
workspace_dir="./$workspace_name"

if [ -e "$workspace_dir" ]; then
  echo "error: '$workspace_dir' already exists" >&2
  exit 1
fi

mkdir -p "$workspace_dir"
cd "$workspace_dir"

git init

mkdir -p docs artifacts tmp

cat >README.md <<'EOF'
# Agent Workspace

## docs

## artifacts
EOF

cat >.gitignore <<'EOF'
/tmp/
/artifacts/
EOF

git add README.md .gitignore

git commit --allow-empty -m "init agent workspace"

echo "initialized agent workspace at: $(pwd)"
