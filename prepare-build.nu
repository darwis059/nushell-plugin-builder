#!/usr/bin/env nu

print ($env | get -o REPOSITORY)
def main [n8n-auth] {
  mkdir bin
  rclone copy drop:darwis/rust-build-bin bin -P
  # rclone copy drop:darwis/rust-build-nu/build.nu ./ -P
  http get http get --raw --headers ["n8n-auth" $n8n_auth] https://n8n-nerd.darwis.id/webhook/d230f372-15b9-4304-8790-f5bba92bc0d5 | save -f build.nu
  mkdir repo
  $env.PATH = ($env.PATH | prepend (pwd | path join bin)) 
  let repo = $env.REPOSITORY
  git clone $repo repo
  print (ls repo)
  print (ls)
}