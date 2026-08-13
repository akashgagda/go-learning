# Integers

## Concepts learned
- Non-`main` package: `package integers` — one package per directory, so each chapter gets its own folder.
- `%d` verb formats integers (vs `%q` for strings); format arguments fill placeholders left to right, so argument order must match.
- `(x, y int)` shorthand when parameters share a type.
- Hardcoding `return 4` passes one test but fails the next input — write the real logic.
- Doc comments start with the function name (`// Add takes two integers...`) and show up in `go doc` and editor tooltips.
- Testable Examples: `ExampleAdd` in `_test.go` is compiled with the suite; with an `// Output:` comment it is executed and the output asserted — examples can't rot silently.

## Key snippet
```go
func ExampleAdd() {
	sum := Add(1, 5)
	fmt.Println(sum)
	// Output: 6
}
```

## Gotchas / mental model
- `t.Errorf("expected '%d' but got '%d'", sum, expected)` prints the words swapped from the values — always pass `expected` before `got` to match the message.
- Mental model: an example function without an `// Output:` comment is only compiled, never run; with it, the test harness asserts printed output against the comment.

## Tests
`go test ./02-integers/...` → ok (TestAdder and ExampleAdd both pass)

## Self-test
What makes an example function "testable" — and what changes if you remove the `// Output: 6` comment?
