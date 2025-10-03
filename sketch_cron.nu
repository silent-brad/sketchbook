#!/usr/bin/env nu

# Sketch Cron

def init-sketches [] {
  ls *.kra | get name | each { |img|
    unzip -d .tmp $img
    cp -f .tmp/preview.png $".imgs/($img | path parse | get stem).png"
    rm -rf .tmp/*
  }
  sync-sketchbook
}

def sync-sketchbook [] {
  let user = open .config.toml | get user
  let host = open .config.toml | get host
  let path_to_remote = open .config.toml | get path_to_remote
  let remote_dir = "$user@$host:$path_to_remote"
  rsync -avz --progress .imgs/ "$remote_dir/"
  rsync -vz --progress sketchbook.log "$remote_dir/"
}

def watch-sketchbook [] {
  watch . --glob=**/*.kra { |op, path, new_path|
    let current_date = date now | format date "%Y-%m-%d %H:%M:%S"
    $"($op) ($path) ($new_path) ($current_date)\n" | save --append sketchbook.log
    match $op {
      Create => {
        unzip -d .tmp $path
        cp -f .tmp/preview.png $".imgs/($path | path parse | get stem).png"
        rm -rf .tmp/*
      }
      Remove => {
        rm $".imgs/($path | path parse | get stem).png"
      }
      Rename => {
        rm $".imgs/($path | path parse | get stem).png"
        unzip -d .tmp $new_path
        cp -f .tmp/preview.png $".imgs/($new_path | path parse | get stem).png"
        rm -rf .tmp/*
      }
    }
    sync-sketchbook
  }
}

# TODO: Add a CLI
# Example: `./sketchbook.nu init`, `./sketchbook.nu watch`

#init-sketches
#watch-sketchbook
