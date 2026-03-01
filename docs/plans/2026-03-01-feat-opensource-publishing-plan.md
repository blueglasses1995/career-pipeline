---
title: Publish career-pipeline MCP Plugin as Open Source
type: feat
date: 2026-03-01
enhanced: 2026-03-01
---

# Publish career-pipeline MCP Plugin as Open Source

## Enhancement Summary

**Deepened on:** 2026-03-01
**Sections enhanced:** 2 (Phase 4: GitHub Templates & Automation, Phase 5: Testing Infrastructure)
**Research agents used:** MCP Testing Strategy Researcher, GitHub Actions 2026 Patterns Researcher

### Key Improvements

1. **Modern Testing Stack (Phase 5)**
   - Replaced Mocha with Node.js Native Test Runner (`node:test`) - zero dependencies
   - Added c8 for coverage (native V8 coverage, faster than nyc)
   - Implemented in-memory SQLite testing pattern with TestDatabase helper
   - Added MCP protocol compliance testing examples
   - Defined realistic coverage targets (75-80% industry standard)
   - Included SQL injection prevention test suite
   - Added security testing checklist

2. **Cutting-Edge GitHub Actions (Phase 4)**
   - Upgraded to npm OIDC Trusted Publishing (eliminates npm tokens)
   - Added automatic provenance attestations (SLSA compliance)
   - Implemented concurrency groups for cost optimization (10%+ savings)
   - Updated Node.js matrix to 2026 LTS versions (20, 22, 24)
   - Added Dependabot with EPSS risk scoring
   - Included CodeQL security scanning workflow
   - Added SBOM generation for supply chain transparency
   - Optimized caching with actions/setup-node@v4 built-in caching

3. **Production-Ready Workflows**
   - Complete CI workflow with lint, test matrix, and package validation
   - Complete publish workflow with OIDC, provenance, and SBOM
   - Complete security workflow with CodeQL and npm audit
   - Comprehensive Dependabot configuration

### New Considerations Discovered

**Testing:**
- Node.js Test Runner is now the gold standard for backend projects (2026)
- In-memory SQLite provides 80%+ speed improvement over file-based testing
- MCP protocol compliance testing is essential for MCP servers
- Security testing (SQL injection) is critical before open source release

**GitHub Actions:**
- npm OIDC Trusted Publishing is now GA (July 2025) - no more npm tokens!
- Automatic provenance generation with Node.js ≥ 22.14.0 and npm ≥ 11.5.1
- EPSS (Exploit Prediction Scoring System) in Dependabot predicts exploitation likelihood
- Concurrency groups reduce CI costs by 10%+
- Action allowlisting is available across all GitHub plans (2026)

**Performance Impact:**
- Testing: < 30 seconds total in CI (with parallel execution)
- Caching: Up to 80% build time reduction with actions/setup-node@v4
- Matrix jobs run in parallel (3 Node versions = same time as 1)

**Security Enhancements:**
- Zero long-lived secrets (OIDC eliminates npm tokens)
- Automatic SLSA compliance via provenance
- Supply chain transparency via SBOM
- Vulnerability prioritization via EPSS scoring

---

## Overview

Prepare and publish the career-pipeline MCP plugin as a high-quality open source project with proper documentation, licensing, and distribution infrastructure. The project is technically solid (80% ready) but needs legal, governance, and community files before public release.

**Current Status:**
- ✅ Excellent README (212 lines)
- ✅ Working MCP server (5 tools, 356 lines)
- ✅ GitHub repository with clean history
- ✅ Marketplace integration ready
- ❌ Missing LICENSE file (critical)
- ❌ License inconsistency (MIT vs ISC)
- ❌ Missing community health files
- ❌ No testing infrastructure
- ❌ Incomplete package.json metadata

## Problem Statement

The career-pipeline MCP plugin provides valuable functionality for career management but cannot be safely published as open source without:

1. **Legal clarity** - No LICENSE file, conflicting license declarations
2. **Community infrastructure** - Missing CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md
3. **Quality assurance** - Zero tests, no CI/CD
4. **Distribution metadata** - Incomplete package.json (missing repository, keywords, author)
5. **Risk of data leaks** - No .npmignore to prevent publishing database files

**Impact:** Cannot legally accept contributions, risk publishing personal data to npm, project appears unprofessional.

## Proposed Solution

Implement industry-standard open source project structure following 2026 best practices, organized into 6 phases with clear dependencies.

## Technical Approach

### Phase 1: Legal Foundation (CRITICAL - Do First)

**Goal:** Establish clear, consistent licensing before any public release.

**Tasks:**

1. **Create LICENSE file**
   - File: `/Users/toshikimatsukuma/Documents/career-pipeline/LICENSE`
   - Content: Standard MIT License template
   - Copyright: `Copyright (c) 2026 Toshiki Matsukuma`
   - Reference: https://choosealicense.com/licenses/mit/

2. **Fix license inconsistency**
   - Update `mcp/package.json:11` from `"license": "ISC"` to `"license": "MIT"`
   - Verify `.claude-plugin/plugin.json:9` shows `"license": "MIT"` (already correct)
   - Verify `README.md:211` shows `MIT` (already correct)

3. **Add SPDX headers to source files**
   - Add to top of `mcp/server.js`:
     ```javascript
     // SPDX-License-Identifier: MIT
     // Copyright (c) 2026 Toshiki Matsukuma
     ```

**Validation:**
```bash
# All license declarations must match
grep -r "MIT" LICENSE README.md .claude-plugin/plugin.json mcp/package.json
# All should return "MIT", no "ISC"
```

**Blockers:** None - must complete before ANY other work

---

### Phase 2: Package Metadata (Before Publishing)

**Goal:** Complete package.json with all metadata for npm discoverability and GitHub integration.

**Current Issues in `mcp/package.json`:**
- `"keywords": []` - Empty (hurts npm search)
- `"author": ""` - Empty
- Missing: `repository`, `bugs`, `homepage`, `engines`, `files`

**Tasks:**

1. **Update mcp/package.json**

   Add/update these fields:

   ```json
   {
     "keywords": [
       "mcp",
       "model-context-protocol",
       "career",
       "job-search",
       "sqlite",
       "ai-assistant",
       "claude",
       "database",
       "career-management"
     ],
     "author": "Toshiki Matsukuma <your.email@example.com>",
     "repository": {
       "type": "git",
       "url": "https://github.com/blueglasses1995/career-pipeline.git",
       "directory": "mcp"
     },
     "bugs": {
       "url": "https://github.com/blueglasses1995/career-pipeline/issues"
     },
     "homepage": "https://github.com/blueglasses1995/career-pipeline#readme",
     "engines": {
       "node": ">=18.0.0"
     },
     "files": [
       "server.js",
       "README.md",
       "LICENSE"
     ]
   }
   ```

2. **Create .npmignore**

   File: `mcp/.npmignore`

   ```
   # Development files
   .git
   .github
   *.db
   *.db-wal
   *.db-shm
   node_modules
   test
   .DS_Store
   ```

**Validation:**
```bash
cd mcp
npm pack --dry-run
tar -tzf career-pipeline-mcp-*.tgz | grep -v node_modules
# Should only show: package.json, server.js, README.md, LICENSE
# Should NOT show: .db files, .git, .github
```

**Dependencies:** Phase 1 (license field must be correct)

---

### Phase 3: Community Documentation (Parallel to Phase 2)

**Goal:** Provide standard community health files for contributors.

**Tasks:**

1. **Create CONTRIBUTING.md**

   File: `/Users/toshikimatsukuma/Documents/career-pipeline/CONTRIBUTING.md`

   Structure:
   - Getting Started (fork, clone, install)
   - Development Workflow (branch naming, commit messages)
   - Code Standards (existing style patterns)
   - Testing Requirements
   - Pull Request Process
   - Questions/Support channels

   Reference: https://opensource.guide/starting-a-project/

2. **Create CODE_OF_CONDUCT.md**

   File: `/Users/toshikimatsukuma/Documents/career-pipeline/CODE_OF_CONDUCT.md`

   Use: Contributor Covenant 2.1 (industry standard)

   Template: https://www.contributor-covenant.org/version/2/1/code_of_conduct/

3. **Create SECURITY.md**

   File: `/Users/toshikimatsukuma/Documents/career-pipeline/SECURITY.md`

   Sections:
   - Supported Versions (current: 1.x.x)
   - Reporting a Vulnerability (email + GitHub Security Advisories)
   - Response Timeline (48hr acknowledgment, 5-day confirmation)
   - Disclosure Policy (coordinated disclosure)
   - Safe Harbor statement

   Reference: https://www.cisa.gov/vulnerability-disclosure-policy-template

4. **Create CHANGELOG.md**

   File: `/Users/toshikimatsukuma/Documents/career-pipeline/CHANGELOG.md`

   Format: Keep a Changelog (https://keepachangelog.com/)

   Initial entry:
   ```markdown
   # Changelog

   All notable changes to this project will be documented in this file.

   The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
   and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

   ## [1.0.0] - 2026-03-01

   ### Added
   - Initial open source release
   - `career_read` tool for SELECT queries
   - `career_write` tool for INSERT/UPDATE/DELETE
   - `career_search` tool for full-text search
   - `career_stats` tool for database statistics
   - `career_dump` tool for SQL export

   ### Security
   - Query validation to prevent DROP/ALTER/CREATE statements
   - Read/write operation separation
   ```

5. **Create MCP-specific README**

   File: `/Users/toshikimatsukuma/Documents/career-pipeline/mcp/README.md`

   Sections:
   - MCP Server Architecture
   - Tool Descriptions (all 5 tools with examples)
   - Development/Testing Instructions
   - Configuration Options (CAREER_PIPELINE_DATA_DIR)
   - Troubleshooting

**Dependencies:** Phase 1 (license must be clear for contributors)

---

### Phase 4: GitHub Templates & Automation (2026 Best Practices)

**Goal:** Streamline issue/PR management and quality control using cutting-edge GitHub Actions patterns.

### Research Insights

**2026 GitHub Actions Key Features:**
- **npm OIDC Trusted Publishing** - Eliminate long-lived npm tokens
- **Automatic Provenance Attestations** - SLSA compliance built-in
- **Enhanced Caching** - actions/setup-node@v4 with `cache: 'npm'`
- **Matrix Optimization** - Test Node.js 20, 22, 24 (LTS versions)
- **EPSS Risk Scoring** - Dependabot alerts with exploit prediction
- **Action Allowlisting** - Available across all GitHub plans (2026)

**Tasks:**

1. **Create issue templates**

   Directory: `.github/ISSUE_TEMPLATE/`

   Files:
   - `bug_report.md` - Bug report template with environment details
   - `feature_request.md` - Feature request template
   - `config.yml` - Issue template configuration

   Reference: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests

2. **Create PR template**

   File: `.github/PULL_REQUEST_TEMPLATE.md`

   Sections:
   - Description
   - Related Issue (Closes #XXX)
   - Changes Made (checklist)
   - Testing Done
   - Checklist (code style, self-review, CHANGELOG updated)

3. **Create optimized CI workflow (2026 patterns)**

   File: `.github/workflows/ci.yml`

   **Features:**
   - Concurrency groups (cancel outdated runs)
   - Matrix testing (Node.js 20, 22, 24)
   - Built-in caching (actions/setup-node@v4)
   - Parallel job execution
   - Package validation

   **Complete workflow:**
   ```yaml
   name: CI

   on:
     push:
       branches: [ main ]
     pull_request:
       branches: [ main ]

   # Cancel outdated CI runs on new push (cost optimization)
   concurrency:
     group: ${{ github.workflow }}-${{ github.head_ref || github.run_id }}
     cancel-in-progress: true

   jobs:
     lint:
       name: Lint
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4

         - uses: actions/setup-node@v4
           with:
             node-version: '22.x'
             cache: 'npm'  # Automatic caching!

         - name: Install dependencies
           run: cd mcp && npm ci

         - name: Run linter
           run: cd mcp && npm run lint --if-present

     test:
       name: Test (Node ${{ matrix.node-version }})
       runs-on: ubuntu-latest

       strategy:
         fail-fast: false  # Continue all tests even if one fails
         matrix:
           node-version: [20, 22, 24]  # LTS versions for 2026

       steps:
         - uses: actions/checkout@v4

         - uses: actions/setup-node@v4
           with:
             node-version: ${{ matrix.node-version }}
             cache: 'npm'

         - name: Install dependencies
           run: cd mcp && npm ci

         - name: Run tests
           run: cd mcp && npm test

         - name: Upload coverage (Node 24 only)
           if: matrix.node-version == 24
           uses: codecov/codecov-action@v4
           with:
             token: ${{ secrets.CODECOV_TOKEN }}
             files: ./mcp/coverage/lcov.info

     validate:
       name: Package Validation
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4

         - uses: actions/setup-node@v4
           with:
             node-version: '22.x'
             cache: 'npm'

         - name: Install dependencies
           run: cd mcp && npm ci

         - name: Validate package
           run: cd mcp && npm pack --dry-run

         - name: Check for data files in package
           run: |
             cd mcp
             ! tar -tzf career-pipeline-mcp-*.tgz | grep -E "\.(db|db-wal|db-shm)$"
   ```

4. **Create publish workflow with OIDC (2026 standard)**

   File: `.github/workflows/publish.yml`

   **Features:**
   - npm OIDC Trusted Publishing (no npm tokens needed!)
   - Automatic provenance attestations
   - SBOM generation
   - Environment protection

   **Prerequisites:**
   1. Configure trusted publisher on npmjs.com:
      - Go to: npmjs.com → Your Package → Settings → Trusted publishing
      - Add: GitHub org/user, repository name, workflow filename (`publish.yml`), environment (`production`)
   2. Create `production` environment in GitHub repository settings
   3. Ensure Node.js ≥ 22.14.0 and npm ≥ 11.5.1

   **Complete workflow:**
   ```yaml
   name: Publish to npm

   on:
     release:
       types: [published]

   jobs:
     publish:
       name: Publish to npm
       runs-on: ubuntu-latest

       permissions:
         contents: read      # Read repository
         id-token: write     # REQUIRED for OIDC

       environment: production  # Matches npm trusted publisher config

       steps:
         - name: Checkout code
           uses: actions/checkout@v4

         - name: Setup Node.js
           uses: actions/setup-node@v4
           with:
             node-version: '22.x'
             cache: 'npm'
             registry-url: 'https://registry.npmjs.org'

         - name: Update npm to latest
           run: npm install -g npm@latest

         - name: Install dependencies
           run: cd mcp && npm ci

         - name: Run tests
           run: cd mcp && npm test

         - name: Generate SBOM
           run: cd mcp && npx @cyclonedx/cyclonedx-npm --output-file sbom.json

         - name: Publish with provenance
           run: cd mcp && npm publish
           # No --provenance flag needed with trusted publishing!
           # Provenance is generated automatically

         - name: Upload SBOM as artifact
           uses: actions/upload-artifact@v4
           with:
             name: sbom-${{ github.event.release.tag_name }}
             path: mcp/sbom.json
             retention-days: 90
   ```

   Reference: https://docs.npmjs.com/trusted-publishers/

5. **Create security scanning workflow**

   File: `.github/workflows/security.yml`

   **Features:**
   - CodeQL scanning for JavaScript
   - npm audit
   - Dependabot (configured separately)
   - SBOM generation

   ```yaml
   name: Security

   on:
     push:
       branches: [main]
     pull_request:
       branches: [main]
     schedule:
       - cron: '0 0 * * 1'  # Weekly on Monday

   jobs:
     codeql:
       name: CodeQL Analysis
       runs-on: ubuntu-latest

       permissions:
         security-events: write
         actions: read
         contents: read

       steps:
         - uses: actions/checkout@v4

         - name: Initialize CodeQL
           uses: github/codeql-action/init@v3
           with:
             languages: javascript
             queries: +security-and-quality

         - name: Autobuild
           uses: github/codeql-action/autobuild@v3

         - name: Perform CodeQL Analysis
           uses: github/codeql-action/analyze@v3

     audit:
       name: npm Audit
       runs-on: ubuntu-latest

       steps:
         - uses: actions/checkout@v4

         - uses: actions/setup-node@v4
           with:
             node-version: '22.x'
             cache: 'npm'

         - name: Install dependencies
           run: cd mcp && npm ci

         - name: Run npm audit
           run: cd mcp && npm audit --audit-level=moderate
           continue-on-error: true
   ```

6. **Configure Dependabot (2026 EPSS scoring)**

   File: `.github/dependabot.yml`

   **New Feature:** EPSS (Exploit Prediction Scoring System) predicts likelihood of vulnerability exploitation in next 30 days.

   ```yaml
   version: 2
   updates:
     # npm dependencies
     - package-ecosystem: "npm"
       directory: "/mcp"
       schedule:
         interval: "weekly"
         day: "monday"
         time: "09:00"
       open-pull-requests-limit: 10
       labels:
         - "dependencies"
         - "automated"
       commit-message:
         prefix: "chore"
         include: "scope"
       # Group minor/patch updates
       groups:
         development-dependencies:
           dependency-type: "development"
           update-types:
             - "minor"
             - "patch"
         production-dependencies:
           dependency-type: "production"
           update-types:
             - "patch"

     # GitHub Actions
     - package-ecosystem: "github-actions"
       directory: "/"
       schedule:
         interval: "weekly"
       labels:
         - "ci"
         - "automated"
   ```

7. **Configure branch protection**

   Settings → Branches → Add rule for `main`:
   - ✅ Require pull request before merging
   - ✅ Require status checks to pass (CI workflow: test, lint, validate)
   - ✅ Require conversation resolution
   - ✅ Require linear history (optional)

   Reference: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches

### Performance Considerations

**Caching Impact:**
- Built-in caching (actions/setup-node@v4) reduces build times by up to 80%
- Cache key based on `package-lock.json` hash
- No manual cache configuration needed

**Matrix Testing:**
- 3 Node.js versions tested in parallel
- Same wall-clock time as testing 1 version
- Use `fail-fast: false` for comprehensive testing

**Concurrency Groups:**
- Cancel outdated CI runs on new push
- Can reduce GitHub Actions spending by 10%+
- Safe for PR workflows, avoid for deployments

### Security Best Practices

✅ **OIDC instead of tokens** - No long-lived npm secrets
✅ **Automatic provenance** - SLSA compliance
✅ **EPSS risk scoring** - Prioritize high-risk vulnerabilities
✅ **CodeQL scanning** - Find security issues in code
✅ **SBOM generation** - Supply chain transparency
✅ **Action allowlisting** - Control which actions can run

### References

- **npm Trusted Publishing:** https://docs.npmjs.com/trusted-publishers/ (GA July 2025)
- **GitHub Actions 2026 Updates:** https://github.blog/changelog/2026-02-05-github-actions-early-february-2026-updates/
- **EPSS Scoring:** https://www.first.org/epss/
- **CodeQL:** https://codeql.github.com/
- **actions/setup-node@v4:** https://github.com/actions/setup-node/tree/v4

**Dependencies:** Phase 3 (CONTRIBUTING.md should reference templates)

---

### Phase 5: Testing Infrastructure (2026 Best Practices)

**Goal:** Establish comprehensive test coverage using modern Node.js testing patterns for MCP servers.

**Current State:** Zero tests

### Research Insights

**2026 Testing Recommendations:**
- **Node.js Native Test Runner** (`node:test`) - Zero dependencies, built-in since Node 18
- **c8 for Coverage** - Native V8 coverage, faster than nyc
- **In-Memory SQLite** - Fast, isolated test databases
- **MCP Protocol Testing** - Validate MCP SDK compliance
- **Target Coverage:** 75-80% (industry standard for backend servers)

**Why Node.js Test Runner over Mocha/Jest:**
- ✅ Zero dependencies (already in Node.js 18+)
- ✅ Modern & fast with parallel execution
- ✅ Perfect for backend/server projects
- ✅ Future-proof (maintained by Node.js core team)
- ✅ Keeps project lightweight (only 2 dependencies currently)

**Tasks:**

1. **Set up modern test framework**

   Install coverage tool only:
   ```bash
   cd mcp
   npm install --save-dev c8
   ```

   Update `mcp/package.json` scripts:
   ```json
   {
     "scripts": {
       "start": "node server.js",
       "test": "node --test test/**/*.test.js",
       "test:watch": "node --test --watch test/**/*.test.js",
       "test:coverage": "c8 --reporter=text --reporter=html node --test test/**/*.test.js",
       "test:ci": "c8 --reporter=lcov node --test test/**/*.test.js",
       "prepublishOnly": "npm run test:coverage && npm pack --dry-run"
     },
     "devDependencies": {
       "c8": "^10.1.2"
     }
   }
   ```

2. **Create test directory structure**

   ```
   test/
   ├── unit/
   │   ├── tools/
   │   │   ├── career-read.test.js
   │   │   ├── career-write.test.js
   │   │   ├── career-search.test.js
   │   │   ├── career-stats.test.js
   │   │   └── career-dump.test.js
   │   └── validation/
   │       ├── sql-injection.test.js
   │       └── input-validation.test.js
   ├── integration/
   │   ├── mcp-protocol.test.js
   │   └── stdio-transport.test.js
   ├── fixtures/
   │   ├── schema.sql
   │   ├── basic.sql
   │   └── large-dataset.sql
   └── helpers/
       ├── db-helper.js
       └── mcp-client.js
   ```

3. **Create database test helper**

   File: `mcp/test/helpers/db-helper.js`

   **In-memory SQLite strategy for fast, isolated tests:**

   ```javascript
   const Database = require('better-sqlite3');
   const path = require('path');
   const fs = require('fs');

   class TestDatabase {
     constructor() {
       // Use :memory: for speed and isolation
       this.db = new Database(':memory:');
       this.db.pragma('journal_mode = WAL');
       this.db.pragma('foreign_keys = ON');
     }

     setupSchema() {
       // Load production schema
       const schemaPath = path.join(__dirname, '../../scripts/schema.sql');
       const schema = fs.readFileSync(schemaPath, 'utf-8');
       this.db.exec(schema);
     }

     seedData(fixture = 'basic') {
       const dataPath = path.join(__dirname, `../fixtures/${fixture}.sql`);
       const data = fs.readFileSync(dataPath, 'utf-8');
       this.db.exec(data);
     }

     close() {
       this.db.close();
     }

     // Transaction-based isolation for parallel tests
     withTransaction(fn) {
       const savepoint = `test_${Date.now()}`;
       this.db.exec(`SAVEPOINT ${savepoint}`);
       try {
         const result = fn();
         this.db.exec(`ROLLBACK TO ${savepoint}`);
         return result;
       } catch (err) {
         this.db.exec(`ROLLBACK TO ${savepoint}`);
         throw err;
       }
     }
   }

   module.exports = { TestDatabase };
   ```

4. **Create tool tests (Node.js Test Runner)**

   File: `mcp/test/unit/tools/career-read.test.js`

   **Example test using native Node.js test runner:**

   ```javascript
   const { describe, it, beforeEach, afterEach } = require('node:test');
   const assert = require('node:assert');
   const { TestDatabase } = require('../../helpers/db-helper');
   const { McpServer } = require('@modelcontextprotocol/sdk/server/mcp.js');

   describe('career_read tool', () => {
     let testDb;
     let server;

     beforeEach(() => {
       testDb = new TestDatabase();
       testDb.setupSchema();
       testDb.seedData('basic');

       // Create server instance with test DB
       server = createTestServer(testDb.db);
     });

     afterEach(() => {
       testDb.close();
     });

     it('should execute valid SELECT query', async () => {
       const result = await server.callTool('career_read', {
         query: 'SELECT * FROM tasks LIMIT 1'
       });

       assert.strictEqual(result.isError, undefined);
       assert.ok(result.content[0].text.includes('['));
     });

     it('should reject INSERT queries', async () => {
       const result = await server.callTool('career_read', {
         query: 'INSERT INTO tasks VALUES (1, "test")'
       });

       assert.strictEqual(result.isError, true);
       assert.ok(result.content[0].text.includes('Only SELECT'));
     });

     it('should handle SQL syntax errors gracefully', async () => {
       const result = await server.callTool('career_read', {
         query: 'SELECT * FROMM tasks'
       });

       assert.strictEqual(result.isError, true);
       assert.ok(result.content[0].text.includes('error'));
     });

     it('should allow PRAGMA queries', async () => {
       const result = await server.callTool('career_read', {
         query: 'PRAGMA table_info(tasks)'
       });

       assert.strictEqual(result.isError, undefined);
     });
   });
   ```

5. **Create SQL injection prevention tests**

   File: `mcp/test/unit/validation/sql-injection.test.js`

   **Critical security testing:**

   ```javascript
   const { describe, it } = require('node:test');
   const assert = require('node:assert');

   describe('SQL Injection Prevention', () => {
     const injectionAttempts = [
       "SELECT * FROM tasks; DROP TABLE tasks; --",
       "SELECT * FROM tasks WHERE id = 1 OR 1=1",
       "SELECT * FROM tasks UNION SELECT * FROM sqlite_master",
       "'; DROP TABLE tasks; --",
     ];

     injectionAttempts.forEach((attempt) => {
       it(`should handle: ${attempt.substring(0, 50)}...`, async () => {
         const result = await testServer.callTool('career_read', {
           query: attempt
         });

         // Verify database still intact
         const tables = testDb.db
           .prepare("SELECT name FROM sqlite_master WHERE type='table'")
           .all();
         assert.ok(tables.length > 0, 'Tables should still exist');
       });
     });
   });
   ```

6. **Create MCP protocol compliance tests**

   File: `mcp/test/integration/mcp-protocol.test.js`

   **Validate MCP SDK integration:**

   ```javascript
   const { describe, it } = require('node:test');
   const assert = require('node:assert');
   const { Client } = require('@modelcontextprotocol/sdk/client/index.js');
   const { StdioClientTransport } = require('@modelcontextprotocol/sdk/client/stdio.js');
   const path = require('path');

   describe('MCP Protocol Compliance', () => {
     it('should list all 5 tools correctly', async () => {
       const client = new Client({
         name: 'test-client',
         version: '1.0.0'
       }, {
         capabilities: {}
       });

       const serverPath = path.join(__dirname, '../../server.js');
       const transport = new StdioClientTransport({
         command: 'node',
         args: [serverPath],
         env: {
           ...process.env,
           CAREER_PIPELINE_DATA_DIR: '/tmp/test-career-pipeline'
         }
       });

       await client.connect(transport);

       const tools = await client.listTools();

       assert.strictEqual(tools.tools.length, 5);
       const toolNames = tools.tools.map(t => t.name);
       assert.ok(toolNames.includes('career_read'));
       assert.ok(toolNames.includes('career_write'));
       assert.ok(toolNames.includes('career_search'));
       assert.ok(toolNames.includes('career_stats'));
       assert.ok(toolNames.includes('career_dump'));

       await client.close();
     });
   });
   ```

7. **Configure coverage targets**

   File: `mcp/.c8rc.json`

   ```json
   {
     "all": true,
     "include": ["server.js"],
     "exclude": [
       "test/**",
       "node_modules/**"
     ],
     "reporter": ["text", "html", "lcov"],
     "check-coverage": true,
     "lines": 75,
     "functions": 75,
     "branches": 70,
     "statements": 75,
     "per-file": true
   }
   ```

### Coverage Targets (Industry Standards)

| Area | Target | Priority |
|------|--------|----------|
| **Overall Line Coverage** | 75-80% | Required |
| **Tool Functions** | 90%+ | Critical |
| **SQL Validation** | 100% | Security-critical |
| **Error Handlers** | 85%+ | Important |
| **Branch Coverage** | 70%+ | Important |

### Minimum Viable Test Suite (Pre-Release)

**Phase 1: Core Functionality (~20 tests, Coverage: ~60%)**
- ✅ 1 happy path test per tool × 5 tools
- ✅ 1 error handling test per tool × 5 tools
- ✅ SQL injection prevention (4 tests)
- ✅ Input validation (3 tests)
- ✅ MCP protocol compliance (2 tests)

**Phase 2: Edge Cases (~35 tests, Coverage: ~75%)**
- ✅ Empty database scenarios (5 tests)
- ✅ Large dataset handling (3 tests)
- ✅ Special characters in search (3 tests)
- ✅ File system errors (2 tests)
- ✅ Database connection errors (2 tests)

**Phase 3: Integration (~47 tests, Coverage: 80%+)**
- ✅ End-to-end MCP client tests (5 tests)
- ✅ stdio transport validation (3 tests)
- ✅ Concurrent read scenarios (2 tests)
- ✅ Transaction handling (2 tests)

### Performance Considerations

**Test Execution Speed:**
- Unit tests: < 5 seconds total
- Integration tests: < 15 seconds total
- Coverage report: < 2 seconds additional
- CI total runtime: < 30 seconds per Node version

**Parallel Testing:**
```javascript
// Run with: node --test --concurrency=4
describe('Parallel suite', { concurrency: true }, () => {
  it('test 1', async () => { /* ... */ });
  it('test 2', async () => { /* ... */ });
});
```

### Security Testing Checklist

✅ SQL injection tests passing
✅ No DROP/ALTER/CREATE in career_write
✅ Path traversal prevention in career_dump
✅ Error messages don't leak system info
✅ Database file permissions validated
✅ No sensitive data in error logs
✅ Input validation using Zod schemas

### References

- **Node.js Test Runner:** https://nodejs.org/api/test.html
- **c8 Coverage:** https://github.com/bcoe/c8
- **MCP Protocol Spec:** https://modelcontextprotocol.io/specification/2025-11-25
- **MCP Inspector:** https://github.com/modelcontextprotocol/inspector
- **Better-sqlite3 Testing:** https://wchargin.com/better-sqlite3/performance.html

**Dependencies:** Phase 2 (package.json scripts must exist)

**Blocks:** Safe publishing (cannot publish without basic tests)

---

### Phase 6: Publishing & Distribution

**Goal:** Publish to npm and create GitHub release.

**Prerequisites Checklist:**
- [ ] All phases 1-5 completed
- [ ] LICENSE file exists and is correct
- [ ] All license declarations match (MIT everywhere)
- [ ] package.json complete with all metadata
- [ ] .npmignore prevents data leaks
- [ ] All community docs created (CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CHANGELOG)
- [ ] Tests passing
- [ ] CI workflow running
- [ ] Package validation passes

**Tasks:**

1. **Pre-publish validation**

   ```bash
   cd mcp

   # 1. Validate package contents
   npm pack
   tar -tzf career-pipeline-mcp-*.tgz

   # 2. Check no data files
   ! tar -tzf career-pipeline-mcp-*.tgz | grep -E "\.(db|db-wal|db-shm)$"

   # 3. Verify metadata
   npm publish --dry-run

   # 4. Run tests
   npm test
   ```

2. **Publish to npm**

   ```bash
   cd mcp

   # First time: Login to npm (requires 2FA)
   npm login

   # Publish with provenance (supply chain security)
   npm publish --access public --provenance
   ```

   Reference: https://docs.npmjs.com/generating-provenance-statements

3. **Create GitHub release**

   ```bash
   # Tag the release
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0

   # Create release (via GitHub web UI or gh CLI)
   gh release create v1.0.0 \
     --title "v1.0.0 - Initial Open Source Release" \
     --notes "$(cat CHANGELOG.md | grep -A 20 '## \[1.0.0\]')"
   ```

4. **Submit to MCP Registry**

   - Visit: https://mcpservers.org/
   - Submit package: `career-pipeline-mcp`
   - Provide description and example configuration

   Benefits: Discoverability in MCP ecosystem

5. **Update README with badges**

   Add to top of `mcp/README.md`:
   ```markdown
   [![npm version](https://img.shields.io/npm/v/career-pipeline-mcp.svg)](https://www.npmjs.com/package/career-pipeline-mcp)
   [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
   [![Node Version](https://img.shields.io/node/v/career-pipeline-mcp.svg)](https://nodejs.org)
   [![CI Status](https://github.com/blueglasses1995/career-pipeline/workflows/CI/badge.svg)](https://github.com/blueglasses1995/career-pipeline/actions)
   ```

**Dependencies:** All previous phases must be complete

**One-way operation:** npm packages cannot be unpublished after 72 hours

---

## Acceptance Criteria

### Phase 1: Legal Foundation
- [ ] LICENSE file exists at repository root with MIT license text
- [ ] All files show consistent "MIT" license (package.json, plugin.json, README)
- [ ] SPDX header added to server.js
- [ ] No more ISC references anywhere in codebase

### Phase 2: Package Metadata
- [ ] package.json has all required fields (repository, bugs, homepage, keywords, author, engines, files)
- [ ] .npmignore exists and excludes .db files, .git, .github
- [ ] `npm pack` succeeds with < 1MB tarball
- [ ] Tarball contains only: package.json, server.js, README.md, LICENSE (no data files)

### Phase 3: Community Documentation
- [ ] CONTRIBUTING.md created with clear workflow instructions
- [ ] CODE_OF_CONDUCT.md created using Contributor Covenant 2.1
- [ ] SECURITY.md created with vulnerability reporting process
- [ ] CHANGELOG.md created with 1.0.0 release entry
- [ ] mcp/README.md created with MCP server details

### Phase 4: GitHub Automation
- [ ] .github/ISSUE_TEMPLATE/ with bug_report.md and feature_request.md
- [ ] .github/PULL_REQUEST_TEMPLATE.md exists
- [ ] .github/workflows/ci.yml running on pushes and PRs
- [ ] Branch protection enabled on main branch
- [ ] CI passing on latest commit

### Phase 5: Testing
- [ ] Test framework installed (mocha + chai)
- [ ] Smoke test passes (server starts)
- [ ] Integration tests pass for all 5 tools
- [ ] `npm test` command works
- [ ] prepublishOnly validation configured

### Phase 6: Publishing
- [ ] Package published to npm at https://www.npmjs.com/package/career-pipeline-mcp
- [ ] GitHub release v1.0.0 created with release notes
- [ ] npm package shows correct README and metadata
- [ ] Installation works: `npm install career-pipeline-mcp`
- [ ] Submitted to MCP Registry
- [ ] Badges added to README

### Overall Quality Gates
- [ ] Three independent test installations successful
- [ ] No personal data in published package
- [ ] All documentation links working
- [ ] GitHub repository topics added (mcp, sqlite, career, ai-assistant)

## Success Metrics

**Immediate (Week 1):**
- npm package visible and installable
- GitHub repository has all community health files
- CI/CD passing
- Zero high-priority issues in GitHub Issues

**Short-term (Month 1):**
- 10+ npm downloads
- 2+ GitHub stars
- Listed in MCP Registry
- At least 1 external user provides feedback

**Long-term (Quarter 1):**
- 100+ npm downloads
- 5+ GitHub stars
- 1+ external contribution (issue or PR)
- Mentioned in at least one blog post or tutorial

## Dependencies & Risks

### Critical Dependencies (Must Happen in Order)

```
Phase 1 (Legal)
  ↓ (blocks)
Phase 2 (Package Metadata) + Phase 3 (Community Docs)
  ↓ (blocks)
Phase 4 (GitHub Templates)
  ↓ (blocks)
Phase 5 (Testing)
  ↓ (blocks)
Phase 6 (Publishing)
```

### High Risks

**R1: License Legal Risk** ⚠️ CRITICAL
- Severity: Critical
- Current: MIT vs. ISC conflict, no LICENSE file
- Impact: Cannot accept contributions, legal ambiguity
- Mitigation: **MUST resolve in Phase 1 before ANY other work**

**R2: Accidental Data Exposure** ⚠️ HIGH
- Severity: High
- Current: No .npmignore, could publish database files
- Impact: Personal career data exposed permanently on npm
- Mitigation: Create .npmignore in Phase 2, validate package contents before publish

**R3: Package Name Squatting** ⚠️ MEDIUM
- Severity: Medium
- Current: `career-pipeline-mcp` not registered on npm
- Impact: Someone else could register the name during prep work
- Mitigation: Consider early registration with `private: true`, then make public when ready

**R4: Zero Test Coverage** ⚠️ MEDIUM
- Severity: Medium
- Current: No tests, could ship broken code
- Impact: Reputation damage, user frustration
- Mitigation: Phase 5 minimum viable tests before publishing

### External Dependencies

- npm account with 2FA enabled (for publishing)
- GitHub account with admin access to repository
- Node.js 18+ for development and CI
- GitHub Actions minutes (free tier sufficient)

## Technical Considerations

### Platform Compatibility

**Currently tested:** macOS
**Documented support:** Linux, macOS
**Unknown:** Windows

**Recommendation:** Document as "macOS and Linux only" in README, or test on Windows before claiming support.

**Windows-specific concerns:**
- `~` home directory expansion may not work
- SQLite file locking behavior differs
- Path separators (using `path.join` mitigates this)

### Database Migration Strategy

**Current state:** Schema in `scripts/schema.sql`

**Considerations for open source:**
- Users may have different schema versions
- No documented migration path
- Recommend: Add version check to server.js, document schema versioning in README

### MCP Security Model

**Current protections:**
- ✅ Query validation (SELECT-only for career_read)
- ✅ Forbidden keywords (DROP, ALTER, CREATE blocked in career_write)
- ✅ No external network calls

**Potential improvements:**
- Query timeout (prevent DOS with complex queries)
- Rate limiting (prevent rapid-fire queries)
- Audit logging (track all database modifications)

**Document in SECURITY.md:** This server accesses local SQLite database only, no data sent externally.

### Performance Considerations

**Current:** Single-threaded Node.js with better-sqlite3 (synchronous)

**Scaling limits:**
- Large databases (100,000+ rows) may slow queries
- Recommend: Document performance characteristics in README
- Consider: Adding query LIMIT recommendations

## References & Research

### Repository Analysis
- Project structure: `mcp/server.js` (356 lines), `commands/` (11 files), `hooks/` (2 files)
- Current state: 80% ready, missing legal/governance docs
- File path: `/Users/toshikimatsukuma/Documents/career-pipeline/`

### External Best Practices
- **Open Source Guide:** https://opensource.guide/starting-a-project/
- **Keep a Changelog:** https://keepachangelog.com/en/1.1.0/
- **Contributor Covenant:** https://www.contributor-covenant.org/
- **npm Best Practices:** https://docs.npmjs.com/cli/v7/configuring-npm/package-json/
- **GitHub Templates:** https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests
- **npm Trusted Publishing:** https://docs.npmjs.com/trusted-publishers/
- **Semantic Versioning:** https://semver.org/

### MCP-Specific
- **MCP Specification:** https://modelcontextprotocol.io/specification/
- **MCP Server Registry:** https://mcpservers.org/
- **MCP SDK:** https://github.com/modelcontextprotocol/sdk

### Licensing Resources
- **Choose a License:** https://choosealicense.com/licenses/mit/
- **SPDX:** https://spdx.org/licenses/MIT.html

## Future Considerations

### Post-1.0 Enhancements

**Documentation:**
- Video tutorial for setup and usage
- GitHub Pages documentation site
- Example career database with sample data
- Integration guides for other MCP clients

**Quality:**
- Increase test coverage to 80%+
- Add end-to-end tests with real database
- Performance benchmarks
- Windows compatibility testing

**Automation:**
- semantic-release for automated versioning
- Dependabot for dependency updates
- Stale issue bot
- Automated CHANGELOG generation from commits

**Community:**
- GitHub Discussions for Q&A
- Contributing guide with good first issues
- Code of conduct enforcement guidelines
- Maintainer GOVERNANCE.md

### Extensibility

**Plugin architecture:**
- Support custom tools via configuration
- Export/import configurations
- Integration with other career management tools

**Distribution:**
- Docker image for easy deployment
- Homebrew formula for macOS users
- npx support for zero-install usage

## Estimated Effort

**Phase 1 (Legal):** 1 hour
- Create LICENSE file: 15 min
- Fix package.json: 10 min
- Add SPDX headers: 15 min
- Validation: 20 min

**Phase 2 (Package Metadata):** 1 hour
- Update package.json: 30 min
- Create .npmignore: 15 min
- Validate package: 15 min

**Phase 3 (Community Docs):** 3 hours
- CONTRIBUTING.md: 45 min
- CODE_OF_CONDUCT.md: 15 min (use template)
- SECURITY.md: 30 min
- CHANGELOG.md: 30 min
- mcp/README.md: 60 min

**Phase 4 (GitHub Automation):** 2 hours
- Issue templates: 30 min
- PR template: 15 min
- CI workflow: 45 min
- Branch protection: 15 min
- Troubleshooting CI: 15 min

**Phase 5 (Testing):** 4 hours
- Set up test framework: 30 min
- Smoke test: 1 hour
- Integration tests (5 tools): 2 hours
- Debug test failures: 30 min

**Phase 6 (Publishing):** 2 hours
- Pre-publish validation: 30 min
- npm account setup (if needed): 15 min
- Publish to npm: 15 min
- Create GitHub release: 30 min
- Submit to MCP Registry: 15 min
- Add badges: 15 min

**Total estimated time:** 13 hours

**Recommended timeline:** 2-3 days (allowing for breaks and unexpected issues)

## Next Steps

After plan approval, proceed with:

1. **Start with Phase 1** - Legal foundation is critical and blocks everything else
2. **Parallel work** - Phases 2 and 3 can be done simultaneously after Phase 1
3. **Validation at each phase** - Use provided validation commands to ensure correctness
4. **Test early** - Don't wait until Phase 5 to start thinking about tests
5. **Document as you go** - Update CHANGELOG.md with each significant change

**Ready to begin? Suggested first command:**
```bash
# Create LICENSE file
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 Toshiki Matsukuma

[... full MIT license text ...]
EOF
```
