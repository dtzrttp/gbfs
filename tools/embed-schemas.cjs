const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const names = [
  'gbfs', 'system_information', 'station_information', 'station_status',
  'vehicle_types', 'vehicle_status',
];
const body = names.map((name) => {
  const file = path.join(root, 'schemas', 'v3.0', name + '.json');
  const lines = fs.readFileSync(file, 'utf8').trimEnd().split(/\r?\n/);
  return '///|\nlet schema_' + name + ' : String =\n'
    + lines.map((line) => '  #|' + line.trimEnd()).join('\n');
});
const output = '// 由 tools/embed-schemas.cjs 从原始 GBFS 3.0 Schema 生成。\n\n'
  + body.join('\n\n') + '\n';
const target = path.join(root, 'schema_sources.mbt');
if (process.argv[2] === '--check') {
  if (fs.readFileSync(target, 'utf8').replaceAll('\r\n', '\n') !== output) {
    throw new Error('内嵌 Schema 与原始文件不一致');
  }
} else {
  fs.writeFileSync(target, output);
}
