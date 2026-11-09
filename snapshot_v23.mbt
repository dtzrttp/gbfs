///|
/// 校验 v2.3 本地快照的 Schema 与跨文件关系。此入口不读取当前时间。
pub fn validate_snapshot(feeds : Map[String, String]) -> Array[Diagnostic] {
  validate_snapshot_with_limits(feeds, max_snapshot_bytes())
}

///|
fn validate_snapshot_with_limits(
  feeds : Map[String, String],
  max_total_bytes : Int32,
  now? : Double,
  docked~ : Bool = false,
  free_floating~ : Bool = false,
) -> Array[Diagnostic] {
  let mut total_bytes = 0
  let mut exceeds_limit = false
  for _, source in feeds {
    let size = @utf8.encode(source).length()
    if size > max_total_bytes - total_bytes {
      exceeds_limit = true
      break
    }
    total_bytes += size
  }
  if exceeds_limit {
    return [
      issue(
        "<snapshot>",
        "",
        "input.total_too_large",
        "快照的 UTF-8 总字节数超过限制，未开始 Schema 验证",
        actual="> " + max_total_bytes.to_string() + " 字节",
        expected="不超过 " + max_total_bytes.to_string() + " 字节",
        suggestion="减少输入文件或分批验证快照",
        source="本工具的离线输入安全边界",
      ),
    ]
  }
  let diagnostics = []
  let documents : Map[String, Json] = Map([])
  let mut all_supplied_files_valid = true
  for name in supported_feeds() {
    match feeds.get(name) {
      Some(source) =>
        match parse_json_untrusted(name + ".json", source) {
          Err(diagnostic) => {
            diagnostics.push(diagnostic)
            all_supplied_files_valid = false
          }
          Ok(document) => {
            let value = untrusted_value(document)
            let file_diagnostics = validate_document_schema(name, value)
            for diagnostic in file_diagnostics {
              diagnostics.push(diagnostic)
            }
            if has_errors(file_diagnostics) {
              all_supplied_files_valid = false
            } else {
              documents[name] = value
            }
          }
        }
      None =>
        if is_required_snapshot_feed(name) ||
          (
            docked &&
            (name == "station_information" || name == "station_status")
          ) ||
          (free_floating && name == "free_bike_status") {
          diagnostics.push(
            issue(
              name,
              "",
              "feed.missing",
              "快照缺少必需的 GBFS v2.3 文件",
              expected="提供 " + name + ".json",
              suggestion="从同一运营方的 GBFS v2.3 发布目录补充此文件",
              source="docs/spec-map.md 的 v2.3 文件范围",
            ),
          )
        }
    }
  }
  for name, _ in feeds {
    if !is_supported_feed(name) {
      all_supplied_files_valid = false
      diagnostics.push(
        issue(
          name,
          "",
          "feed.unsupported",
          "输入文件名不属于 GBFS v2.3 支持端点",
          actual=name,
          expected="13 个官方 v2.3 端点之一",
          suggestion="检查文件名，v2.3 使用 free_bike_status.json",
          source="docs/spec-map.md 的 v2.3 文件范围",
        ),
      )
    }
  }
  if all_supplied_files_valid {
    let local_files = []
    for name, _ in feeds {
      if is_supported_feed(name) {
        local_files.push(name)
      }
    }
    for diagnostic in validate_consistency(documents, local_files, docked) {
      diagnostics.push(diagnostic)
    }
    for diagnostic in check_timing(documents, now) {
      diagnostics.push(diagnostic)
    }
  }
  limit_diagnostics(diagnostics, 5000)
}

///|
/// 额外按调用者提供的 POSIX 秒时间检查快照的新鲜度。
pub fn validate_snapshot_at(
  feeds : Map[String, String],
  now : Double,
) -> Array[Diagnostic] {
  validate_snapshot_with_limits(feeds, max_snapshot_bytes(), now~)
}

///|
/// 显式指定运营模式。可同时要求有桩和无桩端点。
pub fn validate_snapshot_with_options(
  feeds : Map[String, String],
  docked~ : Bool = false,
  free_floating~ : Bool = false,
  now? : Double,
) -> Array[Diagnostic] {
  validate_snapshot_with_limits(
    feeds,
    max_snapshot_bytes(),
    now?,
    docked~,
    free_floating~,
  )
}
