# AGENTS.md

This folder is a personal OS. **Read `CLAUDE.md` first and follow it.** It holds the owner's profile, the folder rules, and how they like to work. This file exists so tools other than Claude Code (Codex, GitHub Copilot, Cursor, Gemini CLI, Grok and others) find the same rules. Where the two disagree, `CLAUDE.md` wins.

## Folder names

If `.claude/folders.json` exists, it maps standard folders to the names this folder already uses (for example `{"projects": "PROJECTS"}`). Wherever `CLAUDE.md`, a routine or a skill names a standard folder (`projects/`, `raw/`, `wiki/`, `daily-logs/` and so on), use the mapped folder instead, subfolders included. A folder that is not listed keeps its standard name.

## If your tool does not run the hooks

In Claude Code, hooks load the two newest daily logs at the start of a session and write a new log when it ends. Most other tools do not run them, so do it by hand:

- **At the start of a session,** read the two newest dated files in `daily-logs/` and `.claude/memory/MEMORY.md` before starting work.
- **Before the session ends,** offer to run the shutdown routine. It writes today's log to `daily-logs/YYYY-MM-DD-convo.md`, using the local date.

## Commands

The routines are Markdown files in `.claude/commands/`: `start`, `brief`, `ingest`, `shutdown`, `lint` and `team-update`. When the user names one ("run shutdown", "brief me on the Q4 launch"), open `.claude/commands/<name>.md` and follow it step by step. Treat `$ARGUMENTS` as whatever the user added after the name.

## Skills and memory

- Skills are in `.claude/skills/<name>/SKILL.md`. When a task matches a skill's description, read it and follow it.
- Standing facts are in `.claude/memory/`, indexed by `MEMORY.md`. Add a file there when the owner tells you something that stays true, and add one line to the index.
