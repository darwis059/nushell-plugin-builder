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
    }

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

    if $repository == 'alex-kattathra-johnson/nu_plugin_ws' {
        open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | save -f Cargo.toml
        cargo update
    }
    if $repository == 'punund/nu_plugin_socket' {
        patch-file-line --file_path  'src\listen.rs' [
            { line: 125, text: '        .map_err(|e| nu_protocol::LabeledError::new("Failed to set read timeout")' },
            { line: 126, text: '            .with_help(e.to_string())' },
            { line: 127, text: '            .with_label("here", head)' },
            { line: 128, text: '        )?;' },
            { line: 129, text: '' },
            { line: 130, text: '' },
            { line: 131, text: '' },
            { line: 133, text: '    let bytes_read = stream.read(&mut request_bytes).map_err(|e| nu_protocol::LabeledError::new("Failed to read from socket")' },
            { line: 134, text: '        .with_help(format!("This can happen if the client disconnects or the read times out. {}", e))' },
            { line: 135, text: '        .with_label("here", head)' },
            { line: 136, text: '    )?;' },
            { line: 154, text: '        Value::Binary { val, .. } => val.to_vec(),' },
            { line: 155, text: '        other => return Err(nu_protocol::LabeledError::new("Unsupported closure output")' },
            { line: 156, text: '            .with_help("The closure for `socket listen` must return a string or binary value.")' },
            { line: 157, text: '            .with_label(format!("Expected string or binary from closure, but got {}.", other.get_type()), head)' },
            { line: 158, text: '            .into())' },
            { line: 159, text: '' },
            { line: 160, text: '' },
            { line: 161, text: '' },

            { line: 165, text: '        nu_protocol::LabeledError::new("Failed to write to socket")' },
            { line: 166, text: '            .with_help(e.to_string())' },
            { line: 167, text: '            .with_label("here", head)' },
            { line: 168, text: '' },
            { line: 169, text: '' },
            { line: 170, text: '' },
            { line: 171, text: '' },
        ]
        patch-file-line --file_path  'src\connect.rs' [
            { line: 87, text: '            Value::Binary { val, .. } => val.to_vec(),' },
            { line: 190, text: '                path_columns: vec![],});' },
        ]
    }

    if $repository == 'dam4rus/nu_plugin_nuts' {
        # open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | upsert dependencies.nu-utils '0.114.0' | save -f Cargo.toml
        # cargo update

        patch-file-line --file_path  'src\commands\publish.rs' [
            { line: 29, text: '                ("headers", Type::record()),' },
            { line: 30, text: '                ("payload", Type::String),' },
            { line: 36, text: '                ("headers", Type::record()),' },
            { line: 37, text: '                ("payload", Type::Binary),' }
        ]
    }

    if $repository == 'cablehead/nu_plugin_http_serve' {
        open src/serve.rs | str replace --all 'eval_closure_cloned_with_stream' 'eval_closure_with_stream' | save -f src/serve.rs
        cat src/serve.rs
    }

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
        #patch-file-line --file_path 'src\secret_types\operations.rs' [
        #    { line: 50, text: '        _ => Err(ShellError::Generic {' },
        #    { line: 84, text: '             return Err(ShellError::Generic {' },
        #    { line: 101, text: '         return Err(ShellError::Generic {' },
        #    { line: 112, text: '         .ok_or_else(|| ShellError::Generic {' }
        #]
        # patch-file 'src\secret_types\operations.rs' 'ShellError::GenericError' 'ShellError::Generic '
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
    
    if $repository == 'yybit/nu_plugin_x509' {
        patch-file-line --file_path  'src\gen.rs' [
            { line: 56, text: '                   Type::Record(vec![' },
            { line: 59, text: '                   ].into()),' }
        ]
        patch-file-line --file_path  'src\parse.rs' [
            { line: 90, text: '   .map(|serial| hex::encode(serial.as_ref() as &[u8]))' }
        ]
    }

    if $repository == 'kik4444/nu_plugin_mime' {
    #    open Cargo.toml | upsert dependencies.windows-sys '0.61.2' | upsert dependencies.nu-utils '0.110.0' | save -f Cargo.toml
    #    cargo update
        patch-file-line --file_path  'src\guess.rs' [
            { line: 26, text: '                       Type::Table(vec![' },
            { line: 29, text: '                       ].into()),' }
        ]
    }

    if $repository == 'adevore/nu_plugin_ldap' {
        patch-file-line --file_path  'src\commands\search\command.rs' [
            { line: 34, text: '                   Type::List(Box::new(Type::Record(vec![' },
            { line: 38, text: '                   ].into()))),' }
        ]
        patch-file-line --file_path  'src\commands\table.rs' [
            { line: 42, text: '                   Type::List(Box::new(Type::Record(vec![' },
            { line: 46, text: '                   ].into()))),' }
        ]
    }
}

def patch-desc [file] {
     open $file | str replace --all 'fn description(&self)' 'fn usage(&self)' | save -f $file
}

def patch-file [file: string old:string new: string] {
    let src = open $file
    if ($src | find $new | is-empty) {
        print $'replace all ($old) with ($new) in file ($file)'
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