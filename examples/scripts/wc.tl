#!/usr/bin/env tallow
// wc.tl — lines, words and bytes of a file.
//
// A real script, not a snippet: it takes a path on the command line, reads the
// file, and prints the three counts on one line. Run it directly (./wc.tl FILE)
// or through the engine (tallow run wc.tl FILE).
//
//   $ ./wc.tl notes.txt
//   42 318 1841 notes.txt

fn count_words(text: String) -> i64 {
    // Words are separated by spaces or newlines; an empty piece is not a word,
    // which is what makes "a  b" count as two and a trailing newline as zero.
    var n: i64 = 0
    for line in text.split("\n") {
        for part in line.split(" ") {
            if part != "" {
                n = n + 1
            }
        }
    }
    return n
}

fn main() {
    let args = env.args()
    // env.args() carries the program's own arguments, not the script path.
    if args.len() < 1 {
        print("usage: wc.tl <file>")
        return
    }
    let path = args[0]
    let text = fs.read_file(path)
    let lines = text.split("\n")
    // A trailing newline splits into a final empty element; that is not a line.
    var line_count: i64 = lines.len()
    if line_count > 0 && lines[line_count - 1] == "" {
        line_count = line_count - 1
    }
    print(line_count.to_string() + " " + count_words(text).to_string() + " " + text.len().to_string() + " " + path)
}
