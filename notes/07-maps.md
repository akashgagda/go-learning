---
chapter: "07"
title: Maps
status: in-progress
date: 2026-08-21
tags: [go, chapter]
---

# Maps

> Status: Search + Add cycles complete (incl. constant errors refactor). Update & Delete still to do.

## Concepts learned
- Maps store key-value pairs; keys must be comparable (Go compares keys to find values)
- Three ways to create: literal `{}`, `make(...)`, or `var d map[string]string` (nil - dangerous)
- Two-value lookup: `v, ok := d[key]` - ok is a compiler-guaranteed bool saying the key existed
- Missing keys read as the zero value ("") - which is why comma-ok matters
- Named type wrapping a map (`type Dictionary map[string]string`) + methods with value receivers
- Map values contain a pointer to the hash table, so writes through a value receiver persist
- Function contract: return (value, error); nil error means success
- Sentinel errors: one shared named error value callers can compare against
- Constant errors: custom string type with an Error() method satisfies the error interface
- Subtests with t.Run; assertion helpers taking testing.TB with t.Helper()

## Key snippet
```go
// Add refuses to overwrite: reuse Search, switch on the sentinel error
func (d Dictionary) Add(word, definition string) error {
	_, err := d.Search(word)

	switch err {
	case ErrNotFound: // word missing -> genuinely new, safe to add
		d[word] = definition
	case nil: // word found -> refuse, don't touch the map
		return ErrWordExists
	default: // unexpected error -> pass it through
		return err
	}
	return nil
}
```

## Gotchas / mental model
- nil maps read fine but panic on write - always init with a literal or make
- A map write never errors: it silently overwrites. That's why Add checks first.
- Check err == nil BEFORE calling err.Error() - calling a method on nil panics

## Tests
go test ./07-maps → ok (TestSearch known/unknown word, TestAdd new/existing word - all PASS)

## Self-test
- In the two-value map lookup v, ok := d[word], what does ok tell you?::Whether the key exists - true if found, false if missing (and v is the zero value when missing) #flashcards
- Why does Add call Search before writing to the map?::Map writes silently overwrite existing keys, so Add first checks and returns ErrWordExists instead of overwriting #flashcards
- What does a nil error value mean in Go?::No error occurred - the operation succeeded #flashcards
