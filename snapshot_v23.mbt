///|
/// 校验 v2.3 本地快照的文件输入与单文件 Schema。跨文件语义由 consistency 模块处理。
pub fn validate_snapshot(feeds : Map[String, String]) -> Array[Diagnostic] {
  validate_snapshot_with_limits(feeds, max_snapshot_bytes())
}

///|
fn validate_snapshot_with_limits(
  feeds : Map[String, String],
  max_total_bytes : Int32,
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
  for name in supported_feeds() {
    match feeds.get(name) {
      Some(source) =>
        for diagnostic in validate_file(name, source) {
          diagnostics.push(diagnostic)
        }
      None =>
        if is_required_snapshot_feed(name) {
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
  limit_diagnostics(diagnostics, 5000)
}
