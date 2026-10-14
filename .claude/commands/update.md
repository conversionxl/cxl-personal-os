---
description: Bring CXL's latest hooks, commands, skills and frameworks into this folder. Shows what changed and applies only on your yes. Your projects, logs, memory and brand brain are never touched.
---

# /update

Update the system files in this folder from the CXL template. Works for a repo made from the GitHub template, a fork, a clone or a ZIP download. Do not use `git pull` for this: a repo made from a template shares no history with CXL's, so git refuses the merge.

1. **Check.** Run `bash .claude/update.sh check` and read the output. If the folder has no `.claude/update.sh` (set up before `/update` existed), download it first: `curl -fsSL https://raw.githubusercontent.com/<template>/main/.claude/update.sh -o .claude/update.sh`, where `<template>` is the CXL repo this folder came from (`conversionxl/cxl-personal-os`, `conversionxl/cxl-marketing-brain` or `conversionxl/cxl-campaign-engine`; ask if it is not clear from `CLAUDE.md`).
2. **Report** in one table, grouped by what the user has to decide. Nothing is written yet.

   | Group | Meaning | Default |
   |---|---|---|
   | NEW | In the template, not here | Add |
   | UPDATE | An earlier CXL version the user never edited | Replace |
   | CHANGED | The user edited it, and CXL changed it too | Merge (step 4) |
   | REVIEW | `CLAUDE.md`, `.claude/settings.json`, `.gitignore`, `.gitattributes` | Merge (step 4) |
   | REMOVED | An unedited CXL file the template no longer ships | Ask; never delete on the default |

   For each UPDATE and CHANGED file, say in a few words what changed (read `diff <local> <download>/template/<path>`). If `Up to date` covers everything and no line was printed, say so, clean up (step 6) and stop.
3. **Ask once:** apply NEW and UPDATE as listed? Then run `bash .claude/update.sh apply <download> <path> <path> ...` with the template paths the user accepted.
4. **Merge CHANGED and REVIEW files one at a time.** Show the diff. Keep everything the user wrote (their "About me", brand source, folder map rule, their own permissions, hooks and rules) and bring in only CXL's changes. In `.claude/settings.json`, add new hook entries from the template next to the user's own, never replacing them. Write the merged file only after the user says yes to it. Edit inside `.claude/` with the shell (a heredoc), as `CLAUDE.md` says.
5. **New hooks or commands.** If a NEW or UPDATE file is a hook, check that `.claude/settings.json` registers it after step 4; if not, say so. Tell the user that hook changes take effect in the next session.
6. **Clean up and record.** Run `bash .claude/update.sh clean <download>`. If the folder is a git repo, offer to commit the update as one commit (`Update from the CXL template`). Mention the update in today's daily log.

Never touch `projects/` (beyond `_template.md` and `README.md`), `daily-logs/`, `wiki/`, `drafts/`, `team-updates/`, `.claude/memory/` or the user's own files in `raw/`; `update.sh` does not compare them. If `.claude/folders.json` maps a folder, `update.sh` already reads and writes the mapped name.
