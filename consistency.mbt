///|
/// 固定到被审计的 GBFS v2.3 规范提交，避免错误诊断引用可变的 master。
let spec_v23_source = "https://github.com/MobilityData/gbfs/blob/4f0cc7024ff5ba71d3c3e861c3ff23a281ef71f8/gbfs.md"

///|
fn escape_pointer_segment(segment : String) -> String {
  segment.replace_all(old="~", new="~0").replace_all(old="/", new="~1")
}

///|
fn json_field(value : Json, key : String) -> Json? {
  match value {
    Object(fields) => fields.get(key)
    _ => None
  }
}

///|
fn json_text(value : Json?) -> String? {
  match value {
    Some(String(text)) => Some(text)
    _ => None
  }
}

///|
fn json_items(value : Json?) -> Array[Json] {
  match value {
    Some(Array(items)) => items
    _ => []
  }
}

///|
fn snapshot_data(documents : Map[String, Json], feed : String) -> Json? {
  match documents.get(feed) {
    Some(document) => json_field(document, "data")
    None => None
  }
}

///|
fn snapshot_rows(
  documents : Map[String, Json],
  feed : String,
  property : String,
) -> Array[Json] {
  json_items(
    match snapshot_data(documents, feed) {
      Some(data) => json_field(data, property)
      None => None
    },
  )
}

///|
fn row_identifier(row : Json, field : String) -> String? {
  json_text(json_field(row, field))
}

///|
fn row_identifiers(rows : Array[Json], field : String) -> Map[String, Bool] {
  let identifiers : Map[String, Bool] = Map([])
  for row in rows {
    match row_identifier(row, field) {
      Some(identifier) => identifiers[identifier] = true
      None => ()
    }
  }
  identifiers
}

///|
fn relation_diagnostic(
  feed : String,
  pointer : String,
  code : String,
  message : String,
  expected : String,
  suggestion : String,
  severity~ : Severity = Error,
  actual? : String,
) -> Diagnostic {
  issue(
    feed,
    pointer,
    code,
    message,
    severity~,
    actual?,
    expected~,
    suggestion~,
    source=spec_v23_source,
  )
}

///|
fn check_identifier(
  feed : String,
  pointer : String,
  identifier : String,
  diagnostics : Array[Diagnostic],
) -> Unit {
  if identifier.contains(" ") {
    diagnostics.push(
      relation_diagnostic(
        feed,
        pointer,
        "consistency.id.contains_space",
        "标识符包含空格",
        "GBFS ID 不含空格",
        "移除标识符中的空格，并同步更新引用",
        actual=identifier,
      ),
    )
  }
}

///|
fn check_unique_rows(
  feed : String,
  rows : Array[Json],
  collection_pointer : String,
  id_field : String,
  diagnostics : Array[Diagnostic],
) -> Unit {
  let seen : Map[String, Bool] = Map([])
  for index, row in rows {
    let pointer = collection_pointer + "/" + index.to_string() + "/" + id_field
    match row_identifier(row, id_field) {
      Some(identifier) => {
        check_identifier(feed, pointer, identifier, diagnostics)
        if seen.contains(identifier) {
          diagnostics.push(
            relation_diagnostic(
              feed,
              pointer,
              "consistency.id.duplicate",
              "同一类记录的 ID 重复",
              "该端点内同类实体 ID 唯一",
              "为每条记录分配唯一且持久（车辆 ID 除外）的 ID",
              actual=identifier,
            ),
          )
        } else {
          seen[identifier] = true
        }
      }
      None => ()
    }
  }
}

///|
fn check_referenced_id(
  feed : String,
  pointer : String,
  identifier : String,
  known_identifiers : Map[String, Bool],
  entity_name : String,
  diagnostics : Array[Diagnostic],
) -> Unit {
  check_identifier(feed, pointer, identifier, diagnostics)
  if !known_identifiers.contains(identifier) {
    diagnostics.push(
      relation_diagnostic(
        feed,
        pointer,
        "consistency." + entity_name + ".unknown",
        "引用了不存在的" + entity_name,
        "ID 必须能在对应 GBFS v2.3 文件中找到",
        "检查引用拼写，并在同一快照中提供对应实体",
        actual=identifier,
      ),
    )
  }
}

///|
fn check_reference_field(
  feed : String,
  record : Json,
  pointer : String,
  field : String,
  known_identifiers : Map[String, Bool],
  entity_name : String,
  diagnostics : Array[Diagnostic],
) -> Unit {
  match row_identifier(record, field) {
    Some(identifier) =>
      check_referenced_id(
        feed,
        pointer + "/" + field,
        identifier,
        known_identifiers,
        entity_name,
        diagnostics,
      )
    None => ()
  }
}

///|
fn check_reference_array(
  feed : String,
  record : Json,
  pointer : String,
  field : String,
  known_identifiers : Map[String, Bool],
  entity_name : String,
  diagnostics : Array[Diagnostic],
) -> Unit {
  let values = json_items(json_field(record, field))
  for index, value in values {
    match value {
      String(identifier) =>
        check_referenced_id(
          feed,
          pointer + "/" + field + "/" + index.to_string(),
          identifier,
          known_identifiers,
          entity_name,
          diagnostics,
        )
      _ => ()
    }
  }
}

///|
fn check_dynamic_id_keys(
  feed : String,
  record : Json,
  pointer : String,
  field : String,
  known_identifiers : Map[String, Bool],
  entity_name : String,
  diagnostics : Array[Diagnostic],
) -> Unit {
  match json_field(record, field) {
    Some(Object(entries)) =>
      for identifier, _ in entries {
        check_referenced_id(
          feed,
          pointer + "/" + field + "/" + escape_pointer_segment(identifier),
          identifier,
          known_identifiers,
          entity_name,
          diagnostics,
        )
      }
    _ => ()
  }
}

///|
fn check_duplicate_definitions(
  documents : Map[String, Json],
) -> Array[Diagnostic] {
  let diagnostics = []
  if snapshot_data(documents, "system_information") is Some(system) &&
    row_identifier(system, "system_id") is Some(identifier) {
    check_identifier(
      "system_information", "/data/system_id", identifier, diagnostics,
    )
  }
  check_unique_rows(
    "station_information",
    snapshot_rows(documents, "station_information", "stations"),
    "/data/stations",
    "station_id",
    diagnostics,
  )
  check_unique_rows(
    "station_status",
    snapshot_rows(documents, "station_status", "stations"),
    "/data/stations",
    "station_id",
    diagnostics,
  )
  check_unique_rows(
    "free_bike_status",
    snapshot_rows(documents, "free_bike_status", "bikes"),
    "/data/bikes",
    "bike_id",
    diagnostics,
  )
  check_unique_rows(
    "vehicle_types",
    snapshot_rows(documents, "vehicle_types", "vehicle_types"),
    "/data/vehicle_types",
    "vehicle_type_id",
    diagnostics,
  )
  check_unique_rows(
    "system_regions",
    snapshot_rows(documents, "system_regions", "regions"),
    "/data/regions",
    "region_id",
    diagnostics,
  )
  check_unique_rows(
    "system_pricing_plans",
    snapshot_rows(documents, "system_pricing_plans", "plans"),
    "/data/plans",
    "plan_id",
    diagnostics,
  )
  check_unique_rows(
    "system_alerts",
    snapshot_rows(documents, "system_alerts", "alerts"),
    "/data/alerts",
    "alert_id",
    diagnostics,
  )
  diagnostics
}

///|
fn check_discovery(
  documents : Map[String, Json],
  local_files : Array[String],
) -> Array[Diagnostic] {
  let diagnostics = []
  match
    (documents.get("gbfs"), snapshot_data(documents, "system_information")) {
    (Some(discovery), Some(system_data)) => {
      let system_language = json_text(json_field(system_data, "language"))
      match (json_field(discovery, "data"), system_language) {
        (Some(Object(languages)), Some(language)) =>
          match languages.get(language) {
            Some(locale_data) => {
              let advertised = []
              let feed_entries = json_items(json_field(locale_data, "feeds"))
              for index, entry in feed_entries {
                match row_identifier(entry, "name") {
                  Some(name) => {
                    let pointer = "/data/" +
                      language +
                      "/feeds/" +
                      index.to_string() +
                      "/name"
                    if advertised.contains(name) {
                      diagnostics.push(
                        relation_diagnostic(
                          "gbfs",
                          pointer,
                          "consistency.discovery.duplicate_feed",
                          "发现文件重复声明同一端点",
                          "每个端点名只声明一次",
                          "删除重复的 feeds 项",
                          actual=name,
                        ),
                      )
                    } else {
                      advertised.push(name)
                    }
                  }
                  None => ()
                }
              }
              for name in advertised {
                if name != "gbfs" && !local_files.contains(name) {
                  diagnostics.push(
                    relation_diagnostic(
                      "gbfs",
                      "/data/" + language + "/feeds",
                      "consistency.discovery.missing_file",
                      "发现文件声明的端点未包含在本地快照",
                      "每个声明的端点都应提供对应本地 JSON 文件",
                      "补充该端点文件，或从发现文件移除不再发布的条目",
                      actual=name,
                    ),
                  )
                }
              }
              for name in local_files {
                if name != "gbfs" && !advertised.contains(name) {
                  diagnostics.push(
                    relation_diagnostic(
                      name,
                      "",
                      "consistency.discovery.unadvertised_file",
                      "本地端点未在 GBFS 发现文件中声明",
                      "v2.3 gbfs.json feeds 应列出本地快照中的端点",
                      "在所选语言的 feeds 中声明该端点，或从输入快照移除它",
                      actual=name + ".json",
                    ),
                  )
                }
              }
            }
            None =>
              diagnostics.push(
                relation_diagnostic(
                  "gbfs",
                  "/data",
                  "consistency.discovery.language_missing",
                  "发现文件未提供 system_information.language 对应的语言项",
                  "gbfs.data 中应存在语言键 " + language,
                  "使发现文件语言键与 system_information.language 一致",
                  actual=language,
                ),
              )
          }
        (_, Some(language)) =>
          diagnostics.push(
            relation_diagnostic(
              "system_information",
              "/data/language",
              "consistency.discovery.language_mismatch",
              "发现文件没有可用于比对的语言映射",
              "gbfs.data 应含与 system_information.language 相同的语言键",
              "修正发现文件的 data 语言映射",
              actual=language,
            ),
          )
        _ => ()
      }
    }
    _ => ()
  }
  diagnostics
}

///|
fn check_station_relations(
  documents : Map[String, Json],
  docked : Bool,
) -> Array[Diagnostic] {
  let diagnostics = []
  let information_rows = snapshot_rows(
    documents, "station_information", "stations",
  )
  let status_rows = snapshot_rows(documents, "station_status", "stations")
  let information_ids = row_identifiers(information_rows, "station_id")
  let status_ids = row_identifiers(status_rows, "station_id")
  if !docked &&
    documents.contains("station_information") &&
    !documents.contains("station_status") {
    diagnostics.push(
      relation_diagnostic(
        "station_status", "", "consistency.feed.missing_station_status", "快照包含站点信息但缺少对应站点状态文件",
        "使用站点的系统应同时发布 station_information.json 与 station_status.json",
        "补充 station_status.json，或确认输入包含同一系统的完整本地快照",
      ),
    )
  }
  if !docked &&
    documents.contains("station_status") &&
    !documents.contains("station_information") {
    diagnostics.push(
      relation_diagnostic(
        "station_information", "", "consistency.feed.missing_station_information",
        "快照包含站点状态但缺少对应站点信息文件", "每个站点状态均须关联 station_information.json 中的站点",
        "补充 station_information.json",
      ),
    )
  }
  for index, row in information_rows {
    match row_identifier(row, "station_id") {
      Some(identifier) if !status_ids.contains(identifier) =>
        diagnostics.push(
          relation_diagnostic(
            "station_information",
            "/data/stations/" + index.to_string() + "/station_id",
            "consistency.station_information.missing_status",
            "站点信息没有对应的站点状态记录",
            "station_id 必须出现在 station_status.json 的 stations 中",
            "补充对应状态记录，或从 station_information 移除不再发布的站点",
            actual=identifier,
          ),
        )
      _ => ()
    }
  }
  for index, row in status_rows {
    match row_identifier(row, "station_id") {
      Some(identifier) if !information_ids.contains(identifier) =>
        diagnostics.push(
          relation_diagnostic(
            "station_status",
            "/data/stations/" + index.to_string() + "/station_id",
            "consistency.station_status.unknown_station",
            "站点状态引用了未知站点",
            "station_id 必须出现在 station_information.json 的 stations 中",
            "修正 station_id，或补充对应站点信息记录",
            actual=identifier,
          ),
        )
      _ => ()
    }
  }
  diagnostics
}

///|
fn check_vehicle_and_plan_relations(
  documents : Map[String, Json],
) -> Array[Diagnostic] {
  let diagnostics = []
  let vehicle_rows = snapshot_rows(documents, "vehicle_types", "vehicle_types")
  let vehicle_ids = row_identifiers(vehicle_rows, "vehicle_type_id")
  let motor_types : Map[String, Bool] = Map([])
  for vehicle in vehicle_rows {
    if row_identifier(vehicle, "vehicle_type_id") is Some(identifier) &&
      row_identifier(vehicle, "propulsion_type") is Some(propulsion) &&
      propulsion != "human" {
      motor_types[identifier] = true
    }
  }
  let plans = snapshot_rows(documents, "system_pricing_plans", "plans")
  let plan_ids = row_identifiers(plans, "plan_id")
  let station_rows = snapshot_rows(documents, "station_status", "stations")
  let bike_rows = snapshot_rows(documents, "free_bike_status", "bikes")
  let station_information_rows = snapshot_rows(
    documents, "station_information", "stations",
  )
  let station_ids = row_identifiers(station_information_rows, "station_id")
  let regions = row_identifiers(
    snapshot_rows(documents, "system_regions", "regions"),
    "region_id",
  )

  for index, station in station_rows {
    let pointer = "/data/stations/" + index.to_string()
    if documents.contains("vehicle_types") &&
      json_field(station, "vehicle_types_available") is None {
      diagnostics.push(
        relation_diagnostic(
          "station_status",
          pointer + "/vehicle_types_available",
          "consistency.vehicle_types_available.required",
          "存在 vehicle_types.json 时站点缺少分类可用车辆数量",
          "每条 station_status 记录都应包含 vehicle_types_available 数组",
          "按车型填入可用车辆数量；无车辆时提供空数组",
        ),
      )
    }
    for
      type_index, item in json_items(
        json_field(station, "vehicle_types_available"),
      ) {
      check_reference_field(
        "station_status",
        item,
        pointer + "/vehicle_types_available/" + type_index.to_string(),
        "vehicle_type_id",
        vehicle_ids,
        "vehicle_type",
        diagnostics,
      )
    }
    for
      group_index, item in json_items(
        json_field(station, "vehicle_docks_available"),
      ) {
      check_reference_array(
        "station_status",
        item,
        pointer + "/vehicle_docks_available/" + group_index.to_string(),
        "vehicle_type_ids",
        vehicle_ids,
        "vehicle_type",
        diagnostics,
      )
    }
  }

  for index, station in station_information_rows {
    let pointer = "/data/stations/" + index.to_string()
    check_reference_field(
      "station_information", station, pointer, "region_id", regions, "region", diagnostics,
    )
    check_dynamic_id_keys(
      "station_information", station, pointer, "vehicle_capacity", vehicle_ids, "vehicle_type",
      diagnostics,
    )
    check_dynamic_id_keys(
      "station_information", station, pointer, "vehicle_type_capacity", vehicle_ids,
      "vehicle_type", diagnostics,
    )
  }

  for index, bike in bike_rows {
    let pointer = "/data/bikes/" + index.to_string()
    if row_identifier(bike, "vehicle_type_id") is Some(identifier) &&
      motor_types.contains(identifier) &&
      json_field(bike, "current_range_meters") is None {
      diagnostics.push(
        relation_diagnostic(
          "free_bike_status",
          pointer + "/current_range_meters",
          "consistency.motor_range.required",
          "机动车辆缺少当前续航",
          "对应车型使用非人力驱动时必须提供 current_range_meters",
          "补充剩余续航米数",
        ),
      )
    }
    if documents.contains("vehicle_types") &&
      json_field(bike, "vehicle_type_id") is None {
      diagnostics.push(
        relation_diagnostic(
          "free_bike_status",
          pointer + "/vehicle_type_id",
          "consistency.vehicle_type.required",
          "存在 vehicle_types.json 时车辆记录缺少车型 ID",
          "vehicle_type_id 必须引用 vehicle_types.json 中的车型",
          "补充该车辆的 vehicle_type_id",
        ),
      )
    }
    check_reference_field(
      "free_bike_status", bike, pointer, "vehicle_type_id", vehicle_ids, "vehicle_type",
      diagnostics,
    )
    check_reference_field(
      "free_bike_status", bike, pointer, "station_id", station_ids, "station", diagnostics,
    )
    check_reference_field(
      "free_bike_status", bike, pointer, "home_station_id", station_ids, "station",
      diagnostics,
    )
    check_reference_field(
      "free_bike_status", bike, pointer, "pricing_plan_id", plan_ids, "pricing_plan",
      diagnostics,
    )
  }

  for index, vehicle in vehicle_rows {
    let pointer = "/data/vehicle_types/" + index.to_string()
    check_reference_field(
      "vehicle_types", vehicle, pointer, "default_pricing_plan_id", plan_ids, "pricing_plan",
      diagnostics,
    )
    check_reference_array(
      "vehicle_types", vehicle, pointer, "pricing_plan_ids", plan_ids, "pricing_plan",
      diagnostics,
    )
  }

  let alerts = snapshot_rows(documents, "system_alerts", "alerts")
  for index, alert in alerts {
    let pointer = "/data/alerts/" + index.to_string()
    check_reference_array(
      "system_alerts", alert, pointer, "station_ids", station_ids, "station", diagnostics,
    )
    check_reference_array(
      "system_alerts", alert, pointer, "region_ids", regions, "region", diagnostics,
    )
  }
  diagnostics
}

///|
fn json_number(value : Json?) -> Double? {
  match value {
    Some(Number(number, ..)) => Some(number)
    _ => None
  }
}

///|
fn check_recommended_sums(documents : Map[String, Json]) -> Array[Diagnostic] {
  let diagnostics = []
  let station_information : Map[String, Json] = Map([])
  for station in snapshot_rows(documents, "station_information", "stations") {
    if row_identifier(station, "station_id") is Some(identifier) &&
      !station_information.contains(identifier) {
      station_information[identifier] = station
    }
  }
  for index, station in snapshot_rows(documents, "station_status", "stations") {
    let pointer = "/data/stations/" + index.to_string()
    match
      (
        json_number(json_field(station, "num_bikes_available")),
        json_field(station, "vehicle_types_available"),
      ) {
      (Some(total), Some(Array(types))) => {
        let mut sum = 0.0
        let mut complete = true
        for item in types {
          match json_number(json_field(item, "count")) {
            Some(count) => sum += count
            None => complete = false
          }
        }
        if complete && sum != total {
          diagnostics.push(
            relation_diagnostic(
              "station_status",
              pointer + "/vehicle_types_available",
              "consistency.bike_count.sum_mismatch",
              "按车型统计的车辆数与 num_bikes_available 不一致",
              "规范建议分类数量之和与 num_bikes_available 相同",
              "核对各车型 count；该项是 SHOULD 建议，因此报告为 warning",
              severity=Warning,
              actual=sum.to_string() + " ≠ " + total.to_string(),
            ),
          )
        }
      }
      _ => ()
    }
    match
      (
        json_number(json_field(station, "num_docks_available")),
        json_field(station, "vehicle_docks_available"),
      ) {
      (Some(total), Some(Array(groups))) => {
        let mut sum = 0.0
        let mut complete = true
        for item in groups {
          match json_number(json_field(item, "count")) {
            Some(count) => sum += count
            None => complete = false
          }
        }
        if complete && sum != total {
          diagnostics.push(
            relation_diagnostic(
              "station_status",
              pointer + "/vehicle_docks_available",
              "consistency.dock_count.sum_mismatch",
              "按车型适配的车桩数量与 num_docks_available 不一致",
              "规范建议分类车桩数量之和与 num_docks_available 相同",
              "核对各车桩组 count；该项是 SHOULD 建议，因此报告为 warning",
              severity=Warning,
              actual=sum.to_string() + " ≠ " + total.to_string(),
            ),
          )
        }
      }
      _ => ()
    }
    match json_number(json_field(station, "num_bikes_available")) {
      Some(available_bikes) => {
        let station_id = row_identifier(station, "station_id")
        let mut capacity : Double? = None
        let mut valet = false
        if station_id is Some(identifier) &&
          station_information.get(identifier) is Some(information) {
          capacity = json_number(json_field(information, "capacity"))
          valet = match json_field(information, "is_valet_station") {
            Some(value) => value.stringify() == "true"
            None => false
          }
        }
        if capacity is Some(_) &&
          !valet &&
          json_field(station, "num_docks_available") is None {
          diagnostics.push(
            relation_diagnostic(
              "station_status",
              pointer + "/num_docks_available",
              "consistency.docks_available.required",
              "具有已知有限容量的站点缺少可用车桩数",
              "有限停靠容量的站点必须提供 num_docks_available",
              "补充可用车桩数",
            ),
          )
        }
        match (capacity, valet) {
          (Some(limit), false) if available_bikes > limit =>
            diagnostics.push(
              relation_diagnostic(
                "station_status",
                pointer + "/num_bikes_available",
                "consistency.station.capacity_exceeded",
                "可用车辆数高于站点公布的容量",
                "可用车辆数不应超过 station_information.capacity",
                "核实容量含义、对应站点记录和状态数量；容量关系按合理性启发报告为 warning",
                severity=Warning,
                actual=available_bikes.to_string() + " > " + limit.to_string(),
              ),
            )
          _ => ()
        }
      }
      None => ()
    }
  }
  diagnostics
}

///|
/// 校验所有已成功通过单文件 Schema 的文档之间的 v2.3 关系。
fn validate_consistency(
  documents : Map[String, Json],
  local_files : Array[String],
  docked : Bool,
) -> Array[Diagnostic] {
  let diagnostics = []
  for diagnostic in check_discovery(documents, local_files) {
    diagnostics.push(diagnostic)
  }
  for diagnostic in check_duplicate_definitions(documents) {
    diagnostics.push(diagnostic)
  }
  for diagnostic in check_station_relations(documents, docked) {
    diagnostics.push(diagnostic)
  }
  for diagnostic in check_vehicle_and_plan_relations(documents) {
    diagnostics.push(diagnostic)
  }
  for diagnostic in check_recommended_sums(documents) {
    diagnostics.push(diagnostic)
  }
  diagnostics
}
