#!/usr/bin/env nu

print ($env | get -o REPOSITORY)
def main [] {
  $env.PATH = ($env.PATH | prepend `C:\Strawberry\perl\bin`)
  mkdir bin
  rclone copy drop:darwis/rust-build-bin bin -P
  mkdir repo
  $env.PATH = ($env.PATH | prepend (pwd | path join bin)) 
  let repo = $env.REPOSITORY
  git clone $repo repo
  print (ls repo)
  print (ls)
  print (git version)
  print (rclone listremotes)

  # build
  cd repo
  if ($repo == 'https://gitlab.com/shivjm/muhasib-e-hledger.git') {
    just tag-version patch
    rclone copy target/release $'drop:darwis/rust-build-nu/(date now | format date "%Y-%m-%d_%H-%M")'
  }
}