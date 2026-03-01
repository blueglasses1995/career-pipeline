# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it privately:

1. **Do NOT** open a public GitHub issue
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

You can expect:
- Acknowledgment within 48 hours
- Regular updates on progress
- Credit in release notes (unless you prefer anonymity)

## Security Considerations

### Data Privacy

- This MCP server accesses local SQLite databases
- Never commit database files containing personal data
- Use `CAREER_PIPELINE_DATA_DIR` env var to control data location
- Database files are excluded from npm packages via `.npmignore`

### Input Validation

- SQL queries are executed via better-sqlite3 prepared statements
- User input should be validated before passing to tools
- Read-only operations use SELECT-only queries

### Dependencies

- Minimal dependencies (2 total: MCP SDK, better-sqlite3)
- Regularly updated via Dependabot
- Native modules (better-sqlite3) require rebuild on Node.js version changes

## Best Practices

When using this MCP server:

1. **Isolate data**: Keep career databases separate from sensitive data
2. **Review queries**: Understand what data queries will access
3. **Limit permissions**: Run with minimal necessary file system permissions
4. **Update regularly**: Keep dependencies up to date
5. **Audit logs**: Monitor MCP server activity in production environments
