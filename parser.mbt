///|
/// 已成功解析 JSON、但尚未经过 GBFS Schema 与语义规则验证的数据。
pub struct UntrustedDocument {
  priv file : String
  priv value : Json
}

///|
/// 返回未验证文档的来源路径。
pub fn untrusted_file(document : UntrustedDocument) -> String {
  document.file
}

///|
/// 返回未验证 JSON。调用方不得仅凭解析成功就信任其中的 GBFS 字段。
pub fn untrusted_value(document : UntrustedDocument) -> Json {
  document.value
}

///|
fn parser_diagnostic(
  file : String,
  code : String,
  message : String,
  expected : String,
  suggestion : String,
) -> Diagnostic {
  {
    file,
    pointer: "",
    severity: Error,
    code,
    message,
    actual: None,
    expected: Some(expected),
    suggestion: Some(suggestion),
    source: Some("本工具的离线 JSON 输入安全边界"),
    schema_pointer: None,
  }
}

///|
/// 解析受大小和嵌套深度限制的 JSON，不验证 GBFS 结构。
pub fn parse_json_untrusted(
  file : String,
  source : String,
) -> Result[UntrustedDocument, Diagnostic] {
  parse_json_untrusted_with_limits(file, source, 8 * 1024 * 1024, 64)
}

///|
fn parse_json_untrusted_with_limits(
  file : String,
  source : String,
  max_bytes : Int32,
  max_nesting_depth : Int32,
) -> Result[UntrustedDocument, Diagnostic] {
  let byte_length = @utf8.encode(source).length()
  if byte_length > max_bytes {
    return Err(
      parser_diagnostic(
        file,
        "json.too_large",
        "JSON 输入超过 " + max_bytes.to_string() + " 字节限制",
        "UTF-8 编码后不超过 " + max_bytes.to_string() + " 字节",
        "缩小输入文件后重试",
      ),
    )
  }
  let value = @json.parse(
    source[:],
    max_nesting_depth~,
    reject_duplicate_keys=true,
  ) catch {
    _ =>
      return Err(
        parser_diagnostic(
          file,
          "json.invalid",
          "JSON 语法无效、含有重复对象键或嵌套超过 " +
          max_nesting_depth.to_string() +
          " 层",
          "无重复键且嵌套不超过 " +
          max_nesting_depth.to_string() +
          " 层的合法 JSON",
          "修复 JSON 语法、移除重复键，并降低嵌套深度",
        ),
      )
  }
  Ok({ file, value, })
}
