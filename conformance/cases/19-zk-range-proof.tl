// Range proofs (--features zk). The blinding is fixed so the proof is
// reproducible; a verifier that accepts the honest proof is the contract.
fn main() {
    let p = crypto.zk_range_prove(42, 16, "0f1e2d3c4b5a69788796a5b4c3d2e1f00f1e2d3c4b5a69788796a5b4c3d2e1f0")
    print(crypto.zk_range_verify(p.proof, p.commitment, 16))
}
