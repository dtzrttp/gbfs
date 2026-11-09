///|
/// 首版支持的文件名，不含 .json 后缀。
pub fn supported_feeds() -> Array[String] {
  [
    "gbfs", "system_information", "station_information", "station_status", "vehicle_types",
    "vehicle_status",
  ]
}

///|
fn compile_schema(source : String) -> @schema.Schema {
  // 只编译仓库固定的上游 Schema。测试覆盖全部六份。
  try! @schema.Schema::new(@json.parse(source[:]), format=true)
}

///|
let schemas : Map[String, @schema.Schema] = {
  "gbfs": compile_schema(schema_gbfs),
  "system_information": compile_schema(schema_system_information),
  "station_information": compile_schema(schema_station_information),
  "station_status": compile_schema(schema_station_status),
  "vehicle_types": compile_schema(schema_vehicle_types),
  "vehicle_status": compile_schema(schema_vehicle_status),
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
    "additionalProperties" => "对象含有未允许的字段"
    "contains" => "数组缺少符合条件的元素"
    "oneOf" => "必须恰好满足一种结构"
    "anyOf" => "至少需要满足一种结构"
    "not" => "字段符合 Schema 禁止的结构"
    _ => "字段不满足 GBFS 3.0 Schema 的 \{keyword} 规则"
  }
}

///|
fn schema_issue(feed : String, fault : @schema.Fault) -> Diagnostic {
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
  if feed == "gbfs" && pointer == "/data/feeds" {
    match fault.schema_at {
      "/properties/data/properties/feeds/contains" =>
        message = "发现列表必须包含 system_information"
      "/properties/data/properties/feeds/allOf/0/anyOf" =>
        message = "发现列表必须至少包含 station_status 或 vehicle_status"
      "/properties/data/properties/feeds/allOf/1/then/contains" =>
        message = "列出 station_information 时必须同时列出 station_status"
      _ => ()
    }
  }
  issue(
    feed,
    pointer,
    "schema." + fault.keyword,
    message,
    schema_pointer=fault.schema_at,
  )
}

///|
fn is_feed_url(text : String) -> Bool {
  let url = @url.Url::decode(text[:], syntax=Rfc3986) catch {
    _ => return false
  }
  if url.scheme is Some(scheme) && url.host is Some(host) {
    let protocol = scheme.to_lower()
    (protocol == "http" || protocol == "https") && !host.is_empty()
  } else {
    false
  }
}

///|
fn check_feed_urls(value : Json, issues : Array[Diagnostic]) -> Unit {
  if value is { "data": { "feeds": Array(feeds), .. }, .. } {
    for i, feed in feeds {
      if feed is { "url": String(url), .. } && !is_feed_url(url) {
        issues.push(
          issue(
            "gbfs",
            "/data/feeds/\{i}/url",
            "feed.url",
            "端点必须是包含主机的 HTTP 或 HTTPS URL",
          ),
        )
      }
    }
  }
}

///|
fn parse_feed(
  feed : String,
  source : String,
  issues : Array[Diagnostic],
) -> Json? {
  guard schemas.get(feed) is Some(schema) else {
    issues.push(issue(feed, "", "feed.unsupported", "首版未支持此端点"))
    return None
  }
  if source.length() > 8 * 1024 * 1024 {
    issues.push(
      issue(
        feed, "", "json.too_large", "JSON 文本超过 8 Mi 个编码单元",
      ),
    )
    return None
  }
  let value = @json.parse(
    source[:],
    max_nesting_depth=64,
    reject_duplicate_keys=true,
  ) catch {
    _ => {
      issues.push(
        issue(
          feed, "", "json.invalid", "JSON 语法无效、含有重复键或嵌套超过 64 层",
        ),
      )
      return None
    }
  }
  let faults = schema.faults(value)
  for fault in faults {
    issues.push(schema_issue(feed, fault))
  }
  if feed == "gbfs" {
    check_feed_urls(value, issues)
  }
  // URL 关系诊断独立于发现列表的结构可读性。
  if faults.is_empty() {
    Some(value)
  } else {
    None
  }
}

///|
/// 验证单个端点的 JSON 及官方 Schema。
pub fn validate_file(feed : String, source : String) -> Array[Diagnostic] {
  let issues = []
  parse_feed(feed, source, issues) |> ignore
  issues
}
