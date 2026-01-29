#!/usr/bin/env nu

print ($env | get -o REPOSITORY)
def main [] {
  mkdir bin
  rclone copy drop:darwis/rust-build-bin bin -P
  mkdir repo
  $env.PATH = ($env.PATH | prepend (pwd | path join bin)) 
  let repo = $env.REPOSITORY
  git clone $repo repo
  print (ls repo)
  print (ls)
}