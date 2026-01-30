#!/usr/bin/env nu

print ($env | get -o REPOSITORY)
def main [] {
  $env.PATH = ($env.PATH | prepend `C:\Strawberry\perl\bin`)
  # build
  cd repo
  let repo = $env.REPOSITORY
  match $repo { 
    'https://gitlab.com/shivjm/muhasib-e-hledger.git' => {
      cargo build --release --target x86_64-pc-windows-msvc
      rclone copy target $'drop:darwis/rust-build-nu/e-hledger-(date now | format date "%Y-%m-%d_%H-%M")' --include '*.exe' --include '*.dll'
    },
    _ => {
      cargo build --release --target x86_64-pc-windows-msvc
      rclone copy target $'drop:darwis/rust-build-nu/repo-(date now | format date "%Y-%m-%d_%H-%M")' --include '*.exe' --include '*.dll'
    } 
  }
  http post -t application/json $'https://api.telegram.org/bot$($env.TELEGRAM_TOKEN)/sendMessage' {chat_id: $env.TELEGRAM_TO, text: $'Build complete for ($repo)'}
}