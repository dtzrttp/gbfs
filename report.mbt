///|
fn diagnostic_precedes(left : Diagnostic, right : Diagnostic) -> Bool {
  if left.file != right.file {
    left.file < right.file
  } else if left.pointer != right.pointer {
    left.pointer < right.pointer
  } else if left.code != right.code {
    left.code < right.code
  } else if left.message != right.message {
    left.message < right.message
  } else {
    match (left.actual, right.actual) {
      (Some(a), Some(b)) => a < b
      (Some(_), None) => true
      (None, Some(_)) => false
      (None, None) => false
    }
  }
}

///|
/// 以固定字段顺序排序诊断，避免结果依赖输入容器的迭代顺序。
pub fn sort_diagnostics(diagnostics : Array[Diagnostic]) -> Array[Diagnostic] {
  let mut sorted = diagnostics.copy()
  let length = sorted.length()
  let mut width = 1
  while width < length {
    let next = sorted.copy()
    let mut start = 0
    while start < length {
      let middle = if start + width < length { start + width } else { length }
      let double_width = width + width
      let end = if start + double_width < length {
        start + double_width
      } else {
        length
      }
      let mut left = start
      let mut right = middle
      let mut output = start
      while output < end {
        if left < middle &&
          (right >= end || !diagnostic_precedes(sorted[right], sorted[left])) {
          next[output] = sorted[left]
          left += 1
        } else {
          next[output] = sorted[right]
          right += 1
        }
        output += 1
      }
      start = end
    }
    sorted = next
    width += width
  }
  sorted
}

///|
fn truncated_diagnostics(count : Int32, limit : Int32) -> Diagnostic {
  {
    file: "<snapshot>",
    pointer: "",
    severity: Error,
    code: "report.truncated",
    message: "达到诊断输出上限，报告不完整",
    actual: Some(count.to_string()),
    expected: Some("最多输出 " + limit.to_string() + " 条诊断"),
    suggestion: Some("缩小输入范围或分批检查文件后重试"),
    source: Some("本工具的诊断资源上限"),
    schema_pointer: None,
  }
}

///|
/// 确保诊断数量有上限；发生截断时添加错误诊断，避免不完整报告误判为通过。
fn limit_diagnostics(
  diagnostics : Array[Diagnostic],
  max_diagnostics : Int32,
) -> Array[Diagnostic] {
  let limit = if max_diagnostics < 1 { 1 } else { max_diagnostics }
  let sorted = sort_diagnostics(diagnostics)
  if sorted.length() <= limit {
    sorted
  } else {
    let limited = []
    for i in 0..<(limit - 1) {
      limited.push(sorted[i])
    }
    limited.push(truncated_diagnostics(sorted.length(), limit))
    limited
  }
}
