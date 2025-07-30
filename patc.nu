#!/usr/bin/env nu

print ($env | get -i REPOSITORY)
def main [repository: string plugin_ver: string do_patch: bool] {
    # let plugin_ver = $env.PLUGIN_VER
    let src = $env.GITHUB_WORKSPACE

    print 'do file patch'

    cd $src
    ls

    if $do_patch == true {
        #     sed -i 's/nu-protocol.*/nu-protocol = \{ version = \"${{ github.event.inputs.nu_plugin_ver }}\", features = \[\"plugin\"\] \}/' Cargo.toml
        #     sed -i 's/nu-plugin.*/nu-plugin = \"${{ github.event.inputs.nu_plugin_ver }}\"/' Cargo.toml
        #     sed -i 's/nuon.*/nuon = \"${{ github.event.inputs.nu_plugin_ver }}\"/' Cargo.toml
        #     sed -i 's/nu-path.*/nu-path = \"${{ github.event.inputs.nu_plugin_ver }}\"/' Cargo.toml
        open Cargo.toml | 
            update dependencies.nu-plugin $plugin_ver | 
            update dependencies.nu-protocol { version: $plugin_ver features: ['plugin'] } | 
            if 'nuon' in ($in | get dependencies) { $in | update dependencies.nuon $plugin_ver } else { $in } | 
            if 'nu-path' in ($in | get dependencies) { $in | update dependencies.nu-path $plugin_ver } else { $in } | 
            if 'nu-plugin-test-support' in ($in | get -i dev-dependencies | default {}) { $in | update dev-dependencies.nu-plugin-test-support $plugin_ver } else { $in } | 
            if 'nu-cmd-base' in ($in | get dependencies) { $in | update dependencies.nu-cmd-base $plugin_ver } else { $in } | 
            save -f Cargo.toml
        # open Cargo.toml | print
        # update package.edition '2024' |
    }

    # if $repository in ['fdncred/nu_plugin_md' 'fdncred/nu_plugin_emoji' 'fdncred/nu_plugin_file' 'fdncred/nu_plugin_regex' 'fdncred/nu_plugin_bg' 'fdncred/nu_plugin_pnet' 'fdncred/nu_plugin_jwalk' 'fdncred/nu_plugin_json_path'] {
    #     patch-desc src/main.rs
    # }

    # if $repository == 'fdncred/nu_plugin_dt' {
    #     patch-desc src/commands/add.rs
    #     patch-desc src/commands/diff.rs
    #     patch-desc src/commands/dt.rs
    #     patch-desc src/commands/now.rs
    #     patch-desc src/commands/part.rs
    #     patch-desc src/commands/utcnow.rs
    # }

    if $repository == 'FMotalleb/nu_plugin_qr_maker' {
        # patch version
        let insert = [
            'fn version(&self) -> String {'
            '    env!("CARGO_PKG_VERSION").into()'
            '}'
            'fn commands(&self)'
        ]
        let src = open src/main.rs
        if ($src | find CARGO_PKG_VERSION | is-empty) {
            $src | str replace 'fn commands(&self)' ($insert | str join (char nl)) | save -f src/main.rs
        }
    }

    if $repository in ['devyn/nu_plugin_explore_ir' 'amtoine/nu_plugin_explore'] {
        open src/main.rs | str replace --all 'usage(&self)' 'description(&self)' | save -f src/main.rs
    }

    if $repository == 'FMotalleb/nu_plugin_qr_maker' {
        open src/to_qr.rs | str replace --all 'usage(&self)' 'description(&self)' | save -f src/to_qr.rs
    }

    if $repository == 'JosephTLyons/nu_plugin_units' {
        open src/nu/mod.rs | str replace --all 'usage(&self)' 'description(&self)' | save -f src/nu/mod.rs
        open src/nu/mod.rs | str replace --all 'as_f64' 'as_float' | save -f src/nu/mod.rs
    }

    if $repository == 'FMotalleb/nu_plugin_audio_hook' {
        open src/sound_make.rs | str replace --all 'as_f64' 'as_float' | save -f src/sound_make.rs
    }

    if $repository == 'Com6235/nu-plugin-http-server' {
        nu toolbox.nu
    }
}

def patch-desc [file] {
     open $file | str replace --all 'fn description(&self)' 'fn usage(&self)' | save -f $file
}

def patch-file [file: string old:string new: string] {
    let src = open $file
    if ($src | find $new | is-empty) {
        $src | str replace --all $old $new | save -f $file
    }
}
