# Go Learning

Working through [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests/).

## Layout

Single module with one package per chapter. Run all tests from the root:

```bash
go test ./...
```

Run tests for one chapter:

```bash
go test ./01-hello-world/...
```

## Chapters

- `01-hello-world` - first program, testing basics
- `02-integers` - integers, table-driven tests
- `03-iteration` - loops, benchmarks
- `04-arrays-and-slices` - slices, collection functions
- `05-structs-methods-interfaces` - structs, methods, interfaces
- `06-pointers-and-errors` - pointers, error handling
- `07-maps` - maps, sentinel errors, subtests
- `08-dependency-injection` - dependency injection
- `09-mocking` - mocking with dependency injection
- `10-concurrency` - concurrency, maps of results (website checker)

## Notes (Obsidian)

`notes/` is an Obsidian vault: `dashboard.md` + `learning-board.md` are load-bearing (progress + kanban), one note per chapter, `glossary.md` archived vocabulary (anchor source is now **book-owned** via the GitBook MCP: `searchDocumentation` → `getPage` verbatim sentences, citation `none`).

Recreate the vault setup (config, plugins, registration) on a new machine:

```bash
./scripts/restore-obsidian.sh
```

Verify without touching anything, or commit the current vault state:

```bash
./scripts/restore-obsidian.sh --check
./scripts/restore-obsidian.sh --backup
```

## Agents (opencode)

This workspace is set up for [opencode](https://opencode.ai): the global `~/.config/opencode/opencode.json` holds the Learn Go With Tests (book-owned anchors), gopls, and pkgsite MCP servers and pre-approves the Go toolchain commands. Skills stack is `learn-go-with-tests` + `concept-explainer` / `socratic-tutor` / `study-habit-coach` (3 companions, no deeptutor).
