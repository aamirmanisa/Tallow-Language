// The smallest program that exercises a loop, a branch and string building.
fn label(n: i64) -> String {
    if n % 15 == 0 { return "FizzBuzz" }
    if n % 3 == 0 { return "Fizz" }
    if n % 5 == 0 { return "Buzz" }
    return "{n}"
}

fn main() {
    var i = 1
    while i <= 15 {
        print(label(i))
        i += 1
    }
}
