---
chapter: "<% tp.file.title.split("-")[0] %>"
title: <% tp.file.title.replace(/^\d+-/, "").replace(/-/g, " ").replace(/\b\w/g, c => c.toUpperCase()) %>
status: todo
tags: [go, chapter]
date: "<% tp.date.now('YYYY-MM-DD') %>"
---

# <% tp.file.title.replace(/^\d+-/, "").replace(/-/g, " ").replace(/\b\w/g, c => c.toUpperCase()) %>

<!-- Name this file like the chapter folder (e.g. 09-mocking.md) so the test
     command below resolves to the right folder. Fill the sections as you go. -->

> Status: ⏳ TODO — not started yet. Work through the TDD checklist below.

## Concepts learned
- 

## Key snippet
```go

```

## Gotchas / mental model
- 

## TDD checklist
- [ ] #task Write the failing test
- [ ] #task Make it pass (minimal code)
- [ ] #task Refactor, re-run tests and benchmark
- [ ] #task Update this note with what you learned

## Tests
`go test ./<% tp.file.title %>/...` → 

## Self-test
<!-- One card per idea. Format: Question::Answer  #flashcards -->
- What is the key idea from this chapter?::Answer in your own words #flashcards
