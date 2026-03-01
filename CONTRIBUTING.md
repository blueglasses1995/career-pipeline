# Contributing to career-pipeline

Thank you for your interest in contributing to career-pipeline! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs. actual behavior
- **Environment details** (Node.js version, OS, etc.)
- **Relevant logs or error messages**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** explaining why this enhancement would be useful
- **Possible implementation** approach (if you have ideas)

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Add tests** if you're adding functionality
4. **Ensure tests pass** by running `npm test`
5. **Update documentation** if needed
6. **Commit with clear messages** following conventional commits format
7. **Submit a pull request**

## Development Setup

### Prerequisites

- Node.js >= 20.0.0
- npm >= 9.0.0

### Installation

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/career-pipeline.git
cd career-pipeline/mcp

# Install dependencies
npm install

# Run tests
npm test

# Check coverage
npm run test:coverage
```

### Project Structure

```
career-pipeline/
├── mcp/              # MCP server implementation
│   ├── server.js     # Main server file
│   ├── package.json  # Package metadata
│   ├── test/         # Test files
│   └── README.md     # Package documentation
├── LICENSE           # MIT license
└── README.md         # Project documentation
```

## Coding Standards

### JavaScript Style

- Use **ES6+ features** where appropriate
- Follow **consistent indentation** (2 spaces)
- Use **meaningful variable names**
- Add **JSDoc comments** for public APIs
- Keep functions **small and focused**

### Testing

- Write **tests for new features**
- Maintain **75%+ code coverage**
- Use **Node.js native test runner** (`node:test`)
- Follow **AAA pattern** (Arrange, Act, Assert)

Example test:

```javascript
import { test } from 'node:test';
import assert from 'node:assert';

test('career_read returns data for valid query', async () => {
  // Arrange
  const query = 'SELECT * FROM projects LIMIT 1';

  // Act
  const result = await careerRead(query);

  // Assert
  assert.ok(result.content);
});
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add career_export tool
fix: handle null values in career_search
docs: update README installation steps
test: add SQL injection prevention tests
chore: update dependencies
```

## Security

- **Never commit** sensitive data (API keys, credentials, personal data)
- Report security vulnerabilities privately (see SECURITY.md)
- Follow **least privilege principle** in code
- Validate and sanitize **all user inputs**

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue for questions or discussions. We're here to help!

## Recognition

Contributors will be recognized in release notes and the project README.
