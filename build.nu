#!/usr/bin/env nu

print ($env | get -o REPOSITORY)
def main [] {
  $env.PATH = ($env.PATH | prepend `C:\Strawberry\perl\bin`)
  # build
  cd repo
  if ($repo == 'https://gitlab.com/shivjm/muhasib-e-hledger.git') {
    # cargo install cargo-release
    # just tag-version patch
    cargo build --release --target x86_64-pc-windows-msvc
    rclone copy target $'drop:darwis/rust-build-nu/e-hledger/(date now | format date "%Y-%m-%d_%H-%M")' --include '*.exe'
  }
}