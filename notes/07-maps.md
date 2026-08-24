---
chapter: "07"
title: Maps
status: complete
date: 2026-08-21
tags: [go, chapter]
---

# Maps

> Status: ✅ COMPLETE — full CRUD (Search, Add, Update, Delete) implemented and all tests passing.

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
- Update/Delete reuse the same switch-err skeleton as Add: Search first, then act on the sentinel error
- Three sentinel errors for precise failures: ErrNotFound, ErrWordExists, ErrWordDoesNotExist (a dedicated error for "word missing" lets callers distinguish redirect vs error behaviour)
- delete(d, word) is Go's built-in map deletion; it's a no-op on missing keys, so Delete checks first and returns ErrWordDoesNotExist
- Value receivers work for map mutation (map holds a pointer to the hash table), BUT you cannot reassign the map itself through a value receiver — d = Dictionary{} only changes the local copy's pointer

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

```go
// Update refuses to add new words: mirror image of Add
func (d Dictionary) Update(word, definition string) error {
    _, err := d.Search(word)

    switch err {
    case ErrNotFound: // word missing -> refuse
        return ErrWordDoesNotExist
    case nil: // word found -> update it
        d[word] = definition
    default: // unexpected error -> pass it through
        return err
    }
    return nil
}
```

### Added on restart (2026-08-23) — the "why" layer
- Keys are ACTIVE (hashed, then compared with == to resolve collisions); values are INERT payloads — never hashed or compared. That asymmetry is why key types must be comparable and value types are unrestricted
- Zero value for missing keys is a deliberate Go design: lookup can't signal absence through the value, so it returns a well-defined default instead of panicking. Payoff: m[key]++ works on first touch. Cost: "" is ambiguous (missing vs stored-empty) — comma-ok exists to break that tie
- Existence checks must come from ok, NEVER by sniffing values (if d[word] == "" misreports a stored empty definition as missing)
- The default case in Add/Update/Delete is load-bearing: Search's signature accepts ANY error. If Search ever gains a new failure mode (e.g. file/DB backed), an unrecognized error would fall through both cases and hit `return nil` — reporting success while nothing happened. Only act on errors you recognize; never assume no-match means success
- Sentinel errors survive message rewording because comparison is by identity; errors.Is even survives wrapping

## Gotchas / mental model
- nil maps read fine but panic on write - always init with a literal or make
- A map write never errors: it silently overwrites. That's why Add checks first.
- Check err == nil BEFORE calling err.Error() - calling a method on nil panics
- The error you assert in a test must match the state of the data at that moment: deleting an existing word returns nil (success), deleting a missing word returns ErrWordDoesNotExist

## Tests
go test ./07-maps → ok (TestSearch, TestAdd, TestUpdate, TestDelete — all 8 subtests PASS)

## Self-test
- In the two-value map lookup v, ok := d[word], what does ok tell you?::Whether the key exists - true if found, false if missing (and v is the zero value when missing) #flashcards
- Why does Add call Search before writing to the map?::Map writes silently overwrite existing keys, so Add first checks and returns ErrWordExists instead of overwriting #flashcards
- What does a nil error value mean in Go?::No error occurred - the operation succeeded #flashcards
- Why does Update return ErrWordDoesNotExist instead of reusing ErrNotFound?::A dedicated error gives callers more information — e.g. a web app might redirect on ErrNotFound but show an error on ErrWordDoesNotExist, even though both mean "word missing" #flashcards
- Can you reassign a map through a value receiver?::No — d = Dictionary{} only changes the local copy's pointer; the caller's map is untouched. You can mutate inside the map, but not point it at a new map #flashcards
- Why does Go return the zero value for a missing map key instead of panicking?::A lookup can't signal absence through the value itself, so Go chose a well-defined default — safe for patterns like m[key]++ on first touch; the ambiguity is then resolved by comma-ok #flashcards
- What happens when you write to a nil map, and why?::Runtime panic "assignment to entry in nil map" — a nil map has no allocated hmap table to store the entry. Reads are safe (no table ≡ empty). Initialize with Dictionary{} or make() #flashcards

---
[[dashboard|🏠 Dashboard]] · [[glossary|📖 Glossary]] · [[learning-board|📋 Board]]
