// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Toshiki Matsukuma

const { test } = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

test('package.json has required fields', () => {
  const packageJson = require('../package.json');

  assert.strictEqual(packageJson.name, 'career-pipeline-mcp');
  assert.strictEqual(packageJson.license, 'MIT');
  assert.ok(packageJson.version);
  assert.ok(packageJson.description);
  assert.ok(packageJson.author);
  assert.ok(packageJson.repository);
});

test('server.js file exists', () => {
  const serverPath = path.join(__dirname, '..', 'server.js');
  assert.ok(fs.existsSync(serverPath), 'server.js should exist');
});

test('server.js has SPDX header', () => {
  const serverPath = path.join(__dirname, '..', 'server.js');
  const content = fs.readFileSync(serverPath, 'utf-8');

  assert.ok(content.includes('SPDX-License-Identifier: MIT'), 'Should have MIT SPDX header');
  assert.ok(content.includes('Copyright (c) 2026'), 'Should have copyright notice');
});

test('README.md exists', () => {
  const readmePath = path.join(__dirname, '..', 'README.md');
  assert.ok(fs.existsSync(readmePath), 'README.md should exist');
});

test('dependencies are declared', () => {
  const packageJson = require('../package.json');

  assert.ok(packageJson.dependencies['@modelcontextprotocol/sdk'], 'Should have MCP SDK');
  assert.ok(packageJson.dependencies['better-sqlite3'], 'Should have better-sqlite3');
});

test('files array excludes test files', () => {
  const packageJson = require('../package.json');

  assert.ok(Array.isArray(packageJson.files), 'Should have files array');
  assert.ok(packageJson.files.includes('server.js'), 'Should include server.js');
  assert.ok(packageJson.files.includes('README.md'), 'Should include README.md');
  assert.ok(!packageJson.files.some(f => f.includes('test')), 'Should not include test files');
});
