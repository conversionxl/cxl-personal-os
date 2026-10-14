#!/usr/bin/env bash
# /update: brings CXL's latest system files (hooks, commands, skills, agents,
# frameworks, CLAUDE.md, AGENTS.md) into this folder without touching your own
# work. It downloads the template fresh and compares file by file, so it works
# the same for a repo made from the GitHub template, a fork, a clone or a ZIP
# download: no shared git history is needed.
#
#   bash .claude/update.sh check                  download and sort every file
#   bash .claude/update.sh apply <dir> <path>...  copy those template files in
#   bash .claude/update.sh clean <dir>            remove the download
#
# check prints one line per system file that is not already up to date:
#   NEW      in the template, not in this folder
#   UPDATE   this folder has an earlier CXL version you never edited: safe
#   CHANGED  you edited it and the template moved on: merge by hand
#   REVIEW   CLAUDE.md, settings and git files: always merged by hand
#   REMOVED  an unedited CXL file the template no longer ships
# Without git, edits cannot be told apart from earlier versions, so every
# differing file is CHANGED.
#
# Shared by cxl-personal-os, cxl-marketing-brain and cxl-campaign-engine: keep
# the copies identical except the TEMPLATE line. Written for bash 3.2.
TEMPLATE="conversionxl/cxl-personal-os"
BRANCH="main"
PREFIX="cxl-update."

# apply re-runs from a copy in the download, so it passes the folder along.
ROOT="${CXL_UPDATE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT" || exit 1

# The folder map sends frameworks/, projects/ and raw/ files to the user's own
# folder names. A folder from before the map existed has no lib: no mapping.
if [ -f .claude/hooks/lib-folders.sh ]; then
  . .claude/hooks/lib-folders.sh
else
  pos_map_path() { printf '%s' "$2"; }
fi

# is_system <template path>: CXL owns it. Your notes, logs, memory, brand
# brain, drafts and campaigns are never compared.
is_system() {
  case "$1" in
    *..*|/*) return 1 ;;
    .claude/memory/*|.claude/state/*|.claude/settings.local.json|.claude/folders.json) return 1 ;;
    .claude/*|AGENTS.md|CLAUDE.md|README.md|.gitignore|.gitattributes) return 0 ;;
    frameworks/*|projects/_template.md|projects/README.md) return 0 ;;
    raw/*/README.md|raw/README.md|raw/*/example/*) return 0 ;;
  esac
  return 1
}

# by_hand <template path>: the user edits these as a matter of course.
by_hand() {
  case "$1" in
    CLAUDE.md|.claude/settings.json|.gitignore|.gitattributes) return 0 ;;
  esac
  return 1
}

have_git() { command -v git >/dev/null 2>&1; }

case "$1" in
  check)
    dir="$(mktemp -d "${TMPDIR:-/tmp}/${PREFIX}XXXXXX")" || exit 1
    tpl="$dir/template"
    if have_git; then
      git clone -q --branch "$BRANCH" "https://github.com/$TEMPLATE.git" "$tpl" 2>/dev/null || { echo "Could not download https://github.com/$TEMPLATE. Check the connection and try again."; rm -rf "$dir"; exit 1; }
      # Every file version CXL ever shipped. A local file that matches one of
      # them has not been edited, so replacing it loses nothing.
      git -C "$tpl" rev-list --objects --all | cut -d' ' -f1 > "$dir/shipped"
      git -C "$tpl" ls-files > "$dir/files"
    else
      mkdir -p "$tpl"
      curl -fsSL "https://codeload.github.com/$TEMPLATE/tar.gz/refs/heads/$BRANCH" | tar -xz --strip-components=1 -C "$tpl" 2>/dev/null || { echo "Could not download https://github.com/$TEMPLATE. Check the connection and try again."; rm -rf "$dir"; exit 1; }
      : > "$dir/shipped"
      (cd "$tpl" && find . -type f | sed 's|^\./||') > "$dir/files"
    fi
    shipped() { have_git && grep -qx "$(git hash-object "$1")" "$dir/shipped"; }

    echo "Template: https://github.com/$TEMPLATE ($BRANCH), commit $(git -C "$tpl" rev-parse --short HEAD 2>/dev/null || echo unknown)"
    echo "Download: $dir"
    same=0
    while IFS= read -r f; do
      is_system "$f" || continue
      [ "$f" = "${f#.git/}" ] || continue
      local_path="$(pos_map_path "$ROOT" "$f")"
      if [ ! -e "$local_path" ]; then echo "NEW $f -> $local_path"
      elif cmp -s "$tpl/$f" "$local_path"; then same=$((same+1))
      elif by_hand "$f"; then echo "REVIEW $f -> $local_path"
      elif shipped "$local_path"; then echo "UPDATE $f -> $local_path"
      else echo "CHANGED $f -> $local_path"
      fi
    done < "$dir/files"
    # System files here that the template dropped, only if never edited.
    if have_git; then
      for d in .claude/hooks .claude/commands .claude/skills .claude/agents; do
        [ -d "$d" ] || continue
        find "$d" -type f | while IFS= read -r f; do
          grep -qx "$f" "$dir/files" && continue
          shipped "$f" && echo "REMOVED $f"
        done
      done
    fi
    echo "Up to date: $same files."
    ;;

  apply)
    dir="$2"; shift 2
    case "$(basename "$dir")" in "$PREFIX"*) ;; *) echo "Not an update download: $dir"; exit 1 ;; esac
    [ -d "$dir/template" ] || { echo "Download not found: $dir. Run check again."; exit 1; }
    # This script may be one of the files being replaced, and bash reads a
    # script as it runs, so carry on from a copy.
    if [ -z "$CXL_UPDATE_COPY" ]; then
      cp "${BASH_SOURCE[0]}" "$dir/update.sh"
      CXL_UPDATE_COPY=1 CXL_UPDATE_ROOT="$ROOT" exec bash "$dir/update.sh" apply "$dir" "$@"
    fi
    for f in "$@"; do
      is_system "$f" || { echo "Skipped (not a system file): $f"; continue; }
      [ -f "$dir/template/$f" ] || { echo "Skipped (not in the template): $f"; continue; }
      local_path="$(pos_map_path "$ROOT" "$f")"
      mkdir -p "$(dirname "$local_path")"
      cp "$dir/template/$f" "$local_path"
      [ -x "$dir/template/$f" ] && chmod +x "$local_path"
      echo "Updated: $local_path"
    done
    ;;

  clean)
    case "$(basename "$2")" in "$PREFIX"*) rm -rf "$2" && echo "Removed $2" ;; *) echo "Not an update download: $2"; exit 1 ;; esac
    ;;

  *)
    echo "Usage: bash .claude/update.sh check | apply <dir> <path>... | clean <dir>"
    exit 1
    ;;
esac
