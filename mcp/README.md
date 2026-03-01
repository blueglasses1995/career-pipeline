# career-pipeline-mcp

MCP server for career-pipeline SQLite database.

## Installation

```bash
npm install career-pipeline-mcp
```

## Usage

Add to your Claude Desktop config at `~/Library/Application Support/Claude/claude_desktop_config.json`:

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

## Available Tools

- **career_read** - Execute SELECT queries
- **career_write** - Execute INSERT/UPDATE/DELETE
- **career_search** - Full-text keyword search
- **career_stats** - Get database statistics
- **career_dump** - Export to SQL dump file

## License

MIT © Toshiki Matsukuma
