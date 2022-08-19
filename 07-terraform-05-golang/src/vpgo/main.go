package main

import (
	"fmt"
)

const FootToMeterCoeff float64 = 0.3048

func main() {
	// 3.1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр).
	fmt.Print("Введите метры: ")
	var input float64
	fmt.Scanf("%f", &input)
	fmt.Printf("Метры в футы: %f\n", MeterToFoot(input))

	// 3.2. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
	// x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17, 4, 8, 15, 23, 42}
	fmt.Printf("Минимальный элемент: %d\n", MinElement(x))

	// 3.3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть (3, 6, 9, …).
	fmt.Printf("Числа, которые делятся на 3: %v\n", Div3())
}

// 3.1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр).
func MeterToFoot(input float64) float64 {
	output := input / FootToMeterCoeff
	return output
}

// 3.2. Напишите программу, которая найдет наименьший элемент в любом заданном списке
func MinElement(list []int) int {
	min := list[0]
	for _, elem := range list {
		if elem < min {
			min = elem
		}
	}

	return min
}

// 3.3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть (3, 6, 9, …).
func Div3() []int {
	result := []int{}
	for i := 1; i <= 100; i++ {
		if i%3 == 0 {
			result = append(result, i)
		}
	}

	return result
}
