const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const cli = path.resolve(root, process.argv[2] || '_build/js/debug/build/cmd/main/main.js');
const fixtures = path.join(root, 'tests/fixtures/v2.3/snapshot');
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'gbfs-mutation-'));
const files = fs.readdirSync(fixtures).sort().map(name => path.join(scratch, name));
const status = path.join(scratch, 'station_status.json');
const original = JSON.parse(fs.readFileSync(path.join(fixtures, 'station_status.json'), 'utf8'));

function validate(files, expectedStatus) {
  const run = spawnSync(process.execPath, [cli, 'check', ...files, '--json'], {
    encoding: 'utf8', timeout: 15000,
  });
  if (run.error) throw run.error;
  assert.equal(run.status, expectedStatus, run.stderr || run.stdout);
  return JSON.parse(run.stdout);
}

const seed = 0x6b6673;
let state = seed;
function random() {
  state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
  return state;
}

try {
  for (const file of files) fs.copyFileSync(path.join(fixtures, path.basename(file)), file);
  assert.equal(validate(files, 0).errors, 0);
  const required = ['station_id', 'num_bikes_available', 'is_installed', 'is_renting', 'is_returning', 'last_reported'];
  const cases = 30;
  const counts = { deletion: 0, type: 0, reference: 0 };
  for (let i = 0; i < cases; i++) {
    const input = structuredClone(original);
    const row = input.data.stations[0];
    const field = required[(random() >>> 16) % required.length];
    const code = ['schema.required', 'schema.type', 'consistency.station_status.unknown_station'][i % 3];
    switch (i % 3) {
      case 0:
        delete row[field];
        counts.deletion++;
        break;
      case 1:
        row[field] = { invalid: random() };
        counts.type++;
        break;
      case 2:
        row.station_id = 'unknown-' + random().toString(16);
        counts.reference++;
        break;
    }
    fs.writeFileSync(status, JSON.stringify(input));
    const report = validate(files, 1);
    const pointer = '/data/stations/0/' + (i % 3 === 2 ? 'station_id' : field);
    assert(report.diagnostics.some(issue =>
      issue.code === code && issue.pointer === pointer && issue.file === status),
    JSON.stringify({ i, code, pointer, report }));
    assert.deepEqual(validate([...files].reverse(), 1), report);
  }
  console.log(JSON.stringify({ seed, cases, passed: cases, counts, inputOrders: 2 }));
} finally {
  assert.equal(path.dirname(path.resolve(scratch)), path.resolve(os.tmpdir()));
  assert(path.basename(scratch).startsWith('gbfs-mutation-'));
  for (const name of fs.readdirSync(scratch)) fs.unlinkSync(path.join(scratch, name));
  fs.rmdirSync(scratch);
}
