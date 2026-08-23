package main

import (
	"fmt"
	"io"
)

func main() {

}

func Greet(writer io.Writer, name string) {
	fmt.Fprintf(writer, "Hello, %s", name)
}
