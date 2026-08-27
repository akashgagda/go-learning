---
chapter: "09"
title: Mocking
status: complete
tags: [go, chapter]
date: 2026-08-24
---

# Mocking

> Status: ✅ COMPLETE — fog cleared: timeline spy, one-object-two-roles, `&` vs `*`, and how the two files connect through `package main` + interfaces.

## Concepts learned
- Slow tests hurt — `time.Sleep` in code made a test take 3s; injecting a fake sleeper made it ~0s.
- A mock/spy is a fake tool the test injects: it measures behavior instead of doing real work.
- `SpySleeper` (counts calls) vs `SpyCountdownOperations` (records a timeline) — the timeline spy catches ORDER bugs the count spy misses.
- A type satisfies an interface by having the method(s) — `SpyCountdownOperations` has both `Sleep()` and `Write(...)`, so it's both a `Sleeper` and an `io.Writer`.

## Key snippet
```go
func Countdown(out io.Writer, sleeper Sleeper) {
	for i := countdownStart; i > 0; i-- {
		fmt.Fprintln(out, i)
		sleeper.Sleep()
	}
	fmt.Fprint(out, finalWord)
}
```

## Gotchas / mental model
- Two tools are injected: `out` (where to write) and `sleeper` (how to pause). Real world: `os.Stdout` + `DefaultSleeper`. Test world: buffer + spy.
- `bytes.Buffer` keeps the actual text (read back with `.String()`); a spy's `Write` throws the bytes away and only logs "write happened".
- `want := []string{...}` slices can't be compared with `==`; use `reflect.DeepEqual`.
- Backtick strings capture tabs literally — the countdown `want` must be flush-left.
- **FOG CLEARED:** the timeline spy plays both `io.Writer` and `Sleeper` at once (`Countdown(spy, spy)`) because a struct can implement many interfaces; `&` = action (address-of), `*T` = type ("pointer to T"), works for any type; `_test.go` files only load under `go test`; both files connect via `package main`.

## TDD checklist
- [x] #task Write the failing test
- [x] #task Make it pass (minimal code)
- [x] #task Refactor, re-run tests and benchmark
- [x] #task Update this note with what you learned

## Tests
`go test ./09-mocking/...` → `ok` — final version uses `TestCountdown` with two subtests (`prints 3 to Go!`, `sleep before every print`); the redundant count spy was deleted. `go test ./...` all green.

## Self-test
<!-- One card per idea. Format: Question::Answer  #flashcards -->
- What is mocking?::Replacing a real tool with a fake (spy) in tests so you can control it and inspect how it was used — instead of waiting 3s or reading the screen. #flashcards
- How is a type chosen as an io.Writer?::If it has the method `Write(p []byte) (n int, err error)`. #flashcards
- Why can the timeline spy be passed twice to Countdown?::Because it implements BOTH interfaces: it has `Sleep()` (Sleeper) and `Write(...)` (io.Writer). #flashcards

---
[[dashboard|🏠 Dashboard]] · [[glossary|📖 Glossary (archived)]] · [[learning-board|📋 Board]]
