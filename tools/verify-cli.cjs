const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..');
const cli = path.resolve(root, process.argv[2] || '_build/js/debug/build/cmd/main/main.js');
const snapshot = path.join(root, 'tests', 'fixtures', 'v2.3', 'snapshot');
const parserFixtures = path.join(root, 'tests', 'fixtures', 'parser');
const v23Fixtures = path.join(root, 'tests', 'fixtures', 'v2.3');

function run(expectedStatus, ...args) {
  const result = spawnSync(process.execPath, [cli, ...args], {
    encoding: 'utf8',
    timeout: 15000,
  });
  if (result.error) throw result.error;
  assert.equal(result.status, expectedStatus, result.stderr || result.stdout);
  return result;
}

assert.match(run(0, '--help').stdout, /用法/);
const directoryReport = JSON.parse(run(0, 'check', snapshot, '--json').stdout);
assert.deepEqual(directoryReport, {
  version: '2.3', errors: 0, warnings: 0, infos: 0, diagnostics: [],
});
const explicitReport = JSON.parse(run(0, 'check',
  path.join(snapshot, 'gbfs.json'),
  path.join(snapshot, 'system_information.json'),
  path.join(snapshot, 'station_information.json'),
  path.join(snapshot, 'station_status.json'), '--json').stdout);
assert.deepEqual(explicitReport, directoryReport);

const parseOnly = JSON.parse(run(0, 'parse', path.join(parserFixtures, 'valid.json'), '--json').stdout);
assert.equal(parseOnly.result, 'syntax_only');
assert.equal(parseOnly.schema_validation, 'not_run');
const badJson = JSON.parse(run(1, 'parse', path.join(parserFixtures, 'invalid.json'), '--json').stdout);
assert.equal(badJson.diagnostics[0].code, 'json.invalid');
assert.equal(badJson.diagnostics[0].file, path.join(parserFixtures, 'invalid.json'));

const wrongVersion = JSON.parse(run(1, 'check',
  path.join(v23Fixtures, 'invalid', 'vehicle_types.json'), '--json').stdout);
assert(wrongVersion.diagnostics.some((issue) =>
  issue.code === 'schema.const' && issue.actual === '3.0' && issue.expected === '2.3'));
const unsupported = JSON.parse(run(1, 'check',
  path.join(v23Fixtures, 'unsupported', 'vehicle_status.json'), '--json').stdout);
assert(unsupported.diagnostics.some((issue) => issue.code === 'feed.unsupported'));
assert.match(run(2, 'check', path.join(root, 'does-not-exist')).stderr, /普通文件或目录/);
assert.match(run(2, 'unexpected').stderr, /命令行参数有误/);

const tempParent = path.resolve(root, 'tests');
const scratch = fs.mkdtempSync(path.join(tempParent, '.tmp-cli-'));
try {
  const badUtf8 = path.join(scratch, 'bad.json');
  fs.writeFileSync(badUtf8, Buffer.from([0xc0, 0xaf]));
  assert.match(run(2, 'parse', badUtf8).stderr, /无效 UTF-8/);
} finally {
  const resolvedScratch = path.resolve(scratch);
  assert.equal(path.dirname(resolvedScratch), tempParent);
  fs.rmSync(resolvedScratch, { recursive: true, force: true });
}

console.log('CLI 集成验证通过：目录、显式文件、JSON 报告、解析错误、版本拒绝、未知端点、UTF-8 与退出码。');
