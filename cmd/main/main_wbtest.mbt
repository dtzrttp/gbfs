///|
test "CLI 可解析显式列出的本地 JSON 文件" {
  let code = run(["parse", "tests/fixtures/parser/valid.json"][:]) catch {
    InputError(_) => 2
  }
  assert_eq(code, 0)
}

///|
test "CLI 可读取目录内的本地 JSON 文件" {
  let code = run(["parse", "tests/fixtures/parser/directory"][:]) catch {
    InputError(_) => 2
  }
  assert_eq(code, 0)
}

///|
test "CLI 对无效 JSON 返回数据错误退出码" {
  let code = run(["parse", "tests/fixtures/parser/invalid.json", "--json"][:]) catch {
    InputError(_) => 2
  }
  assert_eq(code, 1)
}

///|
test "check CLI 校验一个离线 GBFS v2.3 目录" {
  let code = run(["check", "tests/fixtures/v2.3/snapshot"][:]) catch {
    InputError(_) => 2
  }
  assert_eq(code, 0)
}

///|
test "check CLI 支持显式列出的端点文件" {
  let code = run(
    [
      "check", "tests/fixtures/v2.3/snapshot/gbfs.json", "tests/fixtures/v2.3/snapshot/system_information.json",
      "tests/fixtures/v2.3/snapshot/station_information.json", "tests/fixtures/v2.3/snapshot/station_status.json",
    ][:],
  ) catch {
    InputError(_) => 2
  }
  assert_eq(code, 0)
}
