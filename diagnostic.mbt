///|
/// GBFS 强制规则和建议规则分别报告。
pub(all) enum Severity {
  Error
  Warning
  Info
} derive(Eq, Debug)

///|
pub extend Severity with Eq::{equal, not_equal}

///|
pub extend Severity with Debug::{to_repr}

///|
/// pointer 是 RFC 6901 JSON Pointer，空字符串指向根。
pub(all) struct Diagnostic {
  file : String
  pointer : String
  severity : Severity
  code : String
  message : String
  actual : String?
  expected : String?
  suggestion : String?
  source : String?
  schema_pointer : String?
} derive(Debug)

///|
pub extend Diagnostic with Debug::{to_repr}

///|
pub fn Diagnostic::to_json(self : Diagnostic) -> Json {
  let severity : String = match self.severity {
    Error => "error"
    Warning => "warning"
    Info => "info"
  }
  let schema_pointer : Json = match self.schema_pointer {
    Some(path) => Json::string(path)
    None => Json::null()
  }
  let actual : Json = match self.actual {
    Some(value) => Json::string(value)
    None => Json::null()
  }
  let expected : Json = match self.expected {
    Some(value) => Json::string(value)
    None => Json::null()
  }
  let suggestion : Json = match self.suggestion {
    Some(value) => Json::string(value)
    None => Json::null()
  }
  let source : Json = match self.source {
    Some(value) => Json::string(value)
    None => Json::null()
  }
  {
    "file": self.file,
    "pointer": self.pointer,
    "severity": severity,
    "code": self.code,
    "message": self.message,
    "actual": actual,
    "expected": expected,
    "suggestion": suggestion,
    "source": source,
    "schema_pointer": schema_pointer,
  }
}

///|
pub fn has_errors(issues : Array[Diagnostic]) -> Bool {
  issues.any(issue => issue.severity == Error)
}

///|
fn issue(
  feed : String,
  pointer : String,
  code : String,
  message : String,
  severity~ : Severity = Error,
  actual? : String,
  expected? : String,
  suggestion? : String,
  source? : String,
  schema_pointer? : String,
) -> Diagnostic {
  {
    file: feed + ".json",
    pointer,
    severity,
    code,
    message,
    actual,
    expected,
    suggestion,
    source,
    schema_pointer,
  }
}
