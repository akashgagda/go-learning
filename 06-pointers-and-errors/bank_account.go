package main

import "errors"

var ErrInsufficientBalance = errors.New("no balance")

type BankAccount struct {
	balance Bitcoin
}

func (b BankAccount) Balance() Bitcoin {
	return b.balance
}

func (b *BankAccount) Deposit(amount Bitcoin) {
	b.balance += amount
}

func (b *BankAccount) Withdraw(amount Bitcoin) error {
	if amount > b.balance {
		return ErrInsufficientBalance
	}
	b.balance -= amount
	return nil
}

func (b *BankAccount) Transfer(amount Bitcoin, to *BankAccount) error {
	if amount > b.balance {
		return ErrInsufficientBalance
	}
	b.balance -= amount
	to.balance += amount
	return nil
}
