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

`notes/` is an Obsidian vault: `dashboard.md` (progress), `learning-board.md`
(kanban board), `glossary.md` (vocabulary + flashcards), and one note per chapter.

Recreate the vault setup (config, plugins, registration) on a new machine:

```bash
./scripts/restore-obsidian.sh
```

Verify without touching anything, or commit the current vault state:

```bash
./scripts/restore-obsidian.sh --check
./scripts/restore-obsidian.sh --backup
```

## Agents (Command Code / opencode)

This workspace is set up for both [Command Code](https://commandcode.ai) (`cmd`) and [opencode](https://opencode.ai): `.mcp.json` + `.commandcode/settings.json` (Command Code) and the global `~/.config/opencode/opencode.json` (opencode) hold the Learn Go With Tests, gopls, and pkgsite MCP servers and pre-approve the Go toolchain commands.
