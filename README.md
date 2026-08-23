# Go Learning

Working through [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests/).

## Layout

Single module with one package per chapter. Run all tests from the root:

```bash
go test ./...
```

Run tests for one chapter:

```bash
go test ./01-hello-world/...
```

## Chapters

- `01-hello-world` - first program, testing basics
- `02-integers` - integers, table-driven tests
- `03-iteration` - loops, benchmarks
- `04-arrays-and-slices` - slices, collection functions
- `05-structs-methods-interfaces` - structs, methods, interfaces
- `06-pointers-and-errors` - pointers, error handling
- `07-maps` - maps, sentinel errors, subtests
- `08-dependency-injection` - dependency injection (current)
