using Printf

@fastmath function main()
    number = zero(Float64)  # Виділення пам'яті для змінної.

    while true
        try
            print("Введіть число: ")
            number = parse(Float64, readline())  # Отримуємо ввід користувача.
            break  # Закінчуємо цикл, якщо немає помилок.
        catch e
            println("Помилка: $e")
        end
    end

    if number < 0
        println("Квадратний корінь з від'ємного числа не є дійсним числом.")
    else
        @inbounds @printf("Квадратний корінь з %.2f = %.2f\n", number, @fastmath sqrt(number))
    end
end

main()
