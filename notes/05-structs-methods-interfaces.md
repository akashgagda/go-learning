# Structs, Methods & Interfaces

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

## Tests
`go test ./05-structs-methods-interfaces/...` → `ok example.com/go-learning/05-structs-methods-interfaces`

## Self-test
Why did `checkArea(t, 42, 72.0)` refuse to compile, and what does that prove about how interfaces work?
