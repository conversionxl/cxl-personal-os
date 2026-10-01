# CXL Personal OS

A starter repo that gives Claude Code a working memory of your job. Built for the CXL AI Native Marketer cohort.

Claude starts every session knowing nothing about the last one. This repo fixes that with plain Markdown files you own: a daily log written automatically at the end of every session, project files that hold the state of your work, and a handful of commands for the daily and weekly loop. Open it in Obsidian and it is also a linked second brain.

## Set up (10 minutes)

No terminal needed. Claude runs the setup commands for you and asks before each one.

**1. Install Claude Code.** Use the Claude desktop app (its **Code** tab) or the Claude Code extension for VS Code. See the [install docs](https://docs.claude.com/en/docs/claude-code/overview). On Windows, Claude Code also needs Git for Windows; the install docs cover it.

**2. Make your own private copy.** Your logs and projects are private, so do not work in a public fork.
- On this page, click **Use this template → Create a new repository**, choose **Private**, and create it.
- Clone it to your computer with [GitHub Desktop](https://desktop.github.com/) (**File → Clone repository**) or VS Code (**Clone Git Repository** on the Welcome screen). Both sign you in to GitHub in the browser.
- No GitHub? Click **Code → Download ZIP** and unzip it. Everything works on one machine; see [Without GitHub](#without-github).

**3. Open the folder in Claude and type `/start`.**
- **Desktop app:** open the **Code** tab, set Environment to **Local**, and pick the folder.
- **VS Code:** **File → Open Folder**, then open the Claude Code panel.
- **Cowork:** point Cowork at the folder and ask: *"Run the start command from `.claude/commands/start.md`"*. Cowork does not show repo commands as `/` commands, so run each one by asking for it this way. Cowork also does not run hooks, so run `/shutdown` (by asking) at the end of each day to write your daily log.

`/start` checks your setup and installs what is missing with your OK: `jq` (every hook needs it, or daily logs are not written), the `claude` command-line tool (the daily log hooks call it), and optionally `gh` (for pushing to GitHub). It also links memory, explains the system, fills in the "About me" section of `CLAUDE.md`, and creates your first project files.

**Can't install software on your laptop?** The repo still works: run `/shutdown` at the end of each session and it writes the daily log without hooks.

**4. (Optional) Open the folder as an Obsidian vault** to browse your notes, follow `[[wikilinks]]`, and see the backlinks graph.

## What's inside

```
CLAUDE.md          The operating manual Claude reads every session
projects/          One folder per active project (start from _template.md)
raw/               Inbox for unstructured dumps, processed by /ingest
daily-logs/        One log per day, written automatically
frameworks/        Your reusable methods and checklists
wiki/              Durable reference: people, tools, concepts
drafts/            Content in progress
team-updates/      Weekly standup updates built from your logs
.claude/
  commands/        /start, /brief, /ingest, /shutdown, /lint, /team-update
  skills/          Know-how Claude applies automatically (example: my-voice)
  agents/          Specialists Claude hands whole jobs to (example: researcher)
  hooks/           Scripts that run on session start, compaction, and end
  memory/          Standing facts, indexed by MEMORY.md
  link-memory.sh   Links memory to the repo copy (/start runs it on each machine)
```

## Commands

| Command | When | What it does |
|---|---|---|
| `/start` | First session, or `/start tour` any time | Setup, tour, and personalization |
| `/brief <subject>` | Before a meeting or context switch | Everything the repo (plus email and calendar, if connected) knows about a person, project, or topic |
| `/ingest` | When `raw/` fills up | Proposes where each raw dump belongs and files it after you confirm |
| `/shutdown` | End of day | Reconciles the day, routes commitments into projects, writes a rich daily log, offers to push |
| `/lint` | Weekly | Health check: contradictions, stale claims, orphans, missing concepts, neglected projects, unsourced claims |
| `/team-update <period>` | When you owe a status update | Standup-format update from your daily logs |

## What runs automatically

| When | What |
|---|---|
| Session start | Loads your two most recent daily logs. Backfills logs for past days that were missed. Reminds you if `/lint` is overdue. Writes last week's team update if it is missing. |
| Before context compaction | Snapshots the files you changed, your exact prompts, and git state, and restores them afterwards. |
| Session end | Writes today's daily log from the session. Appends if the day already has one; never overwrites. |

## Memory vs daily logs

| | Built-in memory (`.claude/memory/`) | Daily logs (`daily-logs/`) |
|---|---|---|
| Holds | Standing facts: preferences, key people, where things live | What happened: work done, decisions, commitments, next steps |
| Updated | When Claude learns something durable | Automatically at the end of every session |
| Answers | "What is always true?" | "Where did we leave off?" |

Both are plain files in your repo. You can read them, fix them, and take them with you.

## Working across machines

Run `/start` once on each machine after cloning. It links Claude's memory to the repo copy instead of a machine-local folder. Push at the end of the day (`/shutdown` offers to), and at the start of the day on another machine ask Claude to *"pull the latest from GitHub"*.

## Without GitHub

Fine to start without it. On one machine, every folder, command, and daily log works the same. What you give up:

- **Version history.** No way to see or undo what changed in a project file, memory, or `CLAUDE.md`.
- **Sync across machines.** Your laptop and desktop drift apart.
- **Template updates** from CXL as the starter improves.
- **The more complex setups later in the cohort** that build on git: shared team repos, pull-request reviews, automated team updates.

You can add it any time. Ask Claude: *"Put this folder on GitHub as a new private repo."* It uses the `gh` tool if it is installed and signed in. Without it, use [GitHub Desktop](https://desktop.github.com/): **File → Add local repository**, then **Publish repository** with **Keep this code private** ticked.
