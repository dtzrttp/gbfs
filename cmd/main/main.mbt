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
fn load_snapshot(dir : String) -> Map[String, String] raise CliError {
  let entries = @fs.read_dir(dir) catch {
    _ => raise InputError("无法读取目录 \"\{dir}\"")
  }
  let feeds = Map([])
  for name in @gbfs.supported_feeds() {
    let file = name + ".json"
    if entries.any(entry => entry == file) {
      feeds[name] = read_document(dir + "/" + file)
    }
  }
  feeds
}

///|
fn print_report(issues : Array[@gbfs.Diagnostic], as_json : Bool) -> Int32 {
  let errors = issues.filter(issue => issue.severity is Error).length()
  let warnings = issues.length() - errors
  if as_json {
    let output : Json = {
      "version": "3.0",
      "errors": errors,
      "warnings": warnings,
      "diagnostics": Json::array(issues.map(issue => issue.to_json())),
    }
    println(output.stringify(indent=2))
  } else {
    for issue in issues {
      let level = if issue.severity is Error { "错误" } else { "警告" }
      let at = if issue.pointer.is_empty() {
        "（根）"
      } else {
        issue.pointer
      }
      let detail = match issue.schema_pointer {
        Some(path) => "（Schema " + path + "）"
        None => ""
      }
      println(
        "[\{level}] \{issue.file}\{at} \{issue.code} \{issue.message}\{detail}",
      )
    }
    println(
      "GBFS 3.0 校验完成，\{errors} 个错误，\{warnings} 个警告。",
    )
  }
  if errors == 0 {
    0
  } else {
    1
  }
}

///|
let usage : String =
  #|用法
  #|  check <目录> [--json]           校验一个本地 GBFS 3.0 快照
  #|  file <端点名> <文件> [--json]   校验单份文件（端点名不含 .json）
  #|  --help                          显示用法

///|
fn check_file(
  name : String,
  path : String,
  as_json : Bool,
) -> Int32 raise CliError {
  guard @gbfs.supported_feeds().contains(name) else {
    raise InputError("未支持的端点 " + Json(name).stringify())
  }
  let issues = @gbfs.validate_file(name, read_document(path))
  print_report(issues.map(issue => { ..issue, file: path, }), as_json)
}

///|
fn run(args : ArrayView[String]) -> Int32 raise CliError {
  match args {
    ["--help"] | ["-h"] => {
      println(usage)
      0
    }
    ["check", dir] =>
      print_report(@gbfs.validate_snapshot(load_snapshot(dir)), false)
    ["check", dir, "--json"] =>
      print_report(@gbfs.validate_snapshot(load_snapshot(dir)), true)
    ["file", name, path] => check_file(name, path, false)
    ["file", name, path, "--json"] => check_file(name, path, true)
    _ => raise InputError("命令行参数有误\n" + usage)
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
