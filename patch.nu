#!/usr/bin/env nu

print ($env | get -o REPOSITORY)
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
            if 'nu-plugin-test-support' in ($in | get -o dev-dependencies | default {}) { $in | update dev-dependencies.nu-plugin-test-support $plugin_ver } else { $in } | 
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

    if $repository == 'fdncred/nu_plugin_bg' {
        let codes = open src/main.rs | lines
        if (($codes | slice 109..112 | str join '' | str replace --regex --all '\s*' '') == 'Ok(Value::Int{val:process.id()asi64,internal_span:value_span,})') {
            $codes | update 110 '' | update 111 '' | update 112 '' | update 109 '        Ok(Value::int(process.id() as i64, value_span))' | str join (char nl) | save -f src/main.rs
            # $codes | update 110 'val: UntaggedValue::Primitive(Primitive::Int(process.id() as i64)),' | str join (char nl) | save -f src/main.rs
        }
    }
    if $repository == 'FMotalleb/nu_plugin_image' {
        # open Cargo.toml | upsert patch.crates-io { windows-sys: '0.61.2' } | save -f Cargo.toml
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
        # open Cargo.toml | 
        #     upsert dependencies.crossterm '0.28.1' | 
        #     upsert dependencies.ab_glyph '0.2.31' | 
        #     upsert dependencies.slog-term '2.9.2' | 
        #     upsert dependencies.clap.version '4.5.45' |
        #     save -f Cargo.toml
    }
    if $repository == 'mrxiaozhuox/nu_plugin_sled' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
        open src/commands/open.rs | lines | update 19 "     fn examples(&self) -> Vec<nu_protocol::Example<'_>> {" | str join (char nl) | save -f src/commands/open.rs
        open src/commands/save.rs | lines | update 19 "     fn examples(&self) -> Vec<nu_protocol::Example<'_>> {" | str join (char nl) | save -f src/commands/save.rs
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
