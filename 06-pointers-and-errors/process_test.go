package main

import (
	"errors"
	"testing"
)

func TestProcessWithdrawal(t *testing.T) {
	wallet := Wallet{Bitcoin(10)}
	err := ProcessWithdrawal(&wallet, "acc-123", Bitcoin(100))

	if !errors.Is(err, ErrInsufficientFunds) {
		t.Errorf("expected error to wrap ErrInsufficientFunds, got %v", err)
	}

}
