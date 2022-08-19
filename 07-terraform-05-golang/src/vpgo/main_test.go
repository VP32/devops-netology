package main

import (
	"math/rand"
	"testing"
)

// Задача 4. Протестировать код (не обязательно).
// Тест для программы для перевода метров в футы
func TestMeterToFoot(t *testing.T) {
	meter := rand.Float64() * 100
	expected := meter / MeterToFootCoeff
	fact := MeterToFoot(meter)
	if expected != fact {
		t.Error("Expected ", expected, ", got ", fact)
	}
}

// Тест для программы, которая найдет наименьший элемент в любом заданном списке
func TestMinElement(t *testing.T) {
	x := []int{7, 999, 2, 1}
	expected := 1
	fact := MinElement(x)

	if expected != fact {
		t.Error("Expected ", expected, ", got ", fact)
	}
}

// Тест для программы, которая выводит числа от 1 до 100, которые делятся на 3.
func TestDiv3(t *testing.T) {
	expected := []int{3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72, 75, 78, 81, 84, 87, 90, 93, 96, 99}
	fact := Div3()

	if len(expected) != len(fact) {
		t.Error("Wrong result length")
	}

	for k, v := range fact {
		if v != expected[k] {
			t.Error("Expected ", expected[k], ", got ", v)
		}
	}
}
