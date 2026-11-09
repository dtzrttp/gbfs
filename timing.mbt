///|
fn check_timing(
  documents : Map[String, Json],
  now : Double?,
) -> Array[Diagnostic] {
  let diagnostics = []
  for feed in supported_feeds() {
    guard documents.get(feed) is Some(document) else { continue }
    guard json_number(json_field(document, "last_updated")) is Some(updated) else {
      continue
    }
    let realtime = feed == "station_status" || feed == "free_bike_status"
    if now is Some(reference) {
      if updated > reference {
        diagnostics.push(
          relation_diagnostic(
            feed,
            "/last_updated",
            "timing.future_update",
            "发布时间晚于校验参考时间",
            "发布时间通常不晚于校验参考时间",
            "核对发布端和校验端的时钟及 Unix 秒单位",
            severity=Warning,
            actual=updated.to_string(),
          ),
        )
      } else if realtime && reference - updated > 300.0 {
        diagnostics.push(
          relation_diagnostic(
            feed,
            "/last_updated",
            "timing.stale",
            "近实时数据距参考时间已超过 5 分钟",
            "规范建议近实时数据的延迟不超过 300 秒",
            "重新取得快照并检查发布更新频率",
            severity=Warning,
            actual=(reference - updated).to_string(),
          ),
        )
      }
    }
    if realtime {
      if json_number(json_field(document, "ttl")) is Some(ttl) && ttl > 300.0 {
        diagnostics.push(
          relation_diagnostic(
            feed,
            "/ttl",
            "timing.long_cache",
            "近实时数据的缓存时长可能使延迟超过 5 分钟",
            "本工具建议近实时端点使用不超过 300 秒的 TTL",
            "根据发布频率调整 TTL。需要始终刷新时可使用 0",
            severity=Warning,
            actual=ttl.to_string(),
          ),
        )
      }
      let collection = if feed == "station_status" {
        "stations"
      } else {
        "bikes"
      }
      for index, row in snapshot_rows(documents, feed, collection) {
        if json_number(json_field(row, "last_reported")) is Some(reported) &&
          reported > updated {
          diagnostics.push(
            relation_diagnostic(
              feed,
              "/data/" + collection + "/" + index.to_string() + "/last_reported",
              "timing.report_after_update",
              "设备上报时间晚于本文件更新时间",
              "设备状态的上报时间通常不晚于快照发布时间",
              "核对时间戳来源、设备时钟及文件更新时间",
              severity=Warning,
              actual=reported.to_string(),
            ),
          )
        }
      }
    }
  }
  diagnostics
}
