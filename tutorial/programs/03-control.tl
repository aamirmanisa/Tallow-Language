fn main() {
    var total = 0
    for n in [1, 2, 3, 4, 5] {
        if n == 3 { continue }
        total += n
    }
    print(total)

    var countdown = 3
    while countdown > 0 {
        print(countdown)
        countdown -= 1
    }
}
