fn parse_positive(n: i64) -> Result<i64> {
    if n <= 0 {
        bail "not positive"
    }
    Ok(n)
}

fn main() {
    print(parse_positive(5))
    print(parse_positive(0))

    let doubled = parse_positive(21) match {
        Ok(x) -> x * 2
        Err(e) -> 0
    }
    print(doubled)
}
