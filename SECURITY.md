# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

To report a security vulnerability, please email the maintainers directly or use GitHub's private vulnerability reporting feature.

### What to include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested fixes (if available)

### Response Timeline

- Initial response: Within 48 hours
- Status update: Within 7 days
- Fix timeline: Depends on severity

## Security Best Practices

When using this MCP server:

1. **Database Security**: Store your career database (`~/.career-pipeline/career.db`) with appropriate file permissions
2. **No Sensitive Data**: Avoid storing passwords, API keys, or other secrets in the database
3. **Input Validation**: The server validates all SQL queries to prevent injection attacks
4. **Access Control**: Only run the MCP server in trusted environments
5. **Updates**: Keep dependencies up to date using `npm audit` and Dependabot

## Known Security Considerations

- This server provides direct SQL access to your career database
- The server runs with the same permissions as the user running it
- All MCP communication happens over stdio (local only, no network exposure)

## Security Updates

Security updates will be released as soon as possible after vulnerabilities are discovered and verified.
