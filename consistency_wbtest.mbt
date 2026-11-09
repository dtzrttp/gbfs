///|
fn test_envelope(data : Json) -> String {
  (
    { "last_updated": 1450155600, "ttl": 0, "version": "2.3", "data": data } :
    Json).stringify()
}

///|
fn test_station_information(id : String) -> Json {
  { "station_id": id, "name": "Test station", "lat": 31.2, "lon": 121.5 }
}

///|
fn test_station_status(id : String, bikes : Int32) -> Json {
  {
    "station_id": id,
    "num_bikes_available": bikes,
    "is_installed": true,
    "is_renting": true,
    "is_returning": true,
    "last_reported": 1450155600,
  }
}

///|
fn test_discovery(names : Array[String]) -> String {
  let feeds : Array[Json] = names.map(name => {
    ({ "name": name, "url": "https://example.org/gbfs/" + name } : Json)
  })
  test_envelope({ "en": { "feeds": feeds } })
}

///|
fn test_snapshot(
  information : Array[Json],
  status : Array[Json],
) -> Map[String, String] {
  let advertised = [
    "system_information", "station_information", "station_status",
  ]
  {
    "gbfs": test_discovery(advertised),
    "system_information": test_envelope({
      "system_id": "test",
      "language": "en",
      "name": "Test system",
      "timezone": "Asia/Shanghai",
    }),
    "station_information": test_envelope({ "stations": information }),
    "station_status": test_envelope({ "stations": status }),
  }
}

///|
fn test_has_code(diagnostics : Array[Diagnostic], code : String) -> Bool {
  diagnostics.any(diagnostic => diagnostic.code == code)
}

///|
test "station_status 与 station_information 双向引用通过" {
  let diagnostics = validate_snapshot(
    test_snapshot([test_station_information("station-a")], [
      test_station_status("station-a", 2),
    ]),
  )
  assert_true(!has_errors(diagnostics))
}

///|
test "未知站点状态引用与缺失状态站点都给出稳定错误" {
  let unknown_status = validate_snapshot(
    test_snapshot([test_station_information("station-a")], [
      test_station_status("station-b", 0),
    ]),
  )
  assert_true(
    test_has_code(unknown_status, "consistency.station_status.unknown_station"),
  )
  let missing_status = validate_snapshot(
    test_snapshot([test_station_information("station-a")], []),
  )
  assert_true(
    test_has_code(
      missing_status, "consistency.station_information.missing_status",
    ),
  )
}

///|
test "同类站点 ID 重复及含空格的 ID 被拒绝" {
  let diagnostics = validate_snapshot(
    test_snapshot(
      [
        test_station_information("station-a"),
        test_station_information("station-a"),
      ],
      [test_station_status("station id", 0)],
    ),
  )
  assert_true(test_has_code(diagnostics, "consistency.id.duplicate"))
  assert_true(test_has_code(diagnostics, "consistency.id.contains_space"))
}

///|
test "发现文件声明缺少的端点和未声明的本地端点都被定位" {
  let feeds = test_snapshot([], [])
  feeds["gbfs"] = test_discovery([
    "system_information", "station_information", "station_status", "free_bike_status",
    "system_alerts",
  ])
  feeds["free_bike_status"] = test_envelope({ "bikes": [] })
  feeds["system_hours"] = test_envelope({ "rental_hours": [] })
  let diagnostics = validate_snapshot(feeds)
  assert_true(test_has_code(diagnostics, "consistency.discovery.missing_file"))
  assert_true(
    test_has_code(diagnostics, "consistency.discovery.unadvertised_file"),
  )
}

///|
test "车型文件出现时车辆类型必须存在且 ID 必须可解析" {
  let feeds = test_snapshot([], [
    {
      "station_id": "station-a",
      "num_bikes_available": 1,
      "is_installed": true,
      "is_renting": true,
      "is_returning": true,
      "last_reported": 1450155600,
      "vehicle_types_available": [
        { "vehicle_type_id": "missing-type", "count": 1 },
      ],
    },
  ])
  feeds["gbfs"] = test_discovery([
    "system_information", "station_information", "station_status", "vehicle_types",
  ])
  feeds["vehicle_types"] = test_envelope({
    "vehicle_types": [
      {
        "vehicle_type_id": "bike",
        "form_factor": "bicycle",
        "propulsion_type": "human",
      },
    ],
  })
  let diagnostics = validate_snapshot(feeds)
  assert_true(test_has_code(diagnostics, "consistency.vehicle_type.unknown"))
}

///|
test "车型可用量之和差异属于建议级别而非规范硬错误" {
  let feeds = test_snapshot([test_station_information("station-a")], [
    {
      "station_id": "station-a",
      "num_bikes_available": 3,
      "is_installed": true,
      "is_renting": true,
      "is_returning": true,
      "last_reported": 1450155600,
      "vehicle_types_available": [{ "vehicle_type_id": "bike", "count": 1 }],
    },
  ])
  feeds["gbfs"] = test_discovery([
    "system_information", "station_information", "station_status", "vehicle_types",
  ])
  feeds["vehicle_types"] = test_envelope({
    "vehicle_types": [
      {
        "vehicle_type_id": "bike",
        "form_factor": "bicycle",
        "propulsion_type": "human",
      },
    ],
  })
  let diagnostics = validate_snapshot(feeds)
  let mut mismatch : Diagnostic? = None
  for diagnostic in diagnostics {
    if diagnostic.code == "consistency.bike_count.sum_mismatch" {
      mismatch = Some(diagnostic)
    }
  }
  match mismatch {
    Some(diagnostic) => assert_eq(diagnostic.severity, Warning)
    None =>
      fail(
        "规范 SHOULD 提及的分类数量差异必须发出 warning: " +
        Json::array(diagnostics.map(diagnostic => diagnostic.to_json())).stringify(),
      )
  }
  assert_true(!has_errors(diagnostics))
}

///|
fn test_full_snapshot(
  plan_id : String,
  region_id : String,
  home_id : String,
  range : Bool,
) -> Map[String, String] {
  let feeds = test_snapshot(
    [
      {
        "station_id": "s",
        "name": "测试站点",
        "lat": 31.2,
        "lon": 121.5,
        "region_id": region_id,
        "capacity": 3,
        "vehicle_type_capacity": { "electric": 3 },
      },
    ],
    [
      {
        "station_id": "s",
        "num_bikes_available": 1,
        "num_docks_available": 2,
        "is_installed": true,
        "is_renting": true,
        "is_returning": true,
        "last_reported": 1450155600,
        "vehicle_types_available": [
          { "vehicle_type_id": "electric", "count": 1 },
        ],
        "vehicle_docks_available": [
          { "vehicle_type_ids": ["electric"], "count": 2 },
        ],
      },
    ],
  )
  feeds["gbfs"] = test_discovery([
    "system_information", "station_information", "station_status", "vehicle_types",
    "free_bike_status", "system_pricing_plans", "system_regions", "system_alerts",
  ])
  feeds["vehicle_types"] = test_envelope({
    "vehicle_types": [
      {
        "vehicle_type_id": "electric",
        "form_factor": "bicycle",
        "propulsion_type": "electric_assist",
        "max_range_meters": 50000,
        "default_pricing_plan_id": plan_id,
        "pricing_plan_ids": [plan_id],
      },
    ],
  })
  let bike : Json = if range {
    {
      "bike_id": "test-id",
      "vehicle_type_id": "electric",
      "station_id": "s",
      "home_station_id": home_id,
      "is_reserved": false,
      "is_disabled": false,
      "current_range_meters": 1000,
      "pricing_plan_id": plan_id,
    }
  } else {
    {
      "bike_id": "test-id",
      "vehicle_type_id": "electric",
      "station_id": "s",
      "home_station_id": home_id,
      "is_reserved": false,
      "is_disabled": false,
      "pricing_plan_id": plan_id,
    }
  }
  feeds["free_bike_status"] = test_envelope({ "bikes": [bike] })
  feeds["system_pricing_plans"] = test_envelope({
    "plans": [
      {
        "plan_id": "p",
        "name": "测试价格",
        "currency": "CNY",
        "price": 0,
        "is_taxable": false,
        "description": "测试价格",
      },
    ],
  })
  feeds["system_regions"] = test_envelope({
    "regions": [{ "region_id": "r", "name": "测试区域" }],
  })
  feeds["system_alerts"] = test_envelope({
    "alerts": [
      {
        "alert_id": "a",
        "type": "station_closure",
        "summary": "测试通知",
        "station_ids": [home_id],
        "region_ids": [region_id],
      },
    ],
  })
  feeds
}

///|
test "车辆、价格、区域和告警引用在同一快照中解析" {
  let diagnostics = validate_snapshot(test_full_snapshot("p", "r", "s", true))
  assert_eq(diagnostics.length(), 0)
}

///|
test "未知价格、区域与归还站点报告准确的 JSON Pointer" {
  let diagnostics = validate_snapshot(
    test_full_snapshot("unknown-p", "unknown-r", "unknown-s", false),
  )
  let expected = [
    ("consistency.pricing_plan.unknown", "/data/bikes/0/pricing_plan_id"),
    (
      "consistency.pricing_plan.unknown", "/data/vehicle_types/0/default_pricing_plan_id",
    ),
    (
      "consistency.pricing_plan.unknown", "/data/vehicle_types/0/pricing_plan_ids/0",
    ),
    ("consistency.region.unknown", "/data/stations/0/region_id"),
    ("consistency.region.unknown", "/data/alerts/0/region_ids/0"),
    ("consistency.station.unknown", "/data/bikes/0/home_station_id"),
    ("consistency.station.unknown", "/data/alerts/0/station_ids/0"),
    ("consistency.motor_range.required", "/data/bikes/0/current_range_meters"),
  ]
  for item in expected {
    assert_true(
      diagnostics.any(d => {
        d.code == item.0 && d.pointer == item.1 && d.severity == Error
      }),
    )
  }
}

///|
test "已知有限容量需要车桩数量，容量超额产生警告" {
  let feeds = test_snapshot(
    [
      {
        "station_id": "s",
        "name": "测试站点",
        "lat": 31.2,
        "lon": 121.5,
        "capacity": 1,
      },
    ],
    [test_station_status("s", 2)],
  )
  let diagnostics = validate_snapshot(feeds)
  assert_true(
    diagnostics.any(d => {
      d.code == "consistency.docks_available.required" && d.severity == Error
    }),
  )
  assert_true(
    diagnostics.any(d => {
      d.code == "consistency.station.capacity_exceeded" && d.severity == Warning
    }),
  )
}

///|
test "时间诊断区分 300 秒边界、未来发布时间与长 TTL" {
  let feeds = test_snapshot([test_station_information("s")], [
    test_station_status("s", 0),
  ])
  assert_true(
    !test_has_code(validate_snapshot_at(feeds, 1450155900.0), "timing.stale"),
  )
  assert_true(
    test_has_code(validate_snapshot_at(feeds, 1450155901.0), "timing.stale"),
  )
  assert_true(
    test_has_code(
      validate_snapshot_at(feeds, 1450155599.0),
      "timing.future_update",
    ),
  )
  assert_true(!test_has_code(validate_snapshot(feeds), "timing.stale"))
  feeds["station_status"] = (
    #|{"last_updated":1450155600,"ttl":301,"version":"2.3","data":{"stations":[{"station_id":"s","num_bikes_available":0,"is_installed":true,"is_renting":true,"is_returning":true,"last_reported":1450155601}]}}
  )
  let diagnostics = validate_snapshot(feeds)
  assert_true(test_has_code(diagnostics, "timing.long_cache"))
  assert_true(test_has_code(diagnostics, "timing.report_after_update"))
  assert_true(!has_errors(diagnostics))
}
