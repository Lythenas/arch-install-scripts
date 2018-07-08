#!/usr/bin/env sh

set -e

echo "==== Installing rust via rustup"
curl https://sh.rustup.rs -sSf | sh

echo "==== Adding cargo env to .zshrc"
echo "source \$HOME/.cargo/env" >> $HOME/.zshrc

source $HOME/.cargo/env

echo ==== Installing nightly toolchain""
rustup toolchain install nightly
rustup default nightly

echo "==== Finished installing Rust\n"
echo "==== Now installing Cargo plugins"

cargo install clippy
rustup component add rustfmt-preview --toolchain nightly

echo "==== Done installing Cargo plugins"
