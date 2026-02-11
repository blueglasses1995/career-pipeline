const path = require("path");
const os = require("os");
const fs = require("fs");
const { McpServer } = require("@modelcontextprotocol/sdk/server/mcp.js");
const {
  StdioServerTransport,
} = require("@modelcontextprotocol/sdk/server/stdio.js");
const Database = require("better-sqlite3");
const z = require("zod");

// --- DB setup ---
const dataDir =
  process.env.CAREER_PIPELINE_DATA_DIR || path.join(os.homedir(), ".career-pipeline");
const dbPath = path.join(dataDir, "career.db");

let db;
try {
  db = new Database(dbPath);
  db.pragma("journal_mode = WAL");
  db.pragma("foreign_keys = ON");
} catch (err) {
  process.stderr.write(`Failed to open database at ${dbPath}: ${err.message}\n`);
  process.exit(1);
}

// --- MCP server ---
const server = new McpServer({
  name: "career-pipeline",
  version: "1.0.0",
});

// --- Tool: career_read ---
server.tool(
  "career_read",
  "Execute a SELECT query on the career database. Returns rows as JSON.",
  { query: z.string().describe("SQL SELECT query to execute") },
  async ({ query }) => {
    const trimmed = query.trim().toUpperCase();
    if (!trimmed.startsWith("SELECT") && !trimmed.startsWith("PRAGMA") && !trimmed.startsWith("EXPLAIN")) {
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({ error: "Only SELECT, PRAGMA, and EXPLAIN queries are allowed." }),
          },
        ],
        isError: true,
      };
    }
    try {
      const rows = db.prepare(query).all();
      return {
        content: [{ type: "text", text: JSON.stringify(rows, null, 2) }],
      };
    } catch (err) {
      return {
        content: [
          { type: "text", text: JSON.stringify({ error: err.message }) },
        ],
        isError: true,
      };
    }
  }
);

// --- Tool: career_write ---
server.tool(
  "career_write",
  "Execute INSERT, UPDATE, or DELETE on the career database. DROP/ALTER/CREATE are rejected for safety.",
  {
    query: z.string().describe("SQL INSERT/UPDATE/DELETE statement"),
    params: z
      .array(z.any())
      .optional()
      .describe("Optional bind parameters array"),
  },
  async ({ query, params }) => {
    const trimmed = query.trim().toUpperCase();
    const forbidden = ["DROP", "ALTER", "CREATE"];
    for (const kw of forbidden) {
      if (trimmed.startsWith(kw)) {
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                error: `${kw} statements are not allowed for safety.`,
              }),
            },
          ],
          isError: true,
        };
      }
    }
    try {
      const stmt = db.prepare(query);
      const result = params ? stmt.run(...params) : stmt.run();
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              changes: result.changes,
              lastInsertRowid: Number(result.lastInsertRowid),
            }),
          },
        ],
      };
    } catch (err) {
      return {
        content: [
          { type: "text", text: JSON.stringify({ error: err.message }) },
        ],
        isError: true,
      };
    }
  }
);

// --- Tool: career_search ---
const SEARCH_TARGETS = [
  { table: "tasks", columns: ["title", "summary"], label: "Tasks" },
  {
    table: "decisions",
    columns: ["title", "context", "conclusion", "reasoning"],
    label: "Decisions",
  },
  {
    table: "challenges",
    columns: ["title", "symptom", "resolution"],
    label: "Challenges",
  },
  { table: "outcomes", columns: ["metric"], label: "Outcomes" },
  {
    table: "contributions",
    columns: ["description"],
    label: "Contributions",
  },
  { table: "raw_notes", columns: ["content"], label: "Raw Notes" },
];

server.tool(
  "career_search",
  "Full-text keyword search across all major content fields in the career database.",
  {
    keyword: z.string().describe("Search keyword or phrase"),
    limit: z
      .number()
      .optional()
      .describe("Max results per table (default 20)"),
  },
  async ({ keyword, limit }) => {
    const maxRows = limit || 20;
    const results = {};
    const pattern = `%${keyword}%`;

    for (const target of SEARCH_TARGETS) {
      const conditions = target.columns
        .map((col) => `${col} LIKE ?`)
        .join(" OR ");
      const sql = `SELECT * FROM ${target.table} WHERE ${conditions} LIMIT ?`;
      const binds = [
        ...target.columns.map(() => pattern),
        maxRows,
      ];
      try {
        const rows = db.prepare(sql).all(...binds);
        if (rows.length > 0) {
          results[target.label] = rows;
        }
      } catch (err) {
        results[target.label] = { error: err.message };
      }
    }

    if (Object.keys(results).length === 0) {
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              message: `No results found for "${keyword}".`,
            }),
          },
        ],
      };
    }

    return {
      content: [{ type: "text", text: JSON.stringify(results, null, 2) }],
    };
  }
);

// --- Tool: career_stats ---
server.tool(
  "career_stats",
  "Get overview statistics of the career database: row counts and tag lists.",
  {},
  async () => {
    try {
      const countTables = [
        "projects",
        "tasks",
        "decisions",
        "challenges",
        "outcomes",
        "contributions",
        "raw_notes",
      ];
      const counts = {};
      for (const t of countTables) {
        const row = db.prepare(`SELECT COUNT(*) as count FROM ${t}`).get();
        counts[t] = row.count;
      }

      const decisionTags = db
        .prepare("SELECT DISTINCT tag FROM decision_tags ORDER BY tag")
        .all()
        .map((r) => r.tag);

      const challengeTags = db
        .prepare("SELECT DISTINCT tag FROM challenge_tags ORDER BY tag")
        .all()
        .map((r) => r.tag);

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(
              { counts, decisionTags, challengeTags },
              null,
              2
            ),
          },
        ],
      };
    } catch (err) {
      return {
        content: [
          { type: "text", text: JSON.stringify({ error: err.message }) },
        ],
        isError: true,
      };
    }
  }
);

// --- Tool: career_dump ---
server.tool(
  "career_dump",
  "Export the entire career database to a SQL dump file at ~/.career-pipeline/dumps/career.sql.",
  {},
  async () => {
    try {
      const dumpDir = path.join(dataDir, "dumps");
      if (!fs.existsSync(dumpDir)) {
        fs.mkdirSync(dumpDir, { recursive: true });
      }
      const dumpPath = path.join(dumpDir, "career.sql");

      // Get all table names
      const tables = db
        .prepare(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
        )
        .all()
        .map((r) => r.name);

      const lines = [];
      lines.push("-- career-pipeline database dump");
      lines.push(`-- Generated: ${new Date().toISOString()}`);
      lines.push("BEGIN TRANSACTION;");
      lines.push("");

      for (const table of tables) {
        // Schema
        const schema = db
          .prepare(
            "SELECT sql FROM sqlite_master WHERE type='table' AND name=?"
          )
          .get(table);
        if (schema && schema.sql) {
          lines.push(`${schema.sql};`);
          lines.push("");
        }

        // Data
        const rows = db.prepare(`SELECT * FROM "${table}"`).all();
        for (const row of rows) {
          const cols = Object.keys(row)
            .map((c) => `"${c}"`)
            .join(", ");
          const vals = Object.values(row)
            .map((v) => {
              if (v === null) return "NULL";
              if (typeof v === "number") return String(v);
              return `'${String(v).replace(/'/g, "''")}'`;
            })
            .join(", ");
          lines.push(`INSERT INTO "${table}" (${cols}) VALUES (${vals});`);
        }
        lines.push("");
      }

      // Indexes
      const indexes = db
        .prepare(
          "SELECT sql FROM sqlite_master WHERE type='index' AND sql IS NOT NULL ORDER BY name"
        )
        .all();
      for (const idx of indexes) {
        lines.push(`${idx.sql};`);
      }
      lines.push("");
      lines.push("COMMIT;");

      fs.writeFileSync(dumpPath, lines.join("\n"), "utf-8");

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              success: true,
              path: dumpPath,
              tables: tables.length,
              size: fs.statSync(dumpPath).size,
            }),
          },
        ],
      };
    } catch (err) {
      return {
        content: [
          { type: "text", text: JSON.stringify({ error: err.message }) },
        ],
        isError: true,
      };
    }
  }
);

// --- Start server ---
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  process.stderr.write("career-pipeline MCP server running on stdio\n");
}

main().catch((err) => {
  process.stderr.write(`Fatal error: ${err.message}\n`);
  process.exit(1);
});
