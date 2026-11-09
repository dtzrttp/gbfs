///|
fn compile_schema(source : String) -> @schema.Schema {
  try! @schema.Schema::new(@json.parse(source[:]), format=true)
}

///|
let schemas : Map[String, @schema.Schema] = {
  "gbfs": compile_schema(schema_gbfs),
  "gbfs_versions": compile_schema(schema_gbfs_versions),
  "system_information": compile_schema(schema_system_information),
  "station_information": compile_schema(schema_station_information),
  "station_status": compile_schema(schema_station_status),
  "free_bike_status": compile_schema(schema_free_bike_status),
  "vehicle_types": compile_schema(schema_vehicle_types),
  "system_hours": compile_schema(schema_system_hours),
  "system_alerts": compile_schema(schema_system_alerts),
  "system_calendar": compile_schema(schema_system_calendar),
  "system_regions": compile_schema(schema_system_regions),
  "system_pricing_plans": compile_schema(schema_system_pricing_plans),
  "geofencing_zones": compile_schema(schema_geofencing_zones),
}

///|
fn schema_message(keyword : String) -> String {
  match keyword {
    "required" => "缺少必填字段"
    "type" => "字段类型不符合要求"
    "const" => "字段值不等于规定值"
    "enum" => "字段值不在允许列表中"
    "format" => "字段格式不符合要求"
    "pattern" => "字段与规定模式不匹配"
    "minimum" | "exclusiveMinimum" => "字段值低于允许范围"
    "maximum" | "exclusiveMaximum" => "字段值高于允许范围"
    "minItems" => "数组元素不足"
    "maxItems" => "数组元素过多"
    "minProperties" => "对象属性不足"
    "maxProperties" => "对象属性过多"
    "additionalProperties" => "对象含有未允许的字段"
    "contains" => "数组缺少符合条件的元素"
    "oneOf" => "必须恰好满足一种结构"
    "anyOf" => "至少需要满足一种结构"
    "not" => "字段符合 Schema 禁止的结构"
    _ => "字段不满足 GBFS v2.3 Schema 的 \{keyword} 规则"
  }
}

///|
fn pointer_segment(segment : String) -> String {
  segment.replace_all(old="~1", new="/").replace_all(old="~0", new="~")
}

///|
fn pointer_segments(pointer : String) -> Array[String] {
  let segments = []
  if pointer.is_empty() {
    return segments
  }
  let mut segment = ""
  let mut first = true
  for character in pointer {
    if character == '/' {
      if first {
        first = false
      } else {
        segments.push(pointer_segment(segment))
        segment = ""
      }
    } else {
      first = false
      segment += character.to_string()
    }
  }
  segments.push(pointer_segment(segment))
  segments
}

///|
fn value_at_pointer(value : Json, pointer : String) -> Json? {
  let mut current : Json? = Some(value)
  for segment in pointer_segments(pointer) {
    current = match current {
      Some(Object(fields)) => fields.get(segment)
      Some(Array(items)) => {
        let mut found : Json? = None
        for i, item in items {
          if i.to_string() == segment {
            found = Some(item)
            break
          }
        }
        found
      }
      _ => None
    }
  }
  current
}

///|
fn actual_value(value : Json, pointer : String) -> String? {
  match value_at_pointer(value, pointer) {
    Some(String(text)) => Some(text)
    Some(actual) => Some(actual.stringify())
    None => None
  }
}

///|
fn schema_expected(
  pointer : String,
  keyword : String,
  message : String,
) -> String {
  if pointer == "/version" && keyword == "const" {
    "2.3"
  } else if keyword == "required" {
    "字段必须存在"
  } else {
    "满足 Schema 的 \{keyword} 约束（\{message}）"
  }
}

///|
fn schema_suggestion(pointer : String, keyword : String) -> String {
  if pointer == "/version" && keyword == "const" {
    "将 version 设置为 2.3；本工具不会自动切换 GBFS 版本"
  } else if keyword == "required" {
    "按 JSON Pointer 补充缺少的字段"
  } else if keyword == "type" {
    "将该值改为 GBFS v2.3 Schema 指定的 JSON 类型"
  } else {
    "按官方 v2.3 Schema 修正该字段"
  }
}

///|
fn schema_issue(
  feed : String,
  value : Json,
  fault : @schema.Fault,
) -> Diagnostic {
  let mut pointer = fault.at
  let mut message = schema_message(fault.keyword)
  if fault.keyword == "required" && fault.message.has_prefix("missing ") {
    let field = fault.message[8:].to_owned()
    let escaped = field
      .replace_all(old="~", new="~0")
      .replace_all(old="/", new="~1")
    pointer += "/" + escaped
    message = "缺少必填字段 \{field}"
  }
  {
    file: feed + ".json",
    pointer,
    severity: Error,
    code: "schema." + fault.keyword,
    message,
    actual: actual_value(value, pointer),
    expected: Some(schema_expected(pointer, fault.keyword, fault.message)),
    suggestion: Some(schema_suggestion(pointer, fault.keyword)),
    source: Some(
      "https://github.com/MobilityData/gbfs-json-schema/blob/01d4cb480410ca234b1d76799daf474b8f839e85/v2.3/" +
      feed +
      ".json",
    ),
    schema_pointer: Some(fault.schema_at),
  }
}

///|
/// 校验一份 GBFS v2.3 端点 JSON；feed 是不含扩展名的固定端点名。
pub fn validate_file(feed : String, source : String) -> Array[Diagnostic] {
  if !is_supported_feed(feed) {
    return [
      issue(
        feed,
        "",
        "feed.unsupported",
        "首版只支持 GBFS v2.3 的 13 个官方端点",
        actual=feed,
        expected="v2.3 官方端点名",
        suggestion="更换为受支持的端点名，或升级项目版本后再验证",
        source="docs/decisions.md 的首版支持范围",
      ),
    ]
  }
  match parse_json_untrusted(feed + ".json", source) {
    Err(diagnostic) => [diagnostic]
    Ok(document) => validate_document_schema(feed, untrusted_value(document))
  }
}

///|
fn validate_document_schema(feed : String, value : Json) -> Array[Diagnostic] {
  let faults = schemas[feed].faults(value)
  // v2.3 正文允许跨午夜服务时刻，官方 Schema 的小时模式只接受 00–23。
  let applicable = faults.filter(fault => {
    if feed != "system_hours" ||
      fault.keyword != "pattern" ||
      !(fault.at.has_suffix("/start_time") || fault.at.has_suffix("/end_time")) {
      true
    } else {
      match value_at_pointer(value, fault.at) {
        Some(String(time)) => !is_extended_service_time(time)
        _ => true
      }
    }
  })
  limit_diagnostics(
    applicable.map(fault => schema_issue(feed, value, fault)),
    1000,
  )
}

///|
fn is_extended_service_time(time : String) -> Bool {
  let chars = time.to_array()
  if chars.length() != 8 || chars[2] != ':' || chars[5] != ':' {
    return false
  }
  let hour = chars[0] >= '2' &&
    chars[0] <= '4' &&
    chars[1] >= '0' &&
    chars[1] <= '9' &&
    (chars[0] != '2' || chars[1] >= '4') &&
    (chars[0] != '4' || chars[1] <= '7')
  hour &&
  chars[3] >= '0' &&
  chars[3] <= '5' &&
  chars[4] >= '0' &&
  chars[4] <= '9' &&
  chars[6] >= '0' &&
  chars[6] <= '5' &&
  chars[7] >= '0' &&
  chars[7] <= '9'
}
