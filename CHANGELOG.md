# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-01

### Added
- Initial release of career-pipeline MCP server
- `career_read` tool for executing SELECT queries
- `career_write` tool for INSERT/UPDATE/DELETE operations
- `career_search` tool for full-text keyword search
- `career_stats` tool for database statistics
- `career_dump` tool for SQL export
- MIT License
- Community health files (CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)
- GitHub Actions workflows (CI, Security, Publishing)
- Comprehensive test suite with Node.js native test runner
- Code coverage reporting with c8

### Security
- SQL injection prevention through query type validation
- Prepared statements for all database operations
- Foreign keys enforcement
- WAL mode for better concurrency

[1.0.0]: https://github.com/blueglasses1995/career-pipeline/releases/tag/v1.0.0
