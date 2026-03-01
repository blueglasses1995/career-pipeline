# career-pipeline-mcp

[![npm version](https://img.shields.io/npm/v/career-pipeline-mcp.svg)](https://www.npmjs.com/package/career-pipeline-mcp)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

MCP (Model Context Protocol) server for managing career data in a SQLite database. Track projects, tasks, decisions, challenges, outcomes, and contributions.

## Features

- 📊 **SQL Query Execution** - Read and write operations with safety validation
- 🔍 **Full-Text Search** - Search across all content fields
- 📈 **Statistics** - Get overview of your career data
- 💾 **Database Export** - Dump entire database to SQL file
- 🔒 **Security** - SQL injection prevention, prepared statements
- ⚡ **Performance** - WAL mode, foreign keys enforcement

## Installation

```bash
npm install career-pipeline-mcp
```

## Configuration

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS):

```json
{
  "mcpServers": {
    "career-pipeline": {
      "command": "node",
      "args": [
        "/path/to/node_modules/career-pipeline-mcp/server.js"
      ],
      "env": {
        "CAREER_PIPELINE_DATA_DIR": "/path/to/.career-pipeline"
      }
    }
  }
}
```

### Environment Variables

- `CAREER_PIPELINE_DATA_DIR` - Directory containing `career.db` (default: `~/.career-pipeline`)

## Available Tools

### career_read

Execute SELECT queries on the career database.

**Parameters:**
- `query` (string): SQL SELECT query to execute

**Example:**
```sql
SELECT * FROM projects WHERE status = 'active' LIMIT 10
```

### career_write

Execute INSERT, UPDATE, or DELETE operations.

**Parameters:**
- `query` (string): SQL INSERT/UPDATE/DELETE statement
- `params` (array, optional): Bind parameters for prepared statement

**Example:**
```sql
INSERT INTO tasks (project_id, title, status) VALUES (?, ?, ?)
```

**Safety:** DROP, ALTER, and CREATE statements are blocked.

### career_search

Full-text keyword search across all major content fields.

**Parameters:**
- `keyword` (string): Search keyword or phrase
- `limit` (number, optional): Max results per table (default: 20)

**Searches in:** tasks, decisions, challenges, outcomes, contributions, raw_notes

### career_stats

Get overview statistics of the career database.

**Returns:**
- Row counts for all tables
- Distinct decision tags
- Distinct challenge tags

### career_dump

Export entire database to SQL dump file at `~/.career-pipeline/dumps/career.sql`.

**Returns:**
- Success status
- File path
- Number of tables
- File size

## Database Schema

The server expects a SQLite database with tables:
- `projects` - Career projects
- `tasks` - Project tasks
- `decisions` - Technical decisions
- `challenges` - Challenges faced and resolved
- `outcomes` - Measurable outcomes
- `contributions` - Open source contributions
- `raw_notes` - Unstructured notes

## Security

- ✅ SQL injection prevention through query validation
- ✅ Prepared statements for all write operations
- ✅ Read-only operations limited to SELECT/PRAGMA/EXPLAIN
- ✅ Write operations block DDL statements (DROP/ALTER/CREATE)
- ✅ Local-only communication via stdio (no network exposure)

## Development

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development guidelines.

## License

MIT © Toshiki Matsukuma

## Links

- [GitHub Repository](https://github.com/blueglasses1995/career-pipeline)
- [Report Issues](https://github.com/blueglasses1995/career-pipeline/issues)
- [MCP Documentation](https://modelcontextprotocol.io)
