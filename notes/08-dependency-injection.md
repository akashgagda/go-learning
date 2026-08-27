---
chapter: "08"
title: Dependency Injection
status: complete
date: 2026-08-24
tags: [go, chapter]
---

# Dependency Injection

> Status: ✅ COMPLETE — restarted from a clean slate on 2026-08-24.

## Concepts learned
- `fmt.Printf` prints to stdout (the screen) — a fixed destination a test can't read, so it's untestable.
- Dependency injection = passing in ("injecting") the writer so the caller decides *where* output goes: a buffer in tests, `os.Stdout` in a real program.
- A type is an `io.Writer` if it has a `Write(p []byte) (n int, err error)` method. `bytes.Buffer` and `os.File` both have one.

## Key snippet
```go
func Greet(writer io.Writer, name string) {
	fmt.Fprintf(writer, "Hello, %s", name)
}
```

## Gotchas / mental model
- `Printf` vs `Fprintf` is not "screen vs buffer" — it's "fixed destination vs caller-chosen destination". `Fprintf` can write to the screen too.
- `bytes.Buffer{}` is a value, so it needs `&` to become `*bytes.Buffer`, which is what satisfies `io.Writer`.
- `os.Stdout` is already a `*os.File` (a pointer), so it satisfies `io.Writer` as-is — no `&` needed.

## TDD checklist
- [x] #task Write the failing test
- [x] #task Make it pass (minimal code)
- [x] #task Refactor, re-run tests and benchmark
- [x] #task Update this note with what you learned

## Tests
`go test ./08-dependency-injection/...` → `ok example.com/go-learning/08-dependency-injection` (all green, `go test ./...`)

## Self-test
<!-- One card per idea. Format: Question::Answer  #flashcards -->
- Why must `bytes.Buffer{}` be passed with `&` to satisfy `io.Writer`?::Because `Write` is a pointer receiver on `*bytes.Buffer`; the plain value doesn't have the method. #flashcards
- What's the real difference between `Printf` and `Fprintf`?::Not screen vs buffer — `Printf`'s destination is fixed to stdout; `Fprintf` lets the caller pass any writer. #flashcards

---
[[dashboard|🏠 Dashboard]] · [[glossary|📖 Glossary (archived)]] · [[learning-board|📋 Board]]
