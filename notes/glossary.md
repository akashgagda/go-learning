---
title: Go Vocabulary
status: done
date: 2026-08-15
tags: [go, glossary]
---

# Go Vocabulary (chapters 1-5)

All terms in Go-only terms, with examples from the course code.

| Term | Meaning | Example |
|---|---|---|
| **Function** | A named block of code with inputs and outputs. Called by name. | `Perimeter(rectangle)` |
| **Parameter** | The input slot declared in a function's signature. | `rectangle Rectangle` in `func Perimeter(rectangle Rectangle)` |
| **Argument** | The actual value you pass at the call site. | `Rectangle{10.0, 10.0}` passed to `Perimeter` |
| **Return value** | What the function hands back; declared after the params. | `float64` in `func Perimeter(...) float64` |
| **Receiver** | The type a method is attached to, written as `(name Type)` before the method name. Inside the method, `name` is the value it was called on. | `(c Circle)` in `func (c Circle) Area() float64` |
| **Method** | A function with a receiver — called *on a value*: `value.Method()`. | `circle.Area()` |
| **Field** | A named piece of data inside a struct, accessed with `.`. | `rectangle.Width` |
| **Struct** | A type that bundles named fields (data) together. | `type Rectangle struct { Width, Height float64 }` |
| **Interface** | A type that lists methods only — a contract, not data. | `type Shape interface { Area() float64 }` |
| **Concrete type** | A type with a real data layout — you can create values of it (`Rectangle`, `int`). The opposite of an interface, which has no data, only a method list. You store concrete values *in* interface slots. | `Rectangle` inside a `Shape`-typed table slot |
| **Implicit satisfaction** | A type automatically satisfies an interface once it has the listed methods; the compiler checks at each use site. | `Triangle` became a `Shape` the moment `Area` was added — no declaration |
| **Decoupling** | Code depends only on the interface's methods, never the concrete type — so it works for any type that fits. | The test table never cares *which* shape it gets |
| **Zero value** | Every variable starts at a default: `0` numbers, `""` strings, `nil` slices/pointers/interfaces. | `var sums []int` starts as `nil` |
| **Slice** | Dynamic-length sequence; built on a fixed array. `append` returns a new one — always assign it. | `append(sums, n)` |
| **Exported / unexported** | Capitalized names are visible outside the package; lowercase are private. | `Area` (exported) vs `balance` (private — chapter 06) |
| **Table-driven test** | One slice of anonymous structs = many cases, looped once. | `areaTests := []struct{...}{...}` with `for _, tt := range` |
| **`:=` vs `var`** | `:=` declares, infers type, and assigns; `var` declares (often leaving the zero value). | `got := tt.shape.Area()` vs `var sums []int` |

## Official references (pkg.go.dev)
- `testing.TB` — the interface common to `*testing.T`, `*testing.B`, and `*testing.F`; `Helper()` marks a helper so failure lines point at the caller. https://pkg.go.dev/testing#TB
- `slices.Equal` — the idiomatic way to compare two slices. https://pkg.go.dev/slices#Equal
- `strings.Builder` — growable string buffer (the chapter-03 benchmark win). https://pkg.go.dev/strings#Builder

## Mental anchors
- What is the difference between a receiver and a parameter?::A receiver is which type owns the behavior (`c Circle`); a parameter is what extra input the behavior needs. That's the whole difference between a method and a function. #flashcards
- What is the difference between an interface and a struct?::An interface lists what a value can do; a struct holds what a value contains. #flashcards
- What is the difference between a concrete type and an interface?::The concrete type is the real thing with real data; the interface is the job description it qualifies for. #flashcards
- Why write against an interface instead of a concrete type?::Because then new shapes/cases plug in with zero edits to your code — the code depends only on the interface's methods. #flashcards
