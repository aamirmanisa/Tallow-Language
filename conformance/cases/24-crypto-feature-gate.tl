// A build with the default feature set has no ZK surface. Both planes must say
// so and name the feature — the spec documents these calls, so a reader needs a
// diagnostic that points at the build, not at their program.
fn main() {
    let p = crypto.zk_range_prove(1, 8, "00")
    print(p.proof)
}
