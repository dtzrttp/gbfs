const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const Ajv = require('ajv');
const addFormats = require('ajv-formats');

const root = path.resolve(__dirname, '../..');
const cli = path.resolve(root, process.argv[2] || '_build/js/debug/build/cmd/main/main.js');
const fixture = require('../../tests/fixtures/v2.3/schema-cases.json');
const ajv = new Ajv({ allErrors: true, strict: false });
addFormats(ajv);
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'gbfs-schema-'));
const results = [];

function compare(id, feed, input, expected, expectedMoonBit = expected) {
  const reference = ajv.compile(require(`../../schemas/v2.3/${feed}.json`));
  const referenceValid = reference(input);
  const file = path.join(scratch, `${feed}.json`);
  fs.writeFileSync(file, JSON.stringify(input));
  const actual = spawnSync(process.execPath, [cli, 'file', file, '--json'], {
    encoding: 'utf8', timeout: 15000,
  });
  if (actual.error) throw actual.error;
  assert([0, 1].includes(actual.status), actual.stderr || actual.stdout);
  const report = JSON.parse(actual.stdout);
  assert.equal(report.errors === 0, actual.status === 0);
  results.push({
    id, feed, expected, expectedMoonBit,
    reference: referenceValid, moonbit: actual.status === 0,
    referenceRules: (reference.errors ?? []).map(error => [error.instancePath, error.keyword]),
    moonbitRules: report.diagnostics.map(issue => [issue.pointer, issue.code]),
  });
}

function envelope(feed) {
  return { last_updated: 1700000000, ttl: 0, version: '2.3', data: structuredClone(fixture.data[feed]) };
}

try {
  for (const feed of Object.keys(fixture.data)) {
    compare('valid.' + feed, feed, envelope(feed), true);
    for (const field of ['last_updated', 'ttl', 'version', 'data']) {
      const input = envelope(feed);
      delete input[field];
      compare(`required.${feed}.${field}`, feed, input, false);
    }
  }
  for (const [id, feed, pointer, value, operation, expectedMoonBit] of fixture.mutations) {
    const input = envelope(feed);
    const parent = pointer.slice(0, -1).reduce((object, segment) => object[segment], input);
    const key = pointer.at(-1);
    if (operation === 'delete') {
      if (Array.isArray(parent)) parent.splice(key, 1);
      else delete parent[key];
    } else {
      parent[key] = value;
    }
    compare(id, feed, input, false, expectedMoonBit);
  }
  const mismatches = results.filter(row => row.reference !== row.moonbit);
  const unexpected = results.filter(row =>
    row.expected !== row.reference || row.expectedMoonBit !== row.moonbit);
  console.log(JSON.stringify({
    schemaCommit: '01d4cb480410ca234b1d76799daf474b8f839e85',
    engine: `Ajv ${require('ajv/package.json').version} + ajv-formats ${require('ajv-formats/package.json').version}`,
    total: results.length, agreements: results.length - mismatches.length,
    differences: mismatches.map(row => row.id),
    unexpected: unexpected.map(row => row.id), results,
  }, null, 2));
  if (unexpected.length) process.exitCode = 1;
} finally {
  assert.equal(path.dirname(path.resolve(scratch)), path.resolve(os.tmpdir()));
  assert(path.basename(scratch).startsWith('gbfs-schema-'));
  for (const name of fs.readdirSync(scratch)) fs.unlinkSync(path.join(scratch, name));
  fs.rmdirSync(scratch);
}
