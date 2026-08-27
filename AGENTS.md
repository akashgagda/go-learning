# AGENTS.md — Go learning workspace

The user is learning Go as their **first programming language**, working through the
book *Learn Go With Tests* (LGWT) — the only curriculum.

This is load-bearing: it justifies hints-not-solutions, plain language, and the
"explain, then let them type" rule. Any agent working in this repo must read every
existing chapter note in `notes/` before touching code.

## Non-negotiable rules

- Follow the `learn-go-with-tests` skill: test-first (red → green → refactor),
  hints instead of solutions, one concept at a time, plain language.
- **Never paste full solutions** — the learner must type their own code.
- Never rewrite the learner's files silently; explain, then let them type.
- Verify with tests before claiming something works: `go test ./...` from the root.
- Pair with these skills: `learn-go-with-tests` (session flow, TDD loop),
  `study-habit-coach` (planning, friction), `socratic-tutor` (explain by
  questioning), `concept-explainer` (deep-dive a single idea).
- A chapter isn't **Done** until: the `notes/<nn>-<name>.md` note exists, the
  TDD checklist is ticked, and `go test ./<nn>-<name>/...` is green. From
  chapter 10 onwards, also `go test -race ./<nn>-<name>/...` must be green
  (the race detector is part of verification, not optional). The learner's
  "FOG CLEARED:" line in the note's mental-model section is the conceptual
  half of Done — the test-suite green is the other half. Move the card
  on the board yourself once all of that is true.
- Respect the learner's notes. Two files are load-bearing — read them
  before teaching or reviewing:
  - `notes/dashboard.md` — at-a-glance progress; also home of the ` ```tasks ``` ` open-tasks block
  - `notes/learning-board.md` — kanban board; the source of truth for chapter status
- Don't commit or push to git unless the learner asks — commits are theirs to make.

## Project facts

- Module: `example.com/go-learning` (root `go.mod`). Chapters are numbered folders,
  one package per folder (`01-hello-world`, `02-integers`, ...); the kanban board
  `notes/learning-board.md` is the source of truth for which chapters exist and their
  status — check it rather than assuming.
- Run all tests: `go test ./...`; one chapter: `go test ./09-mocking/...`
- MCP servers in `.mcp.json`: `learn-go-with-tests` (GitBook HTTP — `searchDocumentation`,
  `getPage` for chapter content), `gopls` (Go intelligence), `pkgsite` (pkg.go.dev).
  Use the book MCP before falling back to GitHub or the PDF.
- Chapter content sources, in priority order: the GitBook MCP (`searchDocumentation`,
  `getPage`), then https://github.com/quii/learn-go-with-tests, then the offline
  copy `learn-go-with-tests.pdf` in the workspace root.
- `notes/` is an Obsidian vault: `dashboard.md` is the at-a-glance home, the kanban
  `learning-board.md` tracks chapters, and `attachments/` holds images.
  `notes/glossary.md` remains as archived vocabulary but is **not** the anchor
  source — plain-words anchors are book-owned via the GitBook MCP
  (`searchDocumentation` → `getPage`). `chapter.md` in `_templates/` is the note
  template (Templater syntax). New chapter notes MUST be created from
  `_templates/chapter.md` so frontmatter, status banner, TDD checklist, and vault
  footer all stay consistent. Chapter notes carry frontmatter
  (`status: todo|in-progress|complete`, `tags: [go, chapter]`), a status banner,
  and a vault-navigation footer.
- Flashcards: `#flashcards` lines in chapter notes are scheduled by the Obsidian
  Spaced Repetition plugin — treat them as the review layer. Anchor phrasing
  comes from book sentences via the MCP; do not pull from `notes/glossary.md`.
- Vault tooling: recreate the vault setup on a fresh machine with
  `./scripts/restore-obsidian.sh` (`--check` verifies without changing anything,
  `--backup` commits the current vault state to git).
- Git: the repo lives on GitHub (origin → `akashgagda/go-learning`, private); the
  learner commits progress manually, chapter by chapter.

## Commands

| Goal | Command |
| --- | --- |
| Run all tests | `go test ./...` |
| One chapter | `go test ./<nn>-<name>/...` |
| Verbose test output (shows subtests like `TestHello/in_Spanish`) | `go test -v ./<nn>-<name>/...` |
| Run with the race detector (chapter 10+ — required for Done) | `go test -race ./<nn>-<name>/...` |
| Run benchmarks (chapter 03+) | `go test -bench=. -benchmem ./<nn>-<name>/...` |
| Format code | `gofmt -w .` |
| Vet | `go vet ./...` |
| Run a program | `go run .` (inside a `package main` folder) |
| Git status | `git status --short` |
| Git diff | `git diff` |
| Verify Obsidian vault without changes | `./scripts/restore-obsidian.sh --check` |
| Restore Obsidian vault | `./scripts/restore-obsidian.sh` (`--check` to verify, `--backup` to commit state) |
