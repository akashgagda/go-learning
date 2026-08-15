---
chapter: 03
title: Iteration
status: done
date: 2026-08-15
tags: [go, chapter]
---

# Iteration

## Concepts learned
- `for i := 0; i < n; i++` — Go's only loop keyword (no `while`/`do`); no parens around the three parts, braces required.
- `var repeated string` declares a zero-value variable, vs `:=` which declares and initializes.
- `+=` add-and-assign operator (works for strings and numbers).
- Untyped constants: `const repeatCount = 5` (no explicit type).
- Benchmarks: `func BenchmarkRepeat(b *testing.B)` with `for b.Loop() { ... }`; run with `go test -bench=. -benchmem` for `B/op` and `allocs/op` columns.
- Strings are immutable — `+=` copies the whole string each time; `strings.Builder` writes into a growable buffer instead.

## Key snippet
```go
func Repeat(character string) string {
	var repeated strings.Builder
	for i := 0; i < repeatCount; i++ {
		repeated.WriteString(character)
	}
	return repeated.String()
}
```

## Gotchas / mental model
- Only the benchmark loop body is timed — setup/cleanup outside `b.Loop()` doesn't count.
- Mental model: `strings.Builder` is not itself a string — you must call `.String()` to get the result. Benchmark before/after a "performance" refactor instead of guessing; proof beats intuition.

## Tests
`go test ./03-iteration/...` → ok; benchmark dropped 65.63 → 15.50 ns/op and 4 → 1 allocs/op after the Builder refactor

## Self-test
- Why does `repeated += character` cause 4 heap allocations per call?::Strings are immutable, so `+=` copies the entire accumulated string on every iteration. #flashcards
- How does `strings.Builder` avoid those allocations?::It writes into a growable buffer and returns a single string at the end via `.String()`, so it never copies the accumulated value per append. #flashcards
