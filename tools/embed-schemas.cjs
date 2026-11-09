const { spawnSync } = require('node:child_process');
const path = require('node:path');

const script = path.join(__dirname, 'embed-v23-schemas.cjs');
const result = spawnSync(process.execPath, [script, ...process.argv.slice(2)], {
  stdio: 'inherit',
});
if (result.error) throw result.error;
process.exitCode = result.status ?? 1;
