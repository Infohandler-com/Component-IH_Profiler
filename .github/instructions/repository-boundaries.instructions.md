---
applyTo: '**'
description: Repository edit boundaries and safety rules
---

# Repository Boundaries and Safe Edit Rules

## Scope
This is guidance for safe modification boundaries in this repository.


## Hard Boundaries
1. Treat external dependency folders as read-only unless explicitly requested.
2. Do not modify component or plugin code without explicit user approval.
3. Avoid editing generated artifacts unless task scope requires it.
4. Avoid committing or editing machine-specific preference files unless requested.


## Sensitive Paths
Default read-only unless explicitly approved:
- Components/
- Plugins/
- WEB_Outbox/
- WEB_TEMP/
- Logs/
- App Logs/
- userPreferences.*


## Change Scope Discipline
1. Keep edits focused to the minimal set of files needed.
2. Avoid unrelated refactors while implementing requested work.
3. Preserve existing behavior unless change request requires behavior updates.
4. Document assumptions when touching critical request routing or reporting paths.


## Safety Workflow
1. Inspect current uncommitted changes before editing.
2. Never revert unrelated user changes.
3. Flag unexpected modifications immediately and ask how to proceed.
4. Prefer non-destructive operations in all workflows.


## Review Notes
1. Confirm whether any specific component subfolders are allowed for edits.
2. Confirm whether output folders should always be ignored during code changes.
3. Confirm preferred handling for environment-specific config file updates.
