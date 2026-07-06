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
            if 'nu-cmd-lang' in ($in | get -o dev-dependencies | default {}) { $in | update dev-dependencies.nu-cmd-lang $plugin_ver } else { $in } | 
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
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | upsert dependencies.nu-utils '0.110.0' | save -f Cargo.toml
        cargo update
        #open src/nu/mod.rs | str replace --all 'usage(&self)' 'description(&self)' | save -f src/nu/mod.rs
        #open src/nu/mod.rs | str replace --all 'as_f64' 'as_float' | save -f src/nu/mod.rs
    }

    # if $repository == 'FMotalleb/nu_plugin_audio_hook' {
    #     open src/sound_make.rs | str replace --all 'as_f64' 'as_float' | save -f src/sound_make.rs
    # }

    if $repository == 'Com6235/nu-plugin-http-server' {
        open src/commands/mod.rs | lines |
            update 26 '        Value::String { val, internal_span: _, .. } => (val.as_bytes().to_vec(), parse_pipeline_mime(meta, "text/plain")),' |
            update 27 '         Value::Nothing { internal_span: _ , .. } => (vec![], String::from("text/plain")),' |
            update 28 '         Value::Bool { val, internal_span: _ , .. } => ((if val { "true" } else { "false" }).as_bytes().to_vec(), parse_pipeline_mime(meta, "text/plain")),' |
            update 29 '         Value::Binary { val, internal_span: _ , .. } => (val, parse_pipeline_mime(meta, "application/octet-stream")),' |
            update 40 '         Value::Binary { val, internal_span: _ , .. } => Ok((val, parse_pipeline_mime(meta, "application/octet-stream"))),' |
            update 41 '         Value::String { val, internal_span: _ , .. } => Ok((val.as_bytes().to_vec(), parse_pipeline_mime(meta, "text/plain"))),' |
            str join (char nl) | save -f src/commands/mod.rs
        
        nu toolbox.nu
    }

    # last update 2 years ago
    if $repository == 'fdncred/nu_plugin_bg' {
        let codes = open src/main.rs | lines
        if (($codes | slice 109..112 | str join '' | str replace --regex --all '\s*' '') == 'Ok(Value::Int{val:process.id()asi64,internal_span:value_span,})') {
            $codes | update 110 '' | update 111 '' | update 112 '' | update 109 '        Ok(Value::int(process.id() as i64, value_span))' | str join (char nl) | save -f src/main.rs
        }
    }
    #if $repository == 'FMotalleb/nu_plugin_image' {
    #    open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | upsert dependencies.lazy_static '1.4.0' | save -f Cargo.toml
    #    cargo update
    #    open src/logging/logger.rs | lines | update 0 'use lazy_static::lazy_static;' | str join (char nl) | save -f src/logging/logger.rs
    #    open src/ansi_to_image/nu_plugin.rs | lines | 
    #        update 22 '         ..' | 
    #        update 26 '         ..' | str join (char nl) | save -f src/ansi_to_image/nu_plugin.rs
    #}

    if $repository == 'mrxiaozhuox/nu_plugin_sled' {
    #    open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
    #    rm Cargo.lock
    #    cargo update
    #    cargo update -p libc
        open src\commands\open.rs | lines | 
            update 55 ".input_output_type(Type::Nothing, Type::record())" | str join (char nl) | save -f src/commands/open.rs
        open src/commands/save.rs | lines | 
            update 40 ".input_output_type(Type::record(), Type::Nothing)" | str join (char nl) | save -f src/commands/save.rs
    }

    if $repository == 'x_nushell-works/nu_plugin_secret' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
    }
    if $repository == 'ArmoredPony/nu_plugin_hashes' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | upsert dependencies.blake3 { version: "=1.8.3", optional: true, default-features: false, features: ["std", "traits-preview"] } | save -f Cargo.toml
        cargo update -p blake3
        cargo update
    }
    if $repository == 'windtail/nu_plugin_unzip' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
        open src\lib.rs | lines |
            update 157 "                    Type::Table(vec![" |
            update 161 "                    ].into())," | str join (char nl) | save -f src\lib.rs
    }

    if $repository == 'yybit/nu_plugin_x509' {
        open src\gen.rs | lines |
            update 55 "                   Type::Record(vec![" |
            update 58 "                   ].into())" | str join (char nl) | save -f src\gen.rs

        open src\parse.rs | lines |
            update 89 "                   .map(|serial| hex::encode(serial.as_ref() as &[u8]))" | str join (char nl) | save -f src\parse.rs
    }

    if $repository == 'alex-kattathra-johnson/nu_plugin_ws' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
    }
    if $repository == 'punund/nu_plugin_socket' {
        open src/connect.rs | lines |
            update 189 "path_columns: Vec::new(),});" |
            str join (char nl) | save -f src/connect.rs
    }
#    if $repository == 'Elsie19/nu_plugin_nutext' {
#        open src/commands/register.rs | lines | 
#            update 46 "                Value::record(" |
#            update 47 "                    record! {" |
#            update 52 "                    Span::unknown()," |
#            update 53 "                )," |
#            str join (char nl) | save -f src/commands/register.rs
#
#        open src\commands\stringret.rs | lines |
#            update 127 "        Ok(Value::string(" |
#            update 128 "            parsed_vars," |
#            update 129 "            call.head," |
#            update 130 "        ))" |
#            str join (char nl) | save -f src/commands/stringret.rs
#    }
    if $repository == 'dam4rus/nu_plugin_nuts' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update

        #open src/commands/kv/delete.rs | lines |
        #    update 118 "            Value::String { val, internal_span, .. } => jetstream" |
        #    update 131 "            ..} => {" |
        #    str join (char nl) | save -f src/commands/kv/delete.rs

        #open src/commands/publish.rs | lines |
        #    update 178 "             Value::Record { val, internal_span, .. } => {" |
        #    str join (char nl) | save -f src/commands/publish.rs
    }

    if $repository == 'cablehead/nu_plugin_http_serve' {
        # open src/serve.rs | lines |
        #     update 167 "     let result = engine.eval_closure_with_stream(" |
        #     str join (char nl) | save -f src/serve.rs
        open src/serve.rs | str replace --all 'eval_closure_cloned_with_stream' 'eval_closure_with_stream' | save -f src/serve.rs
        cat src/serve.rs
    }

    #if $repository == 'kik4444/nu_plugin_mime' {
    #    open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | upsert dependencies.nu-utils '0.110.0' | save -f Cargo.toml
    #    cargo update
    #}
    if $repository == 'glcraft/nu_plugin_from_more' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
    }
    if $repository == 'x_nushell-works/nu_plugin_nw_ulid' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
    }    
    if $repository == 'eggcaker/nu_plugin_to_xlsx' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
    }
    
    if $repository == 'cristianbdg/nu_plugin_cer' {
        open src\command.rs | lines |
            update 18 "     fn description(&self) -> &str {" |
            str join (char nl) | save -f src\command.rs
    }

    if $repository == 'x_dam4rus/nu_plugin_nuts' {
        open src\commands\kv\delete.rs | lines |
            update 127 "                })?" |
            str join (char nl) | save -f src\commands\kv\delete.rs
    }

    if $repository == 'nushell-works/nu_plugin_secret' {
        patch-file-line --file_path 'src\secret_types\operations.rs' [
            { line: 50, text: '        _ => Err(ShellError::Generic {' },
            { line: 84, text: '             return Err(ShellError::Generic {' },
            { line: 101, text: '         return Err(ShellError::Generic {' },
            { line: 112, text: '         .ok_or_else(|| ShellError::Generic {' }
        ]
        patch-file-line --file_path 'src\commands\config_export.rs' [
            { line: 67, text: '             .input_output_types(vec![(Type::Nothing, Type::record())])' }
        ]
        patch-file-line --file_path 'src\commands\config_import.rs' [
            { line: 98, text: '             .input_output_types(vec![(Type::Nothing, Type::record())])' }
        ]
        patch-file-line --file_path 'src\commands\config_reset.rs' [
            { line: 86, text: '             .input_output_types(vec![(Type::Nothing, Type::record())])' }
        ]
        patch-file-line --file_path 'src\commands\config_show.rs' [
            { line: 91, text: '             .input_output_types(vec![(Type::Nothing, Type::record())])' }
        ]
        patch-file-line --file_path 'src\commands\config_validate.rs' [
            { line: 181, text: '             .input_output_types(vec![(Type::Nothing, Type::record())])' }
        ]
        patch-file-line --file_path 'src\commands\configure.rs' [
            { line: 105, text: '             .input_output_types(vec![(Type::Nothing, Type::record())])' }
        ]
        patch-file-line --file_path 'src\commands\info.rs' [
            { line: 18, text: '             .input_output_types(vec![(Type::Nothing, Type::record())])' }
        ]
        patch-file-line --file_path 'src\commands\unwrap.rs' [
            { line: 29, text: '                    Type::record(),' }
        ]
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

def patch-file-line [
    --file_path: path,                               # The file to modify
    replacements: table<line: int, text: string>   # Table containing line numbers (1-indexed) and new text
] {
    # 1. Read the file as raw text to avoid auto-parsing, then split by newlines
    let original_lines = (open --raw $file_path | lines)
    
    # 2. Iterate through the lines and swap out text if the index matches
    let patched_lines = ($original_lines | enumerate | each {|row|
        
        # We add 1 to Nushell's 0-based index so it matches your 1-based input
        let match = ($replacements | where line == ($row.index + 1))
        
        if ($match | is-empty) {
            $row.item
        } else {
            $match | first | get text
        }
    })
    
    # 3. Join the lines back together, ensure a trailing newline, and overwrite the file
    let result = (($patched_lines | str join (char newline)) + (char newline))
    $result | save --force $file_path
    
    print $"Successfully patched ($file_path)!"
}