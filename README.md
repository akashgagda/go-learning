# Go Learning

[Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests/) — one package per chapter, test-first.

```bash
go test ./...              # all
go test ./01-hello-world/...  # one chapter
```

## Chapters

`01-hello-world` → `10-concurrency` (see `notes/learning-board.md`).

## Notes

Vault `dashboard.md` + `learning-board.md` load-bearing, `glossary.md` archived (book pedagogy via MCP `searchDocumentation→getPage`).

```bash
./scripts/restore-obsidian.sh         # restore vault
./scripts/restore-obsidian.sh --check # verify
./scripts/restore-obsidian.sh --backup # backup notes/
```

## Agents

`~/.config/opencode/opencode.json` — `learn-go-with-tests` (book pedagogy) + `gopls` + `pkgsite` MCPs. Skills: `learn-go-with-tests` + 3 companions.
