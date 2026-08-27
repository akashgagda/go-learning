---
chapter: "05"
title: Structs, Methods & Interfaces
status: complete
date: 2026-08-15
tags: [go, chapter]
---

# Structs, Methods & Interfaces

> Status: ✅ COMPLETE — structs, methods, interfaces, and the table-driven test pattern.

## Concepts learned
- `struct` bundles data into one named type: `type Rectangle struct { Width, Height float64 }`. Fields accessed with `.` (exported fields are capitalized).
- A method is a function with a receiver: `func (r Rectangle) Area() float64` — called as `rectangle.Area()`. Receiver name convention: first letter of the type.
- An interface declares a behavior contract, not data: `type Shape interface { Area() float64 }`.
- Implicit satisfaction: no `implements` keyword — a type satisfies an interface automatically if it has the required methods. The compiler checks at every call site.
- `float64` return type comes after the params; `%g` prints floats at useful precision, `%.2f` rounds to 2 decimals.
- Test helper with `t.Helper()` so failures point at the caller; parameter `testing.TB` works for both tests and benchmarks.

## Key snippet
```go
type Shape interface {
	Area() float64
}

func (r Rectangle) Area() float64 {
	return r.Width * r.Height
}

func (c Circle) Area() float64 {
	return math.Pi * c.Radius * c.Radius
}
```

## Gotchas / mental model
- Mental model: a struct says what a value *contains*; an interface says what a value *can do*. An interface is a shopping list of methods — a type matches if it has them, no paperwork.
- Two ways to trip: declaring `Area(rectangle Rectangle)` as a plain function blocks adding `Area(circle Circle)` (no redeclaration allowed — use methods instead); and "return type must match what you actually return" (`float64`, not the struct).

## Table-driven tests (reusable pattern)
- The reusable pattern: a slice of anonymous structs where each row is one case (input + expected output), looped with `for _, tt := range areaTests`. Adding a case = adding a row.
- Reach for it whenever the same assertion repeats with different inputs — you'll meet it again in Maps, Mocking, Reflection, and HTTP route tests in later chapters.
- Named fields + a `name` field make rows read like facts; wrapping each case in `t.Run(tt.name, ...)` names failures and allows `go test -run TestArea/triangle` to run one case.
- `%#v` in error messages prints the whole struct (`main.Rectangle{Width:12, Height:6}`), so a failing row is obvious without hunting.
- Worked example (Triangle, full TDD cycle): add the row → `undefined: Triangle` → define struct → `does not implement Shape (missing method Area)` → stub `return 0` → `got 0 want 36` → implement `(t.Base * t.Height) * 0.5`.
- Lesson learned: a blanket rename (`want` → `hasArea`) leaked into `TestPerimeter` and its format string. Refactors should touch only what they must.

```go
areaTests := []struct {
	name    string
	shape   Shape
	hasArea float64
}{
	{name: "rectangle", shape: Rectangle{Width: 12, Height: 6}, hasArea: 72.0},
	{name: "circle", shape: Circle{Radius: 10}, hasArea: 314.1592653589793},
	{name: "triangle", shape: Triangle{Base: 12, Height: 6}, hasArea: 36.0},
}
for _, tt := range areaTests {
	t.Run(tt.name, func(t *testing.T) {
		got := tt.shape.Area()
		if got != tt.hasArea {
			t.Errorf("%#v got %g want %g", tt.shape, got, tt.hasArea)
		}
	})
}
```

## Tests
`go test ./05-structs-methods-interfaces/...` → `ok example.com/go-learning/05-structs-methods-interfaces`

## Self-test
- Why did `checkArea(t, 42, 72.0)` refuse to compile?::`42` is an `int`, which has no `Area()` method, so it doesn't satisfy the `Shape` interface parameter. #flashcards
- What does that prove about how interfaces work?::Satisfaction is checked at compile time at every call site — a type is a `Shape` only if it has the required methods; the compiler, not the runtime, enforces it. #flashcards

---
[[dashboard|🏠 Dashboard]] · [[glossary|📖 Glossary (archived)]] · [[learning-board|📋 Board]]
