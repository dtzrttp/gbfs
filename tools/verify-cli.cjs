const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..');
const cli = path.resolve(root, process.argv[2] || '_build/js/debug/build/cmd/main/main.js');
const examples = path.join(root, 'examples', 'valid');
const official = path.join(root, 'tests', 'official');

function run(expected, ...args) {
  const result = spawnSync(process.execPath, [cli, ...args], {
    encoding: 'utf8',
    timeout: 15000,
  });
  if (result.error) throw result.error;
  assert.equal(result.status, expected, result.stderr || result.stdout);
  return result;
}

assert.match(run(0, '--help').stdout, /用法/);
assert.match(run(2, 'file', 'typo', path.join(examples, 'station_status.json')).stderr, /未支持的端点/);
assert.match(run(0, 'check', examples).stdout, /0 个错误/);
const valid = JSON.parse(run(0, 'check', examples, '--json').stdout);
assert.deepEqual(valid, { version: '3.0', errors: 0, warnings: 0, diagnostics: [] });
const mismatched = path.join(official, 'gbfs-1.json');
const wrongEndpoint = JSON.parse(run(1, 'file', 'station_status', mismatched, '--json').stdout);
assert(wrongEndpoint.diagnostics.every((issue) => issue.file === mismatched));

const files = fs.readdirSync(official).filter((name) => name.endsWith('.json')).sort();
assert.equal(files.length, 8);
for (const file of files) {
  const endpoint = file.replace(/-\d+\.json$/, '');
  const expected = file === 'gbfs-1.json' ? 1 : 0;
  const result = JSON.parse(run(expected, 'file', endpoint, path.join(official, file), '--json').stdout);
  if (expected === 1) {
    assert.deepEqual(result.diagnostics.map((issue) => issue.code), ['schema.anyOf', 'schema.contains']);
    assert(result.diagnostics.every((issue) => typeof issue.schema_pointer === 'string'));
  } else {
    assert.equal(result.errors, 0);
  }
  console.log('规范示例', file, '退出码', expected);
}

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'gbfs-cli-'));
const fixtureNames = fs.readdirSync(examples).filter((name) => name.endsWith('.json'));
try {
  for (const file of fixtureNames) fs.copyFileSync(path.join(examples, file), path.join(scratch, file));
  const stationFile = path.join(scratch, 'station_status.json');
  const station = JSON.parse(fs.readFileSync(stationFile, 'utf8'));
  station.data.stations[0].vehicle_types_available[0].count = 1;
  fs.writeFileSync(stationFile, JSON.stringify(station));
  const warning = JSON.parse(run(0, 'check', scratch, '--json').stdout);
  assert.equal(warning.errors, 0);
  assert.equal(warning.warnings, 1);
  assert.equal(warning.diagnostics[0].code, 'count.vehicle_total');
  assert.equal(warning.diagnostics[0].schema_pointer, null);
  station.data.stations[0].station_id = 'missing-station';
  fs.writeFileSync(stationFile, JSON.stringify(station));
  const invalid = JSON.parse(run(1, 'check', scratch, '--json').stdout);
  assert.deepEqual(invalid.diagnostics.filter((issue) => issue.severity === 'error').map((issue) => issue.code),
    ['station.missing_status', 'station.missing_information']);
  assert.match(run(2, 'check', path.join(scratch, 'missing')).stderr, /无法读取目录/);
  fs.writeFileSync(stationFile, Buffer.from([0xc0, 0xaf]));
  assert.match(run(2, 'file', 'station_status', stationFile).stderr, /无效 UTF-8/);
  assert.match(run(2, 'unexpected').stderr, /命令行参数有误/);
} finally {
  for (const file of fixtureNames) fs.rmSync(path.join(scratch, file), { force: true });
  fs.rmdirSync(scratch);
}
console.log('CLI 回归通过。8 个原始示例，7 个接受、1 个按固定 Schema 预期拒绝。退出码 0、1、2 均已覆盖。');
