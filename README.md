# career-pipeline

Record work experiences, build queryable knowledge, and render CVs, blog posts, LinkedIn profiles, and more.

**Keywords:** cv, resume, interview, career, pipeline

---

## The Problem

Traditionally, career documentation follows a disconnected, batch workflow:

1. **Work** -- You build features, solve problems, make technical decisions.
2. **Recall** -- Months or years later, you try to remember what you did.
3. **Document** -- You manually write up your experience for a CV.
4. **Repeat** -- Every job search, you start this painful process over.

Each stage is a separate process with significant information loss between them. By the time you sit down to write your CV, the rich context of your decisions, challenges, and contributions has faded. You end up with generic descriptions that fail to convey the depth of your engineering work.

## The Solution: Continuous Career Delivery

**career-pipeline** eliminates the gap between doing the work and documenting it.

Instead of treating experience documentation as a separate, downstream task, career-pipeline integrates it directly into your development workflow -- capturing structured career data as you work, building queryable knowledge continuously, and rendering polished outputs on demand.

### The Pipeline Model

```
Event --> Record --> Knowledge --> Render
```

| Stage         | Description                                                                                                                                                                     |
|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Event**     | Your daily engineering work -- technical decisions, debugging sessions, architecture discussions, production incidents, feature implementations.                                 |
| **Record**    | Structured data captured in real-time. Decisions with alternatives and tradeoffs. Challenges with debugging steps and root causes. Outcomes with before/after metrics.           |
| **Knowledge** | A queryable database of your entire engineering career. Search by skill, technology, decision type, or challenge pattern. Connect experiences across projects and years.          |
| **Render**    | Generate CVs, prepare for interviews, write blog posts, craft LinkedIn updates -- all from the same source of truth, in any language or format, on demand.                       |

### Why This Matters

- **No information loss**: Capture decisions and context while they are fresh, not months later.
- **Interview-ready at all times**: Your STAR stories, technical decisions, and impact metrics are always structured and searchable.
- **Continuous, not batch**: Like CI/CD transformed software delivery from periodic releases to continuous deployment, career-pipeline transforms career documentation from periodic rewrites to continuous updates.
- **One source, many outputs**: The same structured data powers your Japanese CV, English resume, interview preparation, blog posts, talk proposals, and skill analysis.

---

## Installation

```
/plugin marketplace add blueglasses1995/ekacari
/plugin install career-pipeline@ekacari
```

---

## Commands

career-pipeline provides 15 slash commands organized into five categories.

### Data Entry

| Command         | Description                                                                  |
|-----------------|------------------------------------------------------------------------------|
| `/import-cv`    | Import existing CV/resume data into the database.                            |
| `/update-task`  | Interactively register or update career data (projects, tasks, decisions, challenges, outcomes). |

### CV and Interview

| Command               | Description                                                      |
|-----------------------|------------------------------------------------------------------|
| `/cv-generate`        | Generate CV/resume (markdown or JSON, en/ja).                    |
| `/review-career`      | Review and polish career entries for CV readiness.               |
| `/interview-practice` | Practice interview questions based on your experience.           |
| `/search-experience`  | Search past experiences by skill, technology, or keyword.        |

### Content Generation (Render Adapters)

| Command              | Description                              |
|----------------------|------------------------------------------|
| `/blog-generate`     | Generate technical blog post drafts.     |
| `/linkedin-generate` | Generate LinkedIn posts.                 |
| `/talk-generate`     | Generate conference talk proposals.      |
| `/podcast-generate`  | Generate podcast episode outlines.       |

### Career Analytics

| Command             | Description                                         |
|---------------------|-----------------------------------------------------|
| `/career-timeline`  | Visualize career timeline.                          |
| `/tech-radar`       | Personal technology radar (Adopt/Trial/Assess/Hold).|
| `/diagnose-career`  | Comprehensive career diagnosis.                     |
| `/skill-gap`        | Skill gap analysis against target roles.            |

### Maintenance

| Command        | Description                                |
|----------------|--------------------------------------------|
| `/sync-check`  | Check data consistency across machines.    |

---

## MCP Tools

Five MCP tools are exposed for programmatic access:

| Tool              | Description                                      |
|-------------------|--------------------------------------------------|
| `career_read`     | Read career records by ID or filter criteria.    |
| `career_write`    | Write or update career records.                  |
| `career_search`   | Full-text search across all career data.         |
| `career_stats`    | Retrieve aggregate statistics and summaries.     |
| `career_dump`     | Export the full dataset for backup or migration.  |

---

## Database

- **Engine**: SQLite with WAL mode enabled for concurrent read performance.
- **Schema**: 21 tables at schema version 2.
- **Data location**: `~/.career-pipeline/`
- **Separation of concerns**: The data directory is entirely separate from the plugin code. This makes it safe to update or reinstall the plugin without affecting your career data, and simplifies multi-machine sync.

---

## Hooks

### SessionStart

Runs on every Claude Code session start. Handles:

- Database initialization (creates the schema if it does not exist).
- New project detection -- automatically tracks whether you are working on a work, personal, or OSS project.

### PreCompact

Runs before conversation compaction. Handles:

- Auto-capture of conversation snapshots so that career-relevant context is preserved even when the conversation history is trimmed.

---

## Multi-machine Support

career-pipeline is designed for developers who work across multiple machines.

- **Plugin code** is distributed through the ekacari marketplace. Install on each machine with the same commands.
- **Data directory** (`~/.career-pipeline/`) is local to each machine. Sync it using your preferred method (cloud storage, rsync, Git, etc.).
- **`/sync-check`** verifies data consistency across machines, flagging conflicts or missing records.

---

## Author

Toshiki Matsukuma

## License

MIT
