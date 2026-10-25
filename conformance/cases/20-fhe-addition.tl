// Fully homomorphic addition (--features fhe): the plaintexts never leave the
// ciphertexts, and the sum is modular over 8 bits.
fn main() {
    let s = crypto.fhe_keygen()
    let a = crypto.fhe_encrypt(s.handle, 3)
    let b = crypto.fhe_encrypt(s.handle, 4)
    print(crypto.fhe_decrypt(s.handle, crypto.fhe_add(s.handle, a, b)))
}
