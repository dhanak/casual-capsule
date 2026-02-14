# AGENTS.md

## Purpose

This file defines repository-level collaboration rules for coding agents and contributors.

## GitOps Expectations

1. Keep changes small, focused, and easy to review.
2. Prefer incremental pull requests over large multi-topic changes.
3. Update documentation when behavior or developer workflow changes.
4. Do not rewrite shared history unless explicitly requested.
5. Validate changes locally when practical before proposing them.

## Commit Ownership

1. The repository owner creates commits manually and signs them with GPG keys.
2. Agents must not run `git commit` unless explicitly asked.
3. Agents should prepare commit messages for the currently staged changes when requested.

## Commit Message Format

1. Use a prefix in the headline.
2. Capitalize the first character of the commit message headline.
3. Keep the headline concise and specific.
4. Write the body in full sentences.
5. In the body, describe what changed and why it was needed.

### Preferred Headline Pattern

`<type>(<scope>): <Headline>`

Examples:

- `feat(container): Add Codex runtime image`
- `fix(compose): Correct volume mount path`
- `docs(readme): Clarify usage instructions`

## Staging-Aware Workflow

1. Assume the staged index is the source of truth for commit message generation.
2. If asked for a commit message, summarize only what is currently staged.
3. If staged and unstaged changes differ, call out that the message is based on staged content.

## Docker Process Expectations

1. Keep images reproducible by pinning key tool and runtime versions where practical.
2. Minimize image size and attack surface by avoiding unnecessary packages.
3. Prefer non-root runtime execution unless root is explicitly required.
4. Keep Docker and Compose configuration portable across developer machines.
5. Handle secrets at runtime through environment variables or secret managers, not hardcoded values.

## Compose Conventions

1. Prefer environment-variable-based host paths over user-specific absolute paths.
2. Use restart policies that match workload type. Interactive developer shells should not auto-restart by default.
3. Keep service definitions explicit about required environment variables and mounted directories.
