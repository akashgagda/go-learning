package main

import "testing"

func TestBankAccount(t *testing.T) {
	account := BankAccount{}
	account.Deposit(Bitcoin(10))
	got := account.Balance()
	want := Bitcoin(10)

	if got != want {
		t.Errorf("got %s want %s", got, want)
	}
}
func TestWithdraw(t *testing.T) {
	t.Run("Happy Path", func(t *testing.T) {
		account := BankAccount{20}
		err := account.Withdraw(Bitcoin(10))
		assertNoError(t, err)
		got := account.Balance()
		want := Bitcoin(10)
		if got != want {
			t.Errorf("got %s want %s", got, want)
		}
	})
	t.Run("No Balance in Account", func(t *testing.T) {
		account := BankAccount{20}
		err := account.Withdraw(Bitcoin(100))
		assertError(t, err, ErrInsufficientBalance)
		got := account.Balance()
		want := Bitcoin(20)
		if got != want {
			t.Fatalf("got %s want %s", got, want)
		}
	})
}

func TestTransfer(t *testing.T) {
	t.Run("Happy Transfer", func(t *testing.T) {
		sender := BankAccount{20}
		friend := BankAccount{}
		err := sender.Transfer(Bitcoin(10), &friend)
		assertNoError(t, err)
		got := friend.Balance()
		want := Bitcoin(10)
		if got != want {
			t.Errorf("friend got %s want %s", got, want)
		}
	})
	t.Run("insufficient-funds", func(t *testing.T) {
		sender := BankAccount{20}
		friend := BankAccount{}
		err := sender.Transfer(Bitcoin(100), &friend)
		assertError(t, err, ErrInsufficientBalance)
		got := sender.Balance()
		want := Bitcoin(20)
		if got != want {
			t.Fatalf("sender got %s want %s", got, want)
		}
	})

}
