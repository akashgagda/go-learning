---
chapter: "04"
title: Arrays and Slices
status: complete
date: 2026-08-15
tags: [go, chapter]
---

# Arrays and Slices

> Status: ✅ COMPLETE — slices, variadic parameters, and the accumulator pattern.

## Concepts learned
- Slices (`[]int`) are dynamic-length; arrays (`[5]int`) are fixed and rarely used directly.
- Variadic parameters (`...[]int`) accept zero or more slices; inside, they arrive as a `[][]int`.
- `append(slice, item)` grows a slice and returns the new slice — always assign its result.
- `numbers[1:]` slices from index 1 to the end (the "tail").
- `len(slice)` gives the length — check it before slicing to avoid panics.
- Compare slices in tests with `slices.Equal(got, want)`, not == (works only on arrays).
- TDD pattern: build each function on the previous one (`Sum` -> `SumAll` -> `SumAllTails`), testing each.

## Key snippet
```go
func SumAllTails(numbersToSum ...[]int) []int {
	var sums []int
	for _, numbers := range numbersToSum {
		if len(numbers) == 0 {
			sums = append(sums, 0)
		} else {
			sums = append(sums, Sum(numbers[1:]))
		}
	}
	return sums
}
```

## Gotchas / mental model
- The accumulator shape: `var out []int` + loop + `append` one result per input. `Sum`, `SumAll`, `SumAllTails` are the same shape — build each on the previous.
- Return type must match what you return: one slice in, one int out (`Sum -> int`); many slices in, many sums out (`SumAll -> []int`).
- `+=` already assigns: write `sum += n`, never `sum = sum += n`.
- `numbers[1:]` on an empty slice panics (`slice bounds out of range [1:0]`) — guard with `len(numbers) == 0`.

## Tests
`go test ./04-arrays-and-slices/...` → `ok example.com/go-learning/04-arrays-and-slices`

## Self-test
- What does `SumAllTails([]int{}, []int{3, 4, 5})` return?::`[0, 9]` — the empty slice contributes 0, and `Sum([4, 5])` contributes 9. #flashcards
- Why doesn't the empty slice panic in `SumAllTails`?::`len(numbers) == 0` is checked first, so `numbers[1:]` never runs on an empty slice — that would panic with `slice bounds out of range [1:0]`. #flashcards

---
[[dashboard|🏠 Dashboard]] · [[glossary|📖 Glossary]] · [[learning-board|📋 Board]]
