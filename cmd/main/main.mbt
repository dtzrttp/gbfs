///|
priv suberror CliError {
  InputError(String)
}

///|
extern "js" fn stderr(message : String) -> Unit =
  #| (message) => console.error(message)

///|
extern "js" fn set_exit_code(code : Int32) -> Unit =
  #| (code) => { process.exitCode = code; }

///|
extern "js" fn now_unix_seconds() -> Double =
  #| () => Math.floor(Date.now() / 1000)

///|
fn read_document(path : String) -> String raise CliError {
  let content = try {
    guard @fs.is_file(path) else {
      raise InputError("不是普通文件 \"\{path}\"")
    }
    @fs.read_file_to_bytes(path)
  } catch {
    InputError(_) as error => raise error
    _ => raise InputError("无法读取文件 \"\{path}\"")
  }
  if content.length() > 8 * 1024 * 1024 {
    raise InputError("文件超过 8 MiB \"\{path}\"")
  }
  @utf8.decode(content[:], ignore_bom=true) catch {
    _ => raise InputError("文件含有无效 UTF-8 \"\{path}\"")
  }
}

///|
fn is_regular_file(path : String) -> Bool {
  @fs.is_file(path) catch {
    _ => false
  }
}

///|
fn collect_paths(inputs : Array[String]) -> Array[String] raise CliError {
  let paths = []
  for input in inputs {
    let is_directory = @fs.is_dir(input) catch { _ => false }
    if is_directory {
      let entries = @fs.read_dir(input) catch {
        _ => raise InputError("无法读取目录 \"\{input}\"")
      }
      for name in entries {
        if name.length() >= 5 && name[name.length() - 5:] == ".json" {
          let path = input + "/" + name
          if is_regular_file(path) {
            paths.push(path)
          }
        }
      }
    } else {
      if !is_regular_file(input) {
        raise InputError("不是普通文件或目录 \"\{input}\"")
      }
      paths.push(input)
    }
  }
  if paths.is_empty() {
    raise InputError("输入中没有 JSON 文件")
  }
  if paths.length() > @gbfs.max_input_files() {
    raise InputError(
      "单次最多读取 " +
      @gbfs.max_input_files().to_string() +
      " 个 JSON 文件",
    )
  }
  paths
}

///|
fn print_parse_report(
  diagnostics : Array[@gbfs.Diagnostic],
  as_json : Bool,
) -> Int32 {
  let errors = diagnostics.filter(d => d.severity is Error).length()
  let warnings = diagnostics.filter(d => d.severity is Warning).length()
  let infos = diagnostics.filter(d => d.severity is Info).length()
  if as_json {
    let output : Json = {
      "tool": "gbfs.mbt",
      "result": "syntax_only",
      "schema_validation": "not_run",
      "errors": errors,
      "warnings": warnings,
      "infos": infos,
      "diagnostics": Json::array(diagnostics.map(d => d.to_json())),
    }
    println(output.stringify(indent=2))
  } else {
    for diagnostic in diagnostics {
      let level = match diagnostic.severity {
        Error => "错误"
        Warning => "警告"
        Info => "信息"
      }
      let at = if diagnostic.pointer.is_empty() {
        "（根）"
      } else {
        diagnostic.pointer
      }
      println(
        "[\{level}] \{diagnostic.file}\{at} \{diagnostic.code} \{diagnostic.message}",
      )
    }
    println(
      "仅完成 JSON 语法解析；未运行 GBFS Schema 或跨文件校验。\{errors} 个错误，\{warnings} 个警告，\{infos} 条信息。",
    )
  }
  if errors == 0 {
    0
  } else {
    1
  }
}

///|
fn parse_inputs(inputs : Array[String], as_json : Bool) -> Int32 raise CliError {
  let paths = collect_paths(inputs)
  let diagnostics = []
  let mut total_bytes = 0
  for path in paths {
    let source = read_document(path)
    total_bytes += @utf8.encode(source).length()
    if total_bytes > @gbfs.max_snapshot_bytes() {
      raise InputError("所有输入文件的 UTF-8 总字节数超过 64 MiB")
    }
    match @gbfs.parse_json_untrusted(path, source) {
      Ok(_) => ()
      Err(diagnostic) => diagnostics.push(diagnostic)
    }
  }
  print_parse_report(@gbfs.sort_diagnostics(diagnostics), as_json)
}

///|
fn endpoint_from_path(path : String) -> String raise CliError {
  let normalized = path.replace_all(old="\\", new="/")
  let mut basename = ""
  for character in normalized {
    if character == '/' {
      basename = ""
    } else {
      basename += character.to_string()
    }
  }
  guard basename.length() >= 5 && basename[basename.length() - 5:] == ".json" else {
    raise InputError("端点文件名必须以 .json 结尾：\"" + path + "\"")
  }
  basename[:basename.length() - 5].to_owned()
}

///|
fn validation_report(
  diagnostics : Array[@gbfs.Diagnostic],
  as_json : Bool,
  label : String,
) -> Int32 {
  let errors = diagnostics.filter(d => d.severity is Error).length()
  let warnings = diagnostics.filter(d => d.severity is Warning).length()
  let infos = diagnostics.filter(d => d.severity is Info).length()
  if as_json {
    let output : Json = {
      "version": @gbfs.gbfs_version(),
      "errors": errors,
      "warnings": warnings,
      "infos": infos,
      "diagnostics": Json::array(diagnostics.map(d => d.to_json())),
    }
    println(output.stringify(indent=2))
  } else {
    for diagnostic in diagnostics {
      let level = match diagnostic.severity {
        Error => "错误"
        Warning => "警告"
        Info => "信息"
      }
      let at = if diagnostic.pointer.is_empty() {
        "（根）"
      } else {
        diagnostic.pointer
      }
      println(
        "[" +
        level +
        "] " +
        diagnostic.file +
        at +
        " " +
        diagnostic.code +
        " " +
        diagnostic.message,
      )
      if diagnostic.actual is Some(_) || diagnostic.expected is Some(_) {
        println(
          "  实际值=" +
          diagnostic.actual.unwrap_or("（无）") +
          "；期望=" +
          diagnostic.expected.unwrap_or("（未提供）"),
        )
      }
      if diagnostic.suggestion is Some(suggestion) {
        println("  建议=" + suggestion)
      }
      if diagnostic.source is Some(source) {
        println("  来源=" + source)
      }
    }
    println(
      label +
      "：" +
      errors.to_string() +
      " 个错误，" +
      warnings.to_string() +
      " 个警告，" +
      infos.to_string() +
      " 条信息。",
    )
  }
  if errors == 0 {
    0
  } else {
    1
  }
}

///|
fn check_inputs(
  inputs : Array[String],
  as_json : Bool,
  freshness : Bool,
) -> Int32 raise CliError {
  let paths = collect_paths(inputs)
  let feeds = Map([])
  let path_by_feed = Map([])
  let mut total_bytes = 0
  for path in paths {
    let feed = endpoint_from_path(path)
    if feeds.contains(feed) {
      raise InputError("同一快照含有重复端点文件 " + feed + ".json")
    }
    let source = read_document(path)
    total_bytes += @utf8.encode(source).length()
    if total_bytes > @gbfs.max_snapshot_bytes() {
      raise InputError("所有输入文件的 UTF-8 总字节数超过 64 MiB")
    }
    feeds[feed] = source
    path_by_feed[feed] = path
  }
  let diagnostics = if freshness {
    @gbfs.validate_snapshot_at(feeds, now_unix_seconds())
  } else {
    @gbfs.validate_snapshot(feeds)
  }
  let with_paths = diagnostics.map(diagnostic => {
    let endpoint = if diagnostic.file.has_suffix(".json") {
      diagnostic.file[:diagnostic.file.length() - 5].to_owned()
    } else {
      diagnostic.file
    }
    match path_by_feed.get(endpoint) {
      Some(path) => { ..diagnostic, file: path, }
      None => diagnostic
    }
  })
  validation_report(
    @gbfs.sort_diagnostics(with_paths),
    as_json,
    "GBFS v2.3 快照校验完成",
  )
}

///|
let usage : String =
  #|用法
  #|  check <目录或 JSON 文件...> [--freshness] [--json] 校验 GBFS v2.3 的本地快照
  #|  file <端点 JSON 文件> [--json] 仅校验该文件的官方 Schema
  #|  parse <目录或 JSON 文件...> [--json] 仅解析 JSON，不执行 Schema 校验
  #|  --help                                 显示用法

///|
fn run(args : ArrayView[String]) -> Int32 raise CliError {
  if args.length() >= 2 && args[0] == "parse" {
    let as_json = args[args.length() - 1] == "--json"
    let end = if as_json { args.length() - 1 } else { args.length() }
    if end <= 1 {
      raise InputError(
        "parse 需要至少一个目录或文件路径\n" + usage,
      )
    }
    let inputs = []
    for i in 1..<end {
      inputs.push(args[i])
    }
    parse_inputs(inputs, as_json)
  } else if args.length() >= 2 && args[0] == "file" {
    let as_json = args[args.length() - 1] == "--json"
    let end = if as_json { args.length() - 1 } else { args.length() }
    guard end == 2 else {
      raise InputError("file 需要一个端点 JSON 文件路径")
    }
    let path = args[1]
    let feed = endpoint_from_path(path)
    let diagnostics = @gbfs.validate_file(feed, read_document(path)).map(diagnostic => {
      ..diagnostic,
      file: path,
    })
    validation_report(
      diagnostics, as_json, "GBFS v2.3 单文件 Schema 校验完成",
    )
  } else if args.length() >= 2 && args[0] == "check" {
    let as_json = args[args.length() - 1] == "--json"
    let end_without_json = if as_json {
      args.length() - 1
    } else {
      args.length()
    }
    let freshness = end_without_json > 1 &&
      args[end_without_json - 1] == "--freshness"
    let end = if freshness { end_without_json - 1 } else { end_without_json }
    if end <= 1 {
      raise InputError(
        "check 需要至少一个目录或 JSON 文件路径\n" + usage,
      )
    }
    let inputs = []
    for i in 1..<end {
      inputs.push(args[i])
    }
    check_inputs(inputs, as_json, freshness)
  } else {
    match args {
      ["--help"] | ["-h"] => {
        println(usage)
        0
      }
      _ => raise InputError("命令行参数有误\n" + usage)
    }
  }
}

///|
fn main {
  let argv = @env.args()
  let code = run(argv[2:]) catch {
    InputError(message) => {
      stderr(message)
      2
    }
  }
  set_exit_code(code)
}
