///|
fn field_value(value : Json, key : String) -> Json? {
  match value {
    Object(fields) => fields.get(key)
    _ => None
  }
}

///|
fn members(value : Json, key : String) -> Array[Json] {
  match field_value(value, key) {
    Some(Array(items)) => items
    _ => []
  }
}

///|
fn records(
  valid : Map[String, Json],
  feed : String,
  array : String,
) -> Array[Json] {
  match valid.get(feed) {
    Some({ "data": data, .. }) => members(data, array)
    _ => []
  }
}

///|
fn index(
  items : Array[Json],
  feed : String,
  array : String,
  key : String,
  issues : Array[Diagnostic],
) -> Map[String, Json] {
  let result = Map([])
  for i, record in items {
    if field_value(record, key) is Some(String(id)) {
      let pointer = "/data/\{array}/\{i}/\{key}"
      if key != "name" &&
        (id.is_empty() || id.iter().any(c => c < '!' || c > '~')) {
        issues.push(
          issue(
            feed, pointer, "id.invalid", "ID 必须由不含空格的可打印 ASCII 字符组成",
          ),
        )
      }
      if result.contains(id) {
        issues.push(
          issue(
            feed,
            pointer,
            "id.duplicate",
            "重复标识符 " + Json(id).stringify(),
          ),
        )
      } else {
        result[id] = record
      }
    }
  }
  result
}

///|
fn check_discovery(
  provided : Map[String, String],
  valid : Map[String, Json],
  issues : Array[Diagnostic],
) -> Bool {
  let entries = records(valid, "gbfs", "feeds")
  let declared = index(entries, "gbfs", "feeds", "name", issues)
  if valid.contains("gbfs") {
    for i, item in entries {
      if field_value(item, "name") is Some(String(name)) &&
        name != "gbfs" &&
        name != "system_information" &&
        schemas.contains(name) &&
        !provided.contains(name) {
        issues.push(
          issue(
            "gbfs",
            "/data/feeds/\{i}/name",
            "feed.missing",
            "已声明但未提供本地文件 \{name}.json",
          ),
        )
      }
    }
    for name in supported_feeds() {
      if name != "gbfs" && provided.contains(name) && !declared.contains(name) {
        issues.push(
          issue(name, "", "feed.unlisted", "该文件未列入 gbfs.json"),
        )
      }
    }
  }
  let has_info = provided.contains("station_information") ||
    declared.contains("station_information")
  let has_status = provided.contains("station_status") ||
    declared.contains("station_status")
  if has_info != has_status {
    let missing = if has_info {
      "station_status"
    } else {
      "station_information"
    }
    issues.push(
      issue(
        missing, "", "station.pair_required", "站点信息和状态端点必须成对提供",
      ),
    )
  }
  provided.contains("vehicle_types") || declared.contains("vehicle_types")
}

///|
fn check_station_pair(
  rows : Array[Json],
  feed : String,
  target : Map[String, Json],
  code : String,
  issues : Array[Diagnostic],
) -> Unit {
  for i, row in rows {
    if field_value(row, "station_id") is Some(String(id)) &&
      !target.contains(id) {
      issues.push(
        issue(
          feed,
          "/data/stations/\{i}/station_id",
          code,
          "对应文件中没有站点 " + Json(id).stringify(),
        ),
      )
    }
  }
}

///|
fn check_reference(
  value : Json?,
  feed : String,
  pointer : String,
  target : Map[String, Json]?,
  code : String,
  issues : Array[Diagnostic],
) -> Unit {
  if value is Some(String(id)) &&
    target is Some(entries) &&
    !entries.contains(id) {
    issues.push(
      issue(
        feed,
        pointer,
        code,
        "被引用的 ID 不存在 " + Json(id).stringify(),
      ),
    )
  }
}

///|
fn check_dock_references(
  row : Json,
  feed : String,
  path : String,
  name : String,
  types : Map[String, Json]?,
  issues : Array[Diagnostic],
) -> Unit {
  for i, group in members(row, name) {
    for j, id in members(group, "vehicle_type_ids") {
      check_reference(
        Some(id),
        feed,
        "\{path}/\{name}/\{i}/vehicle_type_ids/\{j}",
        types,
        "vehicle_type.unknown",
        issues,
      )
    }
  }
}

///|
fn check_total(
  row : Json,
  path : String,
  field : String,
  groups : String,
  code : String,
  issues : Array[Diagnostic],
) -> Unit {
  guard field_value(row, field) is Some(Number(expected, ..)) &&
    field_value(row, groups) is Some(Array(items)) else {
    return
  }
  let mut sum = 0.0
  for item in items {
    if field_value(item, "count") is Some(Number(count, ..)) {
      sum += count
    }
  }
  if expected <= 9007199254740991.0 &&
    sum <= 9007199254740991.0 &&
    sum != expected {
    issues.push(
      issue(
        "station_status",
        path + "/" + field,
        code,
        "\{field} 与 \{groups} 的数量合计不一致",
        severity=Warning,
      ),
    )
  }
}

///|
fn restricts_docks(station : Json, types : Map[String, Json]) -> Bool {
  for group in members(station, "vehicle_docks_capacity") {
    if field_value(group, "count") is Some(Number(count, ..)) && count > 0.0 {
      let allowed = Map([])
      for item in members(group, "vehicle_type_ids") {
        if item is String(id) {
          allowed[id] = ()
        }
      }
      for id, _ in types {
        if !allowed.contains(id) {
          return true
        }
      }
    }
  }
  false
}

///|
fn check_station_types(
  information : Array[Json],
  status : Array[Json],
  stations : Map[String, Json],
  types : Map[String, Json]?,
  type_feed_defined : Bool,
  issues : Array[Diagnostic],
) -> Unit {
  for i, row in information {
    let path = "/data/stations/\{i}"
    check_dock_references(
      row, "station_information", path, "vehicle_types_capacity", types, issues,
    )
    check_dock_references(
      row, "station_information", path, "vehicle_docks_capacity", types, issues,
    )
  }
  for i, row in status {
    let feed = "station_status"
    let path = "/data/stations/\{i}"
    if field_value(row, "station_id") is Some(String(id)) &&
      stations.get(id) is Some(station) {
      if field_value(row, "num_docks_available") is None &&
        !(field_value(station, "is_valet_station") is Some(True)) &&
        (
          field_value(station, "capacity") is Some(_) ||
          field_value(station, "is_virtual_station") is Some(False)
        ) {
        issues.push(
          issue(
            feed,
            path + "/num_docks_available",
            "station.docks_required",
            "实体车桩站点或已知容量有限的站点必须报告可用车桩数",
          ),
        )
      }
      if field_value(row, "vehicle_docks_available") is None &&
        types is Some(entries) &&
        restricts_docks(station, entries) {
        issues.push(
          issue(
            feed,
            path + "/vehicle_docks_available",
            "station.dock_types_required",
            "车桩限制车型时必须报告各车型可用车桩数",
          ),
        )
      }
    }
    if type_feed_defined && field_value(row, "vehicle_types_available") is None {
      issues.push(
        issue(
          feed,
          path + "/vehicle_types_available",
          "vehicle_type.required",
          "已定义 vehicle_types，必须提供各车辆类型的可用数量",
        ),
      )
    }
    for j, count in members(row, "vehicle_types_available") {
      check_reference(
        field_value(count, "vehicle_type_id"),
        feed,
        "\{path}/vehicle_types_available/\{j}/vehicle_type_id",
        types,
        "vehicle_type.unknown",
        issues,
      )
    }
    check_dock_references(
      row, feed, path, "vehicle_docks_available", types, issues,
    )
    check_total(
      row, path, "num_vehicles_available", "vehicle_types_available", "count.vehicle_total",
      issues,
    )
    check_total(
      row, path, "num_docks_available", "vehicle_docks_available", "count.dock_total",
      issues,
    )
  }
}

///|
fn check_vehicles(
  vehicles : Array[Json],
  stations : Map[String, Json]?,
  types : Map[String, Json]?,
  type_feed_defined : Bool,
  issues : Array[Diagnostic],
) -> Unit {
  for i, row in vehicles {
    let feed = "vehicle_status"
    let path = "/data/vehicles/\{i}"
    for key in ["station_id", "home_station_id"] {
      check_reference(
        field_value(row, key),
        feed,
        path + "/" + key,
        stations,
        "station.unknown",
        issues,
      )
    }
    let id = field_value(row, "vehicle_type_id")
    if type_feed_defined && id is None {
      issues.push(
        issue(
          feed,
          path + "/vehicle_type_id",
          "vehicle_type.required",
          "已定义 vehicle_types，必须标明车辆类型",
        ),
      )
    }
    check_reference(
      id,
      feed,
      path + "/vehicle_type_id",
      types,
      "vehicle_type.unknown",
      issues,
    )
    if id is Some(String(type_id)) &&
      types is Some(entries) &&
      entries.get(type_id) is Some(definition) &&
      field_value(definition, "propulsion_type") is Some(String(propulsion)) &&
      propulsion != "human" &&
      field_value(row, "current_range_meters") is None {
      issues.push(
        issue(
          feed,
          path + "/current_range_meters",
          "vehicle.range_required",
          "有动力车辆必须提供当前续航",
        ),
      )
    }
  }
}

///|
/// 验证本地快照中的端点及受支持的跨文件关系。
pub fn validate_snapshot(feeds : Map[String, String]) -> Array[Diagnostic] {
  let issues = []
  let valid = Map([])
  for name in supported_feeds() {
    match feeds.get(name) {
      Some(source) =>
        if parse_feed(name, source, issues) is Some(value) {
          valid[name] = value
        }
      None =>
        if name == "gbfs" || name == "system_information" {
          issues.push(
            issue(name, "", "feed.missing", "缺少必需的本地文件"),
          )
        }
    }
  }
  for name, _ in feeds {
    if !schemas.contains(name) {
      issues.push(
        issue(
          name,
          "",
          "feed.unsupported",
          "此端点不在首版校验范围内",
          severity=Warning,
        ),
      )
    }
  }
  let type_feed_defined = check_discovery(feeds, valid, issues)
  let information = records(valid, "station_information", "stations")
  let status = records(valid, "station_status", "stations")
  let vehicles = records(valid, "vehicle_status", "vehicles")
  let types = records(valid, "vehicle_types", "vehicle_types")
  let station_index = index(
    information, "station_information", "stations", "station_id", issues,
  )
  let status_index = index(
    status, "station_status", "stations", "station_id", issues,
  )
  let type_index = index(
    types, "vehicle_types", "vehicle_types", "vehicle_type_id", issues,
  )
  index(vehicles, "vehicle_status", "vehicles", "vehicle_id", issues) |> ignore
  if valid.contains("station_information") && valid.contains("station_status") {
    check_station_pair(
      information, "station_information", status_index, "station.missing_status",
      issues,
    )
    check_station_pair(
      status, "station_status", station_index, "station.missing_information", issues,
    )
  }
  let station_refs = if valid.contains("station_information") ||
    !feeds.contains("station_information") {
    Some(station_index)
  } else {
    None
  }
  let type_refs = if valid.contains("vehicle_types") ||
    !feeds.contains("vehicle_types") {
    Some(type_index)
  } else {
    None
  }
  check_station_types(
    information, status, station_index, type_refs, type_feed_defined, issues,
  )
  check_vehicles(vehicles, station_refs, type_refs, type_feed_defined, issues)
  issues
}
