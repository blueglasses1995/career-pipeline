---
title: Publish career-pipeline MCP Plugin as Open Source
type: feat
date: 2026-03-01
---

# Publish career-pipeline MCP Plugin as Open Source

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

### Phase 4: GitHub Templates & Automation

**Goal:** Streamline issue/PR management and quality control.

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

3. **Create CI workflow**

   File: `.github/workflows/ci.yml`

   Jobs:
   - Test on Node.js 18.x, 20.x, 22.x
   - Run tests (when they exist)
   - Validate package (`npm pack --dry-run`)
   - Check for data files in package

   Example:
   ```yaml
   name: CI

   on:
     push:
       branches: [ main ]
     pull_request:
       branches: [ main ]

   jobs:
     test:
       runs-on: ubuntu-latest
       strategy:
         matrix:
           node-version: [18.x, 20.x, 22.x]
       steps:
       - uses: actions/checkout@v4
       - uses: actions/setup-node@v4
         with:
           node-version: ${{ matrix.node-version }}
       - run: cd mcp && npm ci
       - run: cd mcp && npm test
       - run: cd mcp && npm pack --dry-run
   ```

4. **Create publish workflow (optional)**

   File: `.github/workflows/publish.yml`

   Trigger: On release published

   Steps:
   - Run tests
   - Publish to npm with provenance
   - Use npm Trusted Publishing (OIDC, no long-lived tokens)

   Reference: https://docs.npmjs.com/trusted-publishers/

5. **Configure branch protection**

   Settings → Branches → Add rule for `main`:
   - ✅ Require pull request before merging
   - ✅ Require status checks to pass (CI workflow)
   - ✅ Require conversation resolution

   Reference: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches

**Dependencies:** Phase 3 (CONTRIBUTING.md should reference templates)

---

### Phase 5: Testing Infrastructure (Before Publishing)

**Goal:** Minimum viable test coverage to prevent regressions.

**Current State:** Zero tests

**Tasks:**

1. **Set up test framework**

   Install test dependencies:
   ```bash
   cd mcp
   npm install --save-dev mocha chai
   ```

   Update `mcp/package.json` scripts:
   ```json
   {
     "scripts": {
       "start": "node server.js",
       "test": "mocha test/**/*.test.js",
       "test:smoke": "mocha test/smoke.test.js"
     }
   }
   ```

2. **Create smoke test**

   File: `mcp/test/smoke.test.js`

   Tests:
   - Server starts without errors
   - All 5 tools are discoverable
   - Each tool has valid schema

   Example:
   ```javascript
   const { spawn } = require('child_process');
   const { expect } = require('chai');

   describe('MCP Server Smoke Tests', () => {
     it('should start without errors', (done) => {
       const server = spawn('node', ['server.js']);
       let stderr = '';

       server.stderr.on('data', (data) => {
         stderr += data.toString();
       });

       setTimeout(() => {
         server.kill();
         expect(stderr).to.include('career-pipeline MCP server running');
         done();
       }, 1000);
     });
   });
   ```

3. **Create integration tests**

   File: `mcp/test/tools.test.js`

   Tests for each tool:
   - `career_read` - Validates SELECT queries, rejects INSERT
   - `career_write` - Accepts INSERT/UPDATE, rejects DROP
   - `career_search` - Returns results for keyword
   - `career_stats` - Returns counts object
   - `career_dump` - Creates SQL file

4. **Add prepublishOnly validation**

   Update `mcp/package.json`:
   ```json
   {
     "scripts": {
       "prepublishOnly": "npm test && npm pack --dry-run"
     }
   }
   ```

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
