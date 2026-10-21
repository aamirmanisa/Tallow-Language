# install/

`install.sh` puts the compiler on this machine.

```sh
./install.sh --prefix ~/.local          # or: curl … | sh
./install.sh --from tallow-linux-aarch64-1.1.1.tar.gz
```

## What it installs, and why two files

| file | role |
|---|---|
| `tallow` | the compiler |
| `libtallow.a` | the runtime archive every compiled program links against |

They are installed into the same directory **always**. A compiler without its
runtime archive compiles programs that fail to link, and the failure appears
only when a program calls a runtime symbol — not when it starts. The installer
refuses an archive that lacks either file, then proves the pair by compiling a
program that needs a runtime symbol and running it.

## While no release exists

The script fetches `tallow-<os>-<arch>-<version>.tar.gz` plus its `.sha256`
from the engine repository's releases. Until a release is published it names the
asset, the URL and the platform, and exits **2** without installing anything. It
never installs bytes it could not fetch and verify.

## Building from source instead

```sh
git clone https://github.com/aamirmanisa/tallowsphere
cd tallowsphere
cargo build --profile release --bin tallow --lib
```

Both artifacts are needed: `--bin` produces the compiler, `--lib` produces
`libtallow.a`. Copy them together.

## Platforms

`linux-aarch64`, `linux-x86_64`, `macos-aarch64`, `macos-x86_64`, `windows`
(`.zip`, keep `tallow.exe` beside `tallow.lib`). Linux builds require glibc
2.39 or newer — the compiler links against symbols up to `GLIBC_2.39`.
