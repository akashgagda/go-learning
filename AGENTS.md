# AGENTS.md — Go learning workspace

The user is learning Go as their **first programming language**, working through the
book *Learn Go With Tests* (LGWT) — the only curriculum.

## Non-negotiable rules

- Follow the `learn-go-with-tests` skill: test-first (red → green → refactor),
  hints instead of solutions, one concept at a time, plain language.
- **Never paste full solutions** — the learner must type their own code.
- Never rewrite the learner's files silently; explain, then let them type.
- Verify with tests before claiming something works: `go test ./...` from the root.
- Only move a chapter to **Done** on the kanban board (`notes/learning-board.md`)
  when its test suite passes.
- Respect the learner's notes: check `notes/` (Obsidian vault — per-chapter notes,
  `glossary.md`, `learning-board.md`) before teaching or reviewing.

## Project facts

- Module: `example.com/go-learning` (root `go.mod`). Chapters are numbered folders:
  `01-hello-world`, `02-integers`, `03-iteration`, `04-arrays-and-slices`,
  `05-structs-methods-interfaces`, `06-pointers-and-errors`, `07-maps`,
  `08-dependency-injection`, ...
- Run all tests: `go test ./...`; one chapter: `go test ./08-dependency-injection/...`
- Chapter content comes from the GitBook MCP tools `searchDocumentation` and `getPage`
  (remote server `learn-go-with-tests` in opencode.json). Fallbacks:
  https://github.com/quii/learn-go-with-tests and the offline copy
  `learn-go-with-tests.pdf` in the workspace root.
- `notes/` is an Obsidian vault: `chapter.md` in `_templates/` is the note template
  (Templater syntax); chapter notes carry frontmatter
  (`status: todo|in-progress|complete`, `tags: [go, chapter]`). `dashboard.md` is
  the vault home.
- Vault tooling: recreate the vault setup on a fresh machine with
  `./scripts/restore-obsidian.sh` (`--check` verifies without changing anything,
  `--backup` commits the current vault state to git).

## Commands

| Goal | Command |
| --- | --- |
| Run all tests | `go test ./...` |
| One chapter | `go test ./<nn>-<name>/...` |
| Format code | `gofmt -w .` |
| Vet | `go vet ./...` |
| Restore Obsidian vault | `./scripts/restore-obsidian.sh` (`--check` to verify, `--backup` to commit state) |
