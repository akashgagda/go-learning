---
chapter: "01"
title: Hello, World
status: complete
date: 2026-08-15
tags: [go, chapter]
---

# Hello, World

> Status: ✅ COMPLETE — first program, testing basics, subtests, and the TDD loop.

## Concepts learned
- `t.Run("name", func(t *testing.T) {...})` — subtests group scenarios; failing ones show as `TestHello/in_Spanish` in output.
- `%q` in error messages quotes strings, so `got "Hello, "` vs `want "Hello, World"` shows trailing whitespace clearly.
- Refactor tests too: extract an assertion helper taking `t testing.TB` (satisfied by `*testing.T` and `*testing.B`) with `t.Helper()` so failures report the call site line.
- Default a zero value with `if name == "" { name = "World" }`.
- Magic strings: name them as constants (`const spanish = "Spanish"`); unexported identifiers start lowercase.
- `switch` with `default` beats an `if` chain that checks one value repeatedly.
- Named return value `(prefix string)` — declares `prefix` at its zero value; bare `return` returns it; shows intent in `go doc`.
- Grouped `const` block with blank lines separating related groups.

## Key snippet
```go
func greetingPrefix(language string) (prefix string) {
	switch language {
	case french:
		prefix = frenchHelloPrefix
	case spanish:
		prefix = spanishHelloPrefix
	default:
		prefix = englishHelloPrefix
	}
	return
}
```

## Gotchas / mental model
- Go forbids named `func` declarations inside functions — use a package-level function or a closure (`f := func(...) {...}`).
- `testing.TB` is an interface; never write `*testing.TB`. `t.Errorf` still needs its format args, or you get `%!q(MISSING)`.
- Mental model: a test checks the *return value*, not terminal output — `fmt.Println` inside `Hello` prints but returns nothing useful.
- Listen to the compiler: errors like `too many arguments in call to Hello have (string, string) want (string)` tell you exactly what signature to write next.

## Tests
`go test ./01-hello-world/...` → ok (4 subtests: people, empty string, Spanish, French)

## Self-test
- Why does `assertCorrectMessage` accept `testing.TB` instead of `*testing.T`?::Because `testing.TB` is an interface implemented by both `*testing.T` and `*testing.B`, so one helper works for tests and benchmarks. #flashcards
- What does `t.Helper()` change about failure output?::It marks the function as a helper so failures report the call-site line, not the line inside the helper. #flashcards

---
[[dashboard|🏠 Dashboard]] · [[glossary|📖 Glossary (archived)]] · [[learning-board|📋 Board]]
