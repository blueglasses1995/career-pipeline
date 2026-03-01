# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Open source preparation and documentation

## [1.0.0] - 2026-03-01

### Added
- Initial public release
- MCP server implementation with 5 tools:
  - `career_read` - Execute SELECT queries
  - `career_write` - Execute INSERT/UPDATE/DELETE
  - `career_search` - Full-text keyword search
  - `career_stats` - Get database statistics
  - `career_dump` - Export to SQL dump file
- SQLite database integration via better-sqlite3
- Claude Desktop integration support
- MIT license
- Community documentation (CONTRIBUTING.md, SECURITY.md)
- Comprehensive package metadata for npm

### Security
- Input validation via prepared statements
- Database file exclusion from published package

[Unreleased]: https://github.com/blueglasses1995/career-pipeline/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/blueglasses1995/career-pipeline/releases/tag/v1.0.0
