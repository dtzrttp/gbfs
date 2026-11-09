///|
test "v2.3 快照校验已提供文件的 Schema 并报告缺少的入口文件" {
  let feeds : Map[String, String] = Map::from_array([
    ("vehicle_types", v23_document({ "vehicle_types": [] })),
  ])
  let diagnostics = validate_snapshot(feeds)
  assert_eq(diagnostics.length(), 2)
  assert_eq(diagnostics[0].file, "gbfs.json")
  assert_eq(diagnostics[1].file, "system_information.json")
}

///|
test "v2.3 快照拒绝不支持的 v3.0 端点名" {
  let feeds : Map[String, String] = { "vehicle_status": "{}" }
  let diagnostics = validate_snapshot(feeds)
  assert_true(diagnostics.any(d => d.code == "feed.unsupported"))
}
