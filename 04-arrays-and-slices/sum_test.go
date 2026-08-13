package main

import (
	"slices"
	"testing"
)

func TestSum(t *testing.T) {

	t.Run("Collection of Numbers", func(t *testing.T) {
		numbers := []int{1, 2, 3, 4, 5}
		got := Sum(numbers)
		want := 15
		if got != want {
			t.Errorf("got %d want %d given, %v", got, want, numbers)
		}
	})
	t.Run("Collection of any Size", func(t *testing.T) {
		numbers := []int{1, 2, 3}
		got := Sum(numbers)
		want := 6
		if got != want {
			t.Errorf("got %d want %d given, %v", got, want, numbers)
		}
	})

}

func TestSumAll(t *testing.T) {
	got := SumAll([]int{1, 2}, []int{0, 9})
	want := []int{3, 9}

	if !slices.Equal(got, want) {
		t.Errorf("got %v want %v", got, want)
	}
}

func TestSumAllTails(t *testing.T) {
	got := SumAllTails([]int{1, 2}, []int{0, 9})
	want := []int{2, 9}
	if !slices.Equal(got, want) {
		t.Errorf("got %v want %v", got, want)
	}

	t.Run("safely sum empty slice", func(t *testing.T) {
		got := SumAllTails([]int{}, []int{3, 4, 5})
		want := []int{0, 9}
		if !slices.Equal(got, want) {
			t.Errorf("got %v want %v", got, want)
		}
	})
}

func TestSumAllButFirstAndLast(t *testing.T) {
	got := SumAllButFirstAndLast([]int{1, 2, 3, 4})
	want := []int{5}
	if !slices.Equal(got, want) {
		t.Errorf("got %v want %v", got, want)
	}

	t.Run("nothing left after removing first and last", func(t *testing.T) {
		got := SumAllButFirstAndLast([]int{1, 2})
		want := []int{0}
		if !slices.Equal(got, want) {
			t.Errorf("got %v want %v", got, want)
		}
	})
	t.Run("same", func(t *testing.T) {
		got := SumAllButFirstAndLast([]int{5})
		want := []int{0}
		if !slices.Equal(got, want) {
			t.Errorf("got %v want %v", got, want)
		}
	})
}
