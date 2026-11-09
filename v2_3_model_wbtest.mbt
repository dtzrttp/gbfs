///|
fn v23_document(data : Json) -> String {
  let value : Json = {
    "last_updated": 1450155600,
    "ttl": 0,
    "version": "2.3",
    "data": data,
  }
  value.stringify()
}

///|
test "版本发现文件要求按主版本和次版本严格递增" {
  fn listing(a : String, b : String) -> String {
    v23_document({
      "versions": [
        { "version": a, "url": "https://example.org/older" },
        { "version": b, "url": "https://example.org/newer" },
      ],
    })
  }
  assert_eq(validate_file("gbfs_versions", listing("2.3", "3.0")).length(), 0)
  for source in [listing("3.0", "2.3"), listing("2.3", "2.3")] {
    let diagnostics = validate_file("gbfs_versions", source)
    assert_eq(diagnostics.length(), 1)
    assert_eq(diagnostics[0].code, "version.not_increasing")
    assert_eq(diagnostics[0].pointer, "/data/versions/1/version")
  }
}

///|
test "v2.3 公开端点清单包含全部十三个固定文件" {
  assert_eq(gbfs_version(), "2.3")
  assert_eq(supported_feeds(), [
    "gbfs", "gbfs_versions", "system_information", "station_information", "station_status",
    "free_bike_status", "vehicle_types", "system_hours", "system_alerts", "system_calendar",
    "system_regions", "system_pricing_plans", "geofencing_zones",
  ])
}

///|
test "诊断 JSON 含可定位和可修复所需的字段" {
  let output = issue("gbfs", "/version", "schema.const", "版本必须为 2.3").to_json()
  guard output is Object(fields) else { fail("报告项应为 JSON 对象") }
  assert_true(fields.contains("actual"))
  assert_true(fields.contains("expected"))
  assert_true(fields.contains("suggestion"))
  assert_true(fields.contains("source"))
}

///|
test "JSON 解析结果显式保持未验证状态并保留输入路径" {
  match
    parse_json_untrusted(
      "snapshot/system_information.json", "{\"version\":\"2.3\"}",
    ) {
    Ok(document) => {
      assert_eq(untrusted_file(document), "snapshot/system_information.json")
      assert_true(untrusted_value(document) is Object(_))
    }
    Err(diagnostic) =>
      fail("合法 JSON 不应解析失败：" + diagnostic.message)
  }
}

///|
test "JSON 解析拒绝重复键并保留原文件路径和稳定错误码" {
  match parse_json_untrusted("snapshot/gbfs.json", "{\"data\":1,\"data\":2}") {
    Ok(_) => fail("重复 JSON 键必须被拒绝")
    Err(diagnostic) => {
      assert_eq(diagnostic.file, "snapshot/gbfs.json")
      assert_eq(diagnostic.code, "json.invalid")
      assert_eq(diagnostic.severity, Error)
    }
  }
}

///|
test "诊断按文件、JSON Pointer 和错误码稳定排序" {
  let sorted = sort_diagnostics([
    issue("station_status", "/data/stations/0", "z.code", "Z"),
    issue("gbfs", "/version", "version.invalid", "版本错误"),
    issue("gbfs", "/data", "data.invalid", "数据错误"),
  ])
  assert_eq(sorted[0].file, "gbfs.json")
  assert_eq(sorted[0].pointer, "/data")
  assert_eq(sorted[1].pointer, "/version")
  assert_eq(sorted[2].file, "station_status.json")
}

///|
test "辅助信息级别不会被误计为错误" {
  let diagnostic = issue(
    "gbfs",
    "",
    "input.info",
    "正在按 GBFS v2.3 处理",
    severity=Info,
  )
  assert_true(!has_errors([diagnostic]))
  assert_true(
    diagnostic.to_json().stringify().contains("\"severity\":\"info\""),
  )
}

///|
test "解析器按 UTF-8 字节数和嵌套层数执行边界限制" {
  let unicode_result = parse_json_untrusted_with_limits(
    "unicode.json", "{\"é\":1}", 7, 64,
  )
  match unicode_result {
    Ok(_) => fail("超出 UTF-8 字节数上限的输入应被拒绝")
    Err(diagnostic) => assert_eq(diagnostic.code, "json.too_large")
  }
  let depth_result = parse_json_untrusted_with_limits(
    "deep.json", "[[[0]]]", 32, 2,
  )
  match depth_result {
    Ok(_) => fail("超出嵌套层数上限的输入应被拒绝")
    Err(diagnostic) => assert_eq(diagnostic.code, "json.invalid")
  }
}

///|
test "v2.3 单文件 Schema 接受 Unix 时间戳与固定版本" {
  let source = "{\"last_updated\":1450155600,\"ttl\":0,\"version\":\"2.3\",\"data\":{\"vehicle_types\":[]}}"
  assert_eq(validate_file("vehicle_types", source).length(), 0)
}

///|
test "Schema 诊断带实际值、期望值、修复建议和固定来源" {
  let source = "{\"last_updated\":1450155600,\"ttl\":0,\"version\":\"3.0\",\"data\":{\"vehicle_types\":[]}}"
  let diagnostics = validate_file("vehicle_types", source)
  let version_faults = diagnostics.filter(d => d.pointer == "/version")
  guard version_faults.length() > 0 else {
    fail("错误版本必须定位到 version 字段")
  }
  let diagnostic = version_faults[0]
  assert_eq(diagnostic.actual, Some("3.0"))
  assert_eq(diagnostic.expected, Some("2.3"))
  assert_true(diagnostic.suggestion is Some(_))
  assert_true(diagnostic.source is Some(source) && source.contains("v2.3"))
}

///|
test "快照验证返回固定版本的必需入口文件缺失诊断" {
  let diagnostics = validate_snapshot(Map([]))
  assert_eq(diagnostics.length(), 2)
  assert_eq(diagnostics[0].code, "feed.missing")
  assert_eq(diagnostics[0].file, "gbfs.json")
  assert_eq(diagnostics[1].file, "system_information.json")
}

///|
test "快照 UTF-8 总字节数超限时不进入 Schema 验证" {
  let feeds : Map[String, String] = { "gbfs": "{\"é\":1}" }
  let diagnostics = validate_snapshot_with_limits(feeds, 1)
  assert_eq(diagnostics.length(), 1)
  assert_eq(diagnostics[0].code, "input.total_too_large")
}

///|
test "过多诊断被截断且以错误标记报告不完整结果" {
  let limited = limit_diagnostics(
    [
      issue("a", "/one", "one", "one"),
      issue("b", "/two", "two", "two"),
      issue("c", "/three", "three", "three"),
    ],
    2,
  )
  assert_eq(limited.length(), 2)
  assert_eq(limited[1].code, "report.truncated")
  assert_eq(limited[1].severity, Error)
}

///|
test "全部十三个官方 v2.3 Schema 接受最小合法结构" {
  let files : Map[String, String] = {
    "gbfs": v23_document({
      "en": {
        "feeds": [
          {
            "name": "system_information",
            "url": "https://example.org/system_information",
          },
          {
            "name": "station_status",
            "url": "https://example.org/station_status",
          },
        ],
      },
    }),
    "gbfs_versions": v23_document({ "versions": [] }),
    "system_information": v23_document({
      "system_id": "demo",
      "language": "en",
      "name": "Demo",
      "timezone": "Asia/Shanghai",
    }),
    "station_information": v23_document({ "stations": [] }),
    "station_status": v23_document({ "stations": [] }),
    "free_bike_status": v23_document({ "bikes": [] }),
    "vehicle_types": v23_document({ "vehicle_types": [] }),
    "system_hours": v23_document({ "rental_hours": [] }),
    "system_alerts": v23_document({ "alerts": [] }),
    "system_calendar": v23_document({ "calendars": [] }),
    "system_regions": v23_document({ "regions": [] }),
    "system_pricing_plans": v23_document({ "plans": [] }),
    "geofencing_zones": v23_document({
      "geofencing_zones": { "type": "FeatureCollection", "features": [] },
    }),
  }
  for feed, source in files {
    let diagnostics = validate_file(feed, source)
    if diagnostics.length() > 0 {
      fail(feed + " 的最小 v2.3 JSON 应通过 Schema")
    }
  }
}

///|
test "v2.3 Schema 拒绝越界坐标并报告实际值与 JSON 路径" {
  let source = v23_document({
    "stations": [
      { "station_id": "s1", "name": "Center", "lat": 91, "lon": 121.4 },
    ],
  })
  let diagnostics = validate_file("station_information", source)
  let faults = diagnostics.filter(d => {
    d.code == "schema.maximum" && d.pointer == "/data/stations/0/lat"
  })
  assert_eq(faults.length(), 1)
  assert_eq(faults[0].actual, Some("91"))
}

///|
test "v2.3 Schema 拒绝未定义的车辆形式枚举" {
  let source = v23_document({
    "vehicle_types": [
      {
        "vehicle_type_id": "type1",
        "form_factor": "hoverboard",
        "propulsion_type": "human",
      },
    ],
  })
  let diagnostics = validate_file("vehicle_types", source)
  assert_true(
    diagnostics.any(d => {
      d.code == "schema.enum" &&
      d.pointer == "/data/vehicle_types/0/form_factor"
    }),
  )
}

///|
test "v3.0 vehicle_status 不会被误认为 v2.3 支持端点" {
  let diagnostics = validate_file("vehicle_status", "{}")
  assert_eq(diagnostics.length(), 1)
  assert_eq(diagnostics[0].code, "feed.unsupported")
}
