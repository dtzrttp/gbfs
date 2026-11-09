const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const names = [
  'gbfs', 'gbfs_versions', 'system_information', 'station_information',
  'station_status', 'free_bike_status', 'vehicle_types', 'system_hours',
  'system_alerts', 'system_calendar', 'system_regions',
  'system_pricing_plans', 'geofencing_zones',
];
const body = names.map((name) => {
  const file = path.join(root, 'schemas', 'v2.3', name + '.json');
  const lines = fs.readFileSync(file, 'utf8').trimEnd().split(/\r?\n/);
  return '///|\nlet schema_v23_' + name + ' : String =\n'
    + lines.map((line) => '  #|' + line).join('\n');
});
const output = '// 由官方原始 GBFS v2.3 Schema 文件生成；文件本身保持原样。\n\n'
  + body.join('\n\n') + '\n';
const target = path.join(root, 'schema_sources_v23.mbt');
const namesOutput = '// v2.3 Schema 的兼容别名；实际原始内容位于 schema_sources_v23.mbt。\n\n'
  + names.map((name) => '///|\nlet schema_' + name + ' : String = schema_v23_' + name)
    .join('\n\n') + '\n';
const aliases = path.join(root, 'schema_sources.mbt');
if (process.argv[2] === '--check') {
  if (!fs.existsSync(target)
    || fs.readFileSync(target, 'utf8').replaceAll('\r\n', '\n') !== output) {
    throw new Error('v2.3 嵌入 Schema 与固定上游 JSON 文件不一致');
  }
  if (!fs.existsSync(aliases)
    || fs.readFileSync(aliases, 'utf8').replaceAll('\r\n', '\n') !== namesOutput) {
    throw new Error('Schema 兼容别名与固定端点清单不一致');
  }
} else {
  fs.writeFileSync(target, output);
  fs.writeFileSync(aliases, namesOutput);
}
