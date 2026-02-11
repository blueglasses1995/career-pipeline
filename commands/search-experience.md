---
description: Search past experience by keyword, skill, tag, or natural language query
---

You are helping the user search their career experience database to find relevant past work.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist.
2. Respond in the user's preferred language.

## Input

The user may provide:
- A keyword or phrase (e.g., "performance optimization", "React migration")
- A skill name (e.g., "TypeScript", "Docker")
- A tag (e.g., "architecture", "security")
- A natural language question (e.g., "When did I work with GraphQL?", "What challenges did I face with database performance?")
- No input (show an overview / prompt for a query)

If no query was provided with the command invocation, ask what they want to search for.

## Search Strategy

### 1. Keyword search via career_search

Use the `career_search` MCP tool with the user's query. This performs full-text search across decisions, challenges, tasks, and raw_notes.

### 2. Structured queries via career_read

Run targeted queries based on what the user is looking for:

**By skill:**
```sql
SELECT t.id, t.title, t.summary, p.company, p.role, s.name as skill_name, ts.usage_depth
FROM task_skills ts
JOIN tasks t ON ts.task_id = t.id
JOIN projects p ON t.project_id = p.id
JOIN skills s ON ts.skill_id = s.id
WHERE s.name LIKE '%<query>%'
ORDER BY t.period_start DESC
```

**By tag (decisions):**
```sql
SELECT d.id, d.title, d.context, d.conclusion, t.title as task_title, p.company
FROM decision_tags dt
JOIN decisions d ON dt.decision_id = d.id
JOIN tasks t ON d.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE dt.tag LIKE '%<query>%'
```

**By tag (challenges):**
```sql
SELECT c.id, c.title, c.symptom, c.resolution, t.title as task_title, p.company
FROM challenge_tags ct
JOIN challenges c ON ct.challenge_id = c.id
JOIN tasks t ON c.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE ct.tag LIKE '%<query>%'
```

**By project/company:**
```sql
SELECT p.id, p.company, p.role, p.period_start, p.period_end, p.project_summary,
  (SELECT COUNT(*) FROM tasks WHERE project_id = p.id) as task_count
FROM projects p
WHERE p.company LIKE '%<query>%' OR p.id LIKE '%<query>%'
```

**By difficulty:**
```sql
SELECT t.id, t.title, t.summary, t.difficulty, p.company
FROM tasks t JOIN projects p ON t.project_id = p.id
WHERE t.difficulty = '<query>'
ORDER BY t.period_start DESC
```

### 3. Combine and deduplicate

Merge results from keyword search and structured queries. Remove duplicates by entity ID.

## Presentation

For each result, show contextual detail:

**Task results:**
- Task title and summary
- Project context (company, role, period)
- Skills used
- Number of associated decisions, challenges, outcomes

**Decision results:**
- Decision title and conclusion
- Context and reasoning
- Options considered (brief)
- Tags
- Parent task and project

**Challenge results:**
- Challenge title and symptom
- Resolution
- Difficulty and time spent
- Key debugging steps
- Parent task and project

**Outcome results:**
- Before/after states
- Metrics
- Scope
- Parent task and project

## Follow-up

After showing results, offer:
- "Would you like more detail on any of these?"
- "Should I search with different terms?"
- "Would you like to use this for interview practice? Try `/interview-practice --topic <tag>`"

If no results found:
- Suggest alternative search terms
- Check if the query matches any skill names, tags, or project IDs using targeted career_read queries
- Suggest using `/update-task` to add the experience if it's not yet recorded
