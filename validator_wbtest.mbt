///|
fn document(data : Json) -> String {
  let value : Json = {
    "version": "3.0",
    "last_updated": "2026-11-09T08:00:00Z",
    "ttl": 30,
    "data": data,
  }
  value.stringify()
}

///|
fn has_code(diagnostics : Array[Diagnostic], code : String) -> Bool {
  diagnostics.any(issue => issue.code == code)
}

///|
fn feed_fixture() -> Map[String, String] {
  {
    "gbfs": document({
      "feeds": [
        { "name": "system_information", "url": "https://example.org/system" },
        { "name": "station_information", "url": "https://example.org/stations" },
        { "name": "station_status", "url": "https://example.org/status" },
        { "name": "vehicle_types", "url": "https://example.org/types" },
        { "name": "vehicle_status", "url": "https://example.org/vehicles" },
      ],
    }),
    "system_information": document({
      "system_id": "demo",
      "languages": ["en"],
      "name": [{ "text": "Demo", "language": "en" }],
      "opening_hours": "24/7",
      "feed_contact_email": "feeds@example.org",
      "timezone": "Asia/Shanghai",
    }),
    "station_information": document({
      "stations": [
        {
          "station_id": "s1",
          "name": [{ "text": "Central", "language": "en" }],
          "lat": 31.2,
          "lon": 121.4,
          "capacity": 5,
        },
      ],
    }),
    "station_status": document({
      "stations": [
        {
          "station_id": "s1",
          "num_vehicles_available": 2,
          "num_docks_available": 3,
          "vehicle_types_available": [{ "vehicle_type_id": "bike", "count": 2 }],
          "is_installed": true,
          "is_renting": true,
          "is_returning": true,
          "last_reported": "2026-11-09T08:00:00Z",
        },
      ],
    }),
    "vehicle_types": document({
      "vehicle_types": [
        {
          "vehicle_type_id": "bike",
          "form_factor": "bicycle",
          "propulsion_type": "human",
        },
      ],
    }),
    "vehicle_status": document({
      "vehicles": [
        {
          "vehicle_id": "v1",
          "station_id": "s1",
          "vehicle_type_id": "bike",
          "is_reserved": false,
          "is_disabled": false,
        },
      ],
    }),
  }
}

///|
test "完整快照通过" {
  assert_eq(validate_snapshot(feed_fixture()).length(), 0)
}

///|
test "拒绝重复 JSON 键、错误版本和非法时间" {
  assert_true(
    has_code(
      validate_file("vehicle_types", "{\"a\":1,\"a\":2}"),
      "json.invalid",
    ),
  )
  let good = document({ "vehicle_types": [] })
  assert_true(
    has_code(
      validate_file("vehicle_types", good.replace_all(old="3.0", new="3.1")),
      "schema.const",
    ),
  )
  assert_true(
    has_code(
      validate_file(
        "vehicle_types",
        good.replace_all(old="2026-11-09", new="2026-02-30"),
      ),
      "schema.format",
    ),
  )
}

///|
test "Schema 对纬度范围和发现文件的条件规则返回路径" {
  let feeds = feed_fixture()
  let bad = feeds["station_information"].replace_all(old="31.2", new="91.0")
  let issues = validate_file("station_information", bad)
  assert_true(
    issues.any(d => {
      d.pointer == "/data/stations/0/lat" && d.code == "schema.maximum"
    }),
  )
  let discovery = document({
    "feeds": [
      { "name": "system_information", "url": "https://example.org/info" },
      { "name": "station_information", "url": "https://example.org/stations" },
    ],
  })
  assert_true(has_errors(validate_file("gbfs", discovery)))
}

///|
test "报告双向站点缺项、车辆类型引用与数量差异" {
  let feeds = feed_fixture()
  let original = feeds["station_status"]
  feeds["station_status"] = original
    .replace_all(old="\"s1\"", new="\"s2\"")
    .replace_all(old="\"bike\"", new="\"unknown\"")
    .replace_all(old="\"count\":2", new="\"count\":1")
  let issues = validate_snapshot(feeds)
  assert_true(has_code(issues, "station.missing_information"))
  assert_true(has_code(issues, "station.missing_status"))
  assert_true(has_code(issues, "vehicle_type.unknown"))
  assert_true(
    issues.any(d => d.code == "count.vehicle_total" && d.severity == Warning),
  )
}

///|
test "缺少已声明的本地端点及重复 ID" {
  let feeds = feed_fixture()
  feeds.remove("vehicle_status")
  feeds["vehicle_types"] = document({
    "vehicle_types": [
      {
        "vehicle_type_id": "bike",
        "form_factor": "bicycle",
        "propulsion_type": "human",
      },
      {
        "vehicle_type_id": "bike",
        "form_factor": "bicycle",
        "propulsion_type": "human",
      },
    ],
  })
  let issues = validate_snapshot(feeds)
  assert_true(has_code(issues, "feed.missing"))
  assert_true(
    issues.any(d => {
      d.code == "id.duplicate" &&
      d.pointer == "/data/vehicle_types/1/vehicle_type_id"
    }),
  )
}

///|
test "必填项的诊断指向具体缺失字段" {
  let issues = validate_file(
    "vehicle_status",
    document({
      "vehicles": [
        { "vehicle_id": "v1", "lat": 31.2, "lon": 121.4, "is_disabled": false },
      ],
    }),
  )
  assert_true(
    issues.any(d => {
      d.code == "schema.required" && d.pointer == "/data/vehicles/0/is_reserved"
    }),
  )
}

///|
test "有限泊位和有动力车辆需要提供条件字段" {
  let feeds = feed_fixture()
  feeds["station_status"] = feeds["station_status"].replace_all(
    old="\"num_docks_available\":3,",
    new="",
  )
  feeds["vehicle_types"] = document({
    "vehicle_types": [
      {
        "vehicle_type_id": "bike",
        "form_factor": "bicycle",
        "propulsion_type": "electric_assist",
        "max_range_meters": 10000,
      },
    ],
  })
  let issues = validate_snapshot(feeds)
  assert_true(has_code(issues, "station.docks_required"))
  assert_true(has_code(issues, "vehicle.range_required"))
}

///|
test "明确的实体车桩及车型限制触发状态必填项" {
  let feeds = feed_fixture()
  feeds["station_information"] = document({
    "stations": [
      {
        "station_id": "s1",
        "name": [{ "text": "Central", "language": "en" }],
        "lat": 31.2,
        "lon": 121.4,
        "is_virtual_station": false,
        "vehicle_docks_capacity": [{ "vehicle_type_ids": ["bike"], "count": 5 }],
      },
    ],
  })
  feeds["vehicle_types"] = document({
    "vehicle_types": [
      {
        "vehicle_type_id": "bike",
        "form_factor": "bicycle",
        "propulsion_type": "human",
      },
      {
        "vehicle_type_id": "cargo",
        "form_factor": "cargo_bicycle",
        "propulsion_type": "human",
      },
    ],
  })
  feeds["station_status"] = feeds["station_status"].replace_all(
    old="\"num_docks_available\":3,",
    new="",
  )
  let issues = validate_snapshot(feeds)
  assert_true(has_code(issues, "station.docks_required"))
  assert_true(has_code(issues, "station.dock_types_required"))
  feeds["station_information"] = feeds["station_information"]
    .replace_all(
      old="\"is_virtual_station\":false",
      new="\"is_virtual_station\":false,\"is_valet_station\":true",
    )
    .replace_all(old="[\"bike\"]", new="[\"bike\",\"cargo\"]")
  assert_eq(validate_snapshot(feeds).length(), 0)
}

///|
test "发现 URL 必须包含 HTTP(S) 协议和主机" {
  let valid = feed_fixture()["gbfs"]
  for
    url in [
      "javascript:alert(1)", "ftp://example.org/feed", "http:example.org", "https://",
    ] {
    let invalid = valid.replace_all(old="https://example.org/system", new=url)
    let issues = validate_file("gbfs", invalid)
    assert_true(
      issues.any(d => d.code == "feed.url" && d.pointer == "/data/feeds/0/url"),
    )
  }
}
