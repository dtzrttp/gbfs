///|
/// 本工具固定校验的 GBFS 版本。
pub fn gbfs_version() -> String {
  "2.3"
}

///|
/// GBFS v2.3 官方端点文件名，不含 `.json` 扩展名。
pub fn supported_feeds() -> Array[String] {
  [
    "gbfs", "gbfs_versions", "system_information", "station_information", "station_status",
    "free_bike_status", "vehicle_types", "system_hours", "system_alerts", "system_calendar",
    "system_regions", "system_pricing_plans", "geofencing_zones",
  ]
}

///|
/// 判断端点名是否属于固定支持范围。
pub fn is_supported_feed(name : String) -> Bool {
  supported_feeds().contains(name)
}

///|
/// 单次快照输入允许的最大本地文件数。
pub fn max_input_files() -> Int32 {
  256
}

///|
/// 单次快照输入允许的最大 UTF-8 总字节数。
pub fn max_snapshot_bytes() -> Int32 {
  64 * 1024 * 1024
}
