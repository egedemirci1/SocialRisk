# AGENTS.md

## Project Overview
This project was initially prototyped using Antigravity.
Development is now continued using Codex.

Your job is to extend and improve the project without unnecessary rewrites.

## Development Principles
- Prefer minimal diffs.
- Do not rewrite large parts of the code unless explicitly requested.
- Preserve the current architecture when possible.
- Avoid renaming files, classes, or public APIs unless necessary.
- Keep the project buildable after each change.

## Code Style
- Follow existing naming conventions.
- Prefer small, focused functions.
- Avoid overly complex abstractions.
- Add comments only when logic is not obvious.

## Refactoring Rules
- Do not refactor unrelated code.
- If a refactor is needed, propose the plan first.
- Avoid large architectural changes without approval.

## Task Execution Behavior
When given a task:

1. First analyze the relevant code.
2. Identify affected files and logic flow.
3. Propose a short plan.
4. Implement the change.
5. Summarize modified files and potential risks.

## Safety Rules
- Avoid breaking existing features.
- Do not delete code unless clearly safe.
- If unsure about a behavior, explain assumptions before implementing.

## Preferred Workflow
1. Analysis
2. Plan
3. Implementation
4. Review

## Output Expectations
After completing a task, always provide:
- changed files
- short explanation
- possible edge cases