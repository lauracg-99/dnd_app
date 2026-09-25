---
name: dnd-notes-and-diaries
description: Use this skill for character notes, journal entries, diaries, campaign records, and narrative content in this app.
---

# Notes and diaries guidance

## Domain focus

This app supports narrative content such as diaries, group notes, character notes, and other writing workflows linked to a character or campaign context.

## Best practices

- Keep narrative data separate from mechanical character stats when practical, but preserve the relationship when needed.
- Avoid losing draft content or timestamps during save and reload flows.
- Keep entry ordering and grouping predictable, especially when sorting by date, group, or character.
- Preserve rich text or plain text content carefully if the app supports structured note editing.

## Rules for implementation

- Prefer service or model-level handling for note creation, update, and retrieval.
- Treat note saving as a persistence flow that must be resilient to user interruptions and app restarts.
- Ensure empty and loading states are user-friendly and consistent with the rest of the app.

## Validation

- Check that diary entries and notes persist after saving and reopening the screen.
- Confirm that grouping, ordering, and filtering remain consistent.
- Verify that UI updates reflect note edits without stale or duplicated items.
