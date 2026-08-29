# AGENTS.md — Go learning workspace

The user is learning Go as their **first programming language** via *Learn Go With Tests* — the only curriculum. Follow the book, hints-not-solutions, and "explain, then let them type".

## Non-negotiable rules

- Follow the `learn-go-with-tests` skill: test-first (red → green → refactor), one concept at a time, book's wording/style.
- Never paste full solutions — the learner types all code.
- Verify with `go test ./...` before claiming something works.
- A chapter is **Done** only when `notes/<nn>-<name>.md` exists (TDD checklist ticked), `go test ./<nn>-<name>/...` green (and `go test -race` green from ch.10 onward), `FOG CLEARED:` in Gotchas, and kanban card moved to **Done**.
- Two load-bearing files — read before teaching:
  - `notes/dashboard.md` — progress
  - `notes/learning-board.md` — kanban (source of truth for chapter status)
- Don't commit or push unless the learner asks.
- No inline citations by default — never emit `// <path>:<line>` or `(<path>:<line>)` / `file:line` noise in answers. Explain in words only. Only add precise `path:line` cites when user says `with cites`.

## Project facts

- Module `example.com/go-learning` (root `go.mod`). One package per numbered chapter (`01-hello-world` … `10-concurrency`); kanban board is the source of truth.
- MCP servers in global `~/.config/opencode/opencode.json`: `learn-go-with-tests` (`searchDocumentation`/`getPage`), `gopls`, `pkgsite`. Use the book MCP before GitHub or `learn-go-with-tests.pdf`.
- `notes/` is an Obsidian vault: `dashboard.md`, `learning-board.md`, `attachments/`. `glossary.md` is archived — wording/style is book-owned via MCP. `_templates/chapter.md` scaffolds new notes (frontmatter `status: todo|in-progress|complete`, `tags: [go, chapter]`).
- Flashcards `#flashcards` in chapter notes via Obsidian SRS — book sentences via MCP.

## Commands

| Goal | Command |
| --- | --- |
| All tests | `go test ./...` |
| One chapter | `go test ./<nn>-<name>/...` |
| Race detector (ch.10+) | `go test -race ./<nn>-<name>/...` |
| Vet / Format | `go vet ./...` / `gofmt -w .` |
| Vault check/restore | `./scripts/restore-obsidian.sh --check` / `./scripts/restore-obsidian.sh` |
