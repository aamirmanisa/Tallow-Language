#!/usr/bin/env tallow
// todo.tl — every TODO / FIXME / XXX in a file, with its line number.
//
//   $ ./todo.tl src/main.rs
//   src/main.rs:118: // TODO: hoist the retry policy
//
// Exit 1 when something is found, 0 when the file is clean — a script whose
// exit code is useful in a pre-commit hook, not just readable output.

fn find_in(line: String, marker: String) -> bool {
    // No `contains` on strings in this language: a split that yields more than
    // one piece is the test.
    return line.split(marker).len() > 1
}

fn main() {
    let args = env.args()
    if args.len() < 1 {
        print("usage: todo.tl <file>")
        return
    }
    let path = args[0]
    let text = fs.read_file(path)
    let lines = text.split("\n")
    var found: i64 = 0
    for i in 0..lines.len() {
        let line = lines[i]
        if find_in(line, "TODO") || find_in(line, "FIXME") || find_in(line, "XXX") {
            print(path + ":" + (i + 1).to_string() + ": " + line)
            found = found + 1
        }
    }
    if found > 0 {
        process.exit(1)
    }
}
