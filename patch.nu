#!/usr/bin/env nu

print ($env | get -o REPOSITORY)
def main [repository: string plugin_ver: string do_patch: bool] {
    # let plugin_ver = $env.PLUGIN_VER
    let src = $env.GITHUB_WORKSPACE

    print 'do file patch'

    cd $src

    ls

    if $do_patch == true {
        open Cargo.toml | 
            update dependencies.nu-plugin $plugin_ver | 
            update dependencies.nu-protocol { version: $plugin_ver features: ['plugin'] } | 
            if 'nuon' in ($in | get dependencies) { $in | update dependencies.nuon $plugin_ver } else { $in } | 
            if 'nu-path' in ($in | get dependencies) { $in | update dependencies.nu-path $plugin_ver } else { $in } | 
            if 'nu-plugin-test-support' in ($in | get -o dev-dependencies | default {}) { $in | update dev-dependencies.nu-plugin-test-support $plugin_ver } else { $in } | 
            if 'nu-cmd-base' in ($in | get dependencies) { $in | update dependencies.nu-cmd-base $plugin_ver } else { $in } | 
            save -f Cargo.toml
    }

    # if $repository in ['fdncred/nu_plugin_md' 'fdncred/nu_plugin_emoji' 'fdncred/nu_plugin_file' 'fdncred/nu_plugin_regex' 'fdncred/nu_plugin_bg' 'fdncred/nu_plugin_pnet' 'fdncred/nu_plugin_jwalk' 'fdncred/nu_plugin_json_path'] {
    #     patch-desc src/main.rs
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
        }
    }
    if $repository == 'FMotalleb/nu_plugin_image' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | upsert dependencies.lazy_static '1.4.0' | save -f Cargo.toml
        cargo update
        open src/logging/logger.rs | lines | update 0 'use lazy_static::lazy_static;' | str join (char nl) | save -f src/logging/logger.rs
        open src/ansi_to_image/nu_plugin.rs | lines | 
            update 22 '         ..' | 
            update 26 '         ..' | str join (char nl) | save -f src/ansi_to_image/nu_plugin.rs
    }
    if $repository == 'mrxiaozhuox/nu_plugin_sled' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
        open src/commands/open.rs | lines | 
            update 19 "     fn examples(&self) -> Vec<nu_protocol::Example<'_>> {" | str join (char nl) | save -f src/commands/open.rs
        open src/commands/save.rs | lines | 
            update 19 "     fn examples(&self) -> Vec<nu_protocol::Example<'_>> {" | str join (char nl) | save -f src/commands/save.rs
    }
    if $repository == 'nushell-works/nu_plugin_secret' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
    }
    if $repository == 'Elsie19/nu_plugin_nutext' {
        open src/commands/register.rs | lines | 
            update 46 "                Value::record(" |
            update 47 "                    record! {" |
            update 52 "                    Span::unknown()," |
            update 53 "                )," |
            str join (char nl) | save -f src/commands/register.rs

        open src\commands\stringret.rs | lines |
            update 127 "        Ok(Value::string(" |
            update 128 "            parsed_vars," |
            update 129 "            call.head," |
            update 130 "        ))" |
            str join (char nl) | save -f src/commands/stringret.rs
    }
    if $repository == 'dam4rus/nu_plugin_nuts' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | upsert dependencies.nu-utils '0.108.0' | save -f Cargo.toml
        cargo update

        open src/commands/kv/delete.rs | lines |
            update 118 "            Value::String { val, internal_span, .. } => jetstream" |
            update 131 "            ..} => {" |
            str join (char nl) | save -f src/commands/kv/delete.rs

        open src/commands/publish.rs | lines |
            update 178 "             Value::Record { val, internal_span, .. } => {" |
            str join (char nl) | save -f src/commands/publish.rs
    }

    if $repository == 'cablehead/nu_plugin_http_serve' {
        # open src/serve.rs | lines |
        #     update 167 "     let result = engine.eval_closure_with_stream(" |
        #     str join (char nl) | save -f src/serve.rs
        open src/serve.rs | str replace --all 'eval_closure_cloned_with_stream' 'eval_closure_with_stream' | save -f src/serve.rs
        cat src/serve.rs
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
