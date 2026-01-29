#!/usr/bin/env nu

print ($env | get -o REPOSITORY)
def main [] {
  $env.PATH = ($env.PATH | prepend `C:\Strawberry\perl\bin`)
  mkdir bin
  mkdir repo
  $env.PATH = ($env.PATH | prepend (pwd | path join bin)) 
  let repo = $env.REPOSITORY
  git clone $repo repo
  print (ls repo)
  print (ls)
  print (git version)
  print (rclone listremotes)
}