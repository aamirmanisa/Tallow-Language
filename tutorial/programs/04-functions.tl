fn factorial(n: i64) -> i64 {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}

fn sign_word(n: i64) -> String {
    if n < 0 { return "negative" }
    if n == 0 { return "zero" }
    return "positive"
}

fn main() {
    print(factorial(6))
    print(sign_word(-4))
    print(sign_word(0))
}
