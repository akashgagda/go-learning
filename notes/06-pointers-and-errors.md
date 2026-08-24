---
chapter: "06"
title: Pointers and Errors
status: complete
date: 2026-08-16
tags: [go, chapter]
---

# Pointers and Errors

> Status: ✅ COMPLETE — pointers, error values, sentinels, and the wallet/transfer exercises.

## Concepts learned
- Go **copies values** when calling functions/methods. A value receiver (`func (w Wallet)`) mutates a private copy; a **pointer receiver** (`func (w *Wallet)`) gets the address and mutates the original. Keep receiver types consistent.
- Struct pointers auto-dereference: `w.balance` already means `(*w).balance`.
- Errors are the idiomatic failure signal: a function returns `error`, `nil` means success, and callers must check it (linters like `errcheck` flag ignored errors).
- Errors are values: a package-level **sentinel** `var ErrInsufficientFunds = errors.New(...)` is a single source of truth — test and code reference the same value, so messages can't drift apart (or get typo'd independently).
- `type Bitcoin int` creates a new type from an existing one; the compiler then refuses to mix `Bitcoin` and `int`. Methods can be declared on any type you define.
- `Stringer` (`String() string`) is used by `fmt` for `%s` — so failures read `got 10 BTC want 20 BTC` instead of raw numbers.
- Test helper staples: `assertBalance`, `assertError`, `assertNoError`, with `testing.TB` and `t.Helper()`; `t.Fatal` stops a test before dereferencing a nil error.

## Key snippet
```go
func (w *Wallet) Withdraw(amount Bitcoin) error {
	if amount > w.balance {
		return ErrInsufficientFunds
	}
	w.balance -= amount
	return nil
}
```

## Gotchas / mental model
- Mental model: value receiver = "work on my photocopy"; pointer receiver = "work on the original, changes stick". Reach for a pointer whenever a method must mutate state.
- The format verb decides rendering: `%s` triggers `String()`, `%d` prints the raw number — mixing them produced `got 20 BTC want 10`.
- Compiler enforces the contract from both sides: a function that returns nothing can't `return nil` ("too many return values"), and a caller that assigns a value needs the signature to declare it ("no value used as value").
- A method that calls itself (`return w.Balance()` inside `Balance()`) is infinite recursion — read the field, not the method.

## Tests
`go test ./06-pointers-and-errors/...` → `ok example.com/go-learning/06-pointers-and-errors`

## Practice session (rebuild + Transfer)
- Pointer **parameters** are the same `*` idea as pointer receivers: `func (b *BankAccount) Transfer(amount Bitcoin, to *BankAccount)` holds two addresses and mutates both. Difference: the receiver gets its `&` written automatically by method-call syntax; a pointer parameter needs `&friend` written by hand at the call site, or the compiler rejects it (type mismatch).
- A transfer has **two effects** (debit sender, credit friend). A test that asserts only one effect is green while the feature silently destroys money — assert every effect. This is the "blind spot" lesson.
- `t.Error` does NOT format; `t.Errorf` does. `go vet` (runs with `go test`) flags `t.Error` with format directives.
- Package scope is one namespace: no two top-level declarations (functions, `var` sentinels) may share a name — `ErrInsufficientFunds` redeclared in a second file is a compile error.
- Statements vs expressions: `b.balance += amount` is a statement (does something, produces nothing) — `return b.balance += amount` is invalid.
- When a test fails with a wrong expectation, read it before fixing: `got 20 want 100` meant the *test* wanted the balance to change on a rejected withdrawal; the code was right.
- Top-level test functions take `*testing.T`; `testing.TB` is the interface for helper parameters.

## Self-test
- Why did `Deposit` with a value receiver leave the balance at 0 even though the code looked right?::Go copies values on method calls, so `Deposit` mutated a copy of the wallet. A `*Wallet` pointer receiver mutates the original. #flashcards
- What does `var ErrInsufficientFunds` buy you compared with comparing error message strings?::One source of truth shared by test and code — messages can't drift or get typo'd independently, and callers can compare errors directly with == . #flashcards
<!--SR:!2026-08-16,0,230-->
- When do you need `t.Fatal` instead of `t.Errorf` in a helper?::When continuing the test would dereference a nil value (e.g. `got.Error()` on a nil error) — `t.Fatal` stops the test immediately. #flashcards
- How do you make a domain value print as "10 BTC" instead of "10"?::Implement `String() string` on the type; `fmt` uses it for the `%s` verb. #flashcards
- What's the difference between a pointer receiver and a pointer parameter?::Both pass addresses; the method-call syntax writes the `&` for the receiver automatically, but a pointer parameter requires you to write `&` explicitly at the call site. #flashcards
- How can all tests pass while a `Transfer` feature is broken?::If the tests only assert the sender's balance, the friend's side is a blind spot — a transfer has two effects and both must be asserted. #flashcards
<!--SR:!2026-08-16,0,230-->

## Bonus: error wrapping
- Layers want to add context without losing the cause: `return fmt.Errorf("processing withdrawal for account %s: %w", accountID, err)`.
- `%w` vs `%v`: both substitute the message text, but `%v` copies it into a brand-new unrelated error (message right, chain broken — `errors.Is` returns false), while `%w` keeps a link to the original (wrapper). Message and chain are separate things.
- `errors.Is(err, ErrInsufficientFunds)` walks the unwrap chain until it finds a match — the safe default for checking errors that may have passed through layers. == only works for the exact same value.
- Idiom: `if err := wallet.Withdraw(amount); err != nil { ... }` — declare and check the error in one line; `err` scoped to the block.
- `err` is just the conventional variable name for the error report: `nil` = "all good", non-nil = "something failed".
- Sibling: `errors.As` extracts typed errors from a chain (covered in the error-types chapter).
- Why does `errors.Is(err, ErrInsufficientFunds)` return false when the error was built with `%v` instead of `%w`?::`%v` copies the message into a brand-new, unrelated error value — the chain is broken and there's nothing to unwrap. `%w` keeps a link to the original error, so `errors.Is` can walk the chain and find the match. #flashcards

---
[[dashboard|🏠 Dashboard]] · [[glossary|📖 Glossary]] · [[learning-board|📋 Board]]