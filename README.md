# career-pipeline

A Claude Code plugin that continuously captures your engineering decisions and work into a structured SQLite database, then generates polished CVs, blog posts, interview prep, and career analytics on demand.

```
Event --> Record --> Knowledge --> Render
```

---

## The Problem

Career documentation follows a disconnected, batch workflow:

1. **Work** -- You build features, solve problems, make technical decisions.
2. **Recall** -- Months or years later, you try to remember what you did.
3. **Document** -- You manually write up your experience for a CV.

Each stage loses information. By the time you write your CV, the rich context of your decisions, challenges, and contributions has faded.

## The Solution: Continuous Career Delivery

**career-pipeline** integrates career documentation directly into your development workflow. Capture structured data as you work, build queryable knowledge continuously, render polished outputs on demand.

| Stage         | What happens                                                                                                           |
|---------------|------------------------------------------------------------------------------------------------------------------------|
| **Event**     | Your daily engineering work -- technical decisions, debugging sessions, architecture discussions.                       |
| **Record**    | Structured data captured in real-time. Decisions with alternatives and tradeoffs. Challenges with debugging steps.     |
| **Knowledge** | A queryable database of your career. Search by skill, decision type, or challenge pattern across projects and years.   |
| **Render**    | Generate CVs, blog posts, LinkedIn updates, talk proposals -- all from the same source of truth, in any language.      |

---

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- macOS or Linux
- Node.js 18+

## Installation

```
/plugin marketplace add blueglasses1995/ekacari
/plugin install career-pipeline@ekacari
```

Restart Claude Code after installation.

## Getting Started

```
# 1. Import your existing CV (bootstrap)
/import-cv

# 2. Record a task from your current project
/update-task

# 3. Generate a CV
/cv-generate --lang en --format markdown
```

---

## Output Example

`/cv-generate` produces structured output like:

```markdown
# Jane Doe
Full-Stack Engineer

## Skills
**Backend**: Go (designed), Python (configured), Ruby (used)
**Frontend**: React (designed), Vue.js (configured)
**Infra**: GCP (designed), Kubernetes (configured), Terraform (used)

## Professional Experience

### Acme Inc. - Backend Engineer
Apr 2023 - Mar 2025 | Team size: 8

#### Real-time Notification Service
Designed a pub/sub notification system handling 50K messages/min using
Go + Cloud Pub/Sub + WebSocket. Replaced polling-based approach, reducing
notification latency from 30s to under 500ms.

**Key decision**: Chose Cloud Pub/Sub over self-hosted Kafka to reduce
operational burden for a 3-person infra team.
**Technologies**: Go, GCP Cloud Pub/Sub, WebSocket, Redis, PostgreSQL
```

---

## Commands

11 slash commands organized into five categories.

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

**Example -- interview practice:**

```
/interview-practice
> "Tell me about a time you made a difficult technical decision."

Uses your actual decisions from the database to generate STAR-format
responses with real context, actions, and measurable results.
```

### Content Generation

| Command    | Description                                                            |
|------------|------------------------------------------------------------------------|
| `/render`  | Generate content: `--target blog\|linkedin\|talk\|podcast`            |

```
/render --target blog --format draft --tone technical
/render --target linkedin --type achievement
/render --target talk --format proposal --duration 30
/render --target podcast --format outline --style solo
```

### Career Analytics

| Command             | Description                                         |
|---------------------|-----------------------------------------------------|
| `/career-timeline`  | Visualize career timeline.                          |
| `/tech-radar`       | Personal technology radar (Adopt/Trial/Assess/Hold).|
| `/analyze`          | Career analysis: `--type diagnosis\|skill-gap`      |

```
/analyze --type diagnosis --depth thorough
/analyze --type skill-gap --role "Staff Engineer"
```

### Maintenance

| Command        | Description                                |
|----------------|--------------------------------------------|
| `/sync-check`  | Check data consistency across machines.    |

---

## MCP Tools

Five MCP tools for programmatic access:

| Tool              | Description                                      |
|-------------------|--------------------------------------------------|
| `career_read`     | Execute SELECT queries on the career database.   |
| `career_write`    | Execute INSERT/UPDATE/DELETE operations.          |
| `career_search`   | Full-text search across all career data.         |
| `career_stats`    | Retrieve aggregate statistics and summaries.     |
| `career_dump`     | Export the full dataset for backup or migration.  |

---

## Database

SQLite with WAL mode. 21 tables at schema version 2. Data stored at `~/.career-pipeline/`, separate from plugin code.

**Core tables:**

| Table           | Purpose                                      |
|-----------------|----------------------------------------------|
| `projects`      | Companies, roles, periods, team size         |
| `tasks`         | Individual work items within projects        |
| `skills`        | Technology/skill master with categories      |
| `decisions`     | Technical decisions with context and reasoning |
| `challenges`    | Problems solved with debugging steps         |
| `outcomes`      | Measurable results (before/after metrics)    |
| `contributions` | Your specific role vs team                   |
| `content_ideas` | Blog/talk/podcast topic pipeline             |
| `career_goals`  | Target roles and desired skill depths        |

---

## Hooks

- **SessionStart**: Database initialization and new project detection (work/personal/OSS tracking).
- **PreCompact**: Auto-capture conversation snapshots before context trimming.

## Multi-machine Support

- **Plugin code**: Distributed through the ekacari marketplace. Install on each machine with the same commands.
- **Data directory** (`~/.career-pipeline/`): Local to each machine. Sync using your preferred method.
- **`/sync-check`**: Verifies data consistency across machines.

---

## Author

[@blueglasses1995](https://github.com/blueglasses1995)

## License

MIT
