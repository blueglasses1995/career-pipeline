---
description: Generate a CV/resume from your career database (markdown or JSON, en/ja)
---

You are generating a professional CV/resume from the user's Career Pipeline database.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine default language. Default to English.
2. Parse flags from the user's input:
   - `--lang ja|en` : Override language setting (default: from settings.json)
   - `--format markdown|json` : Output format (default: markdown)
   - `--full` : Include all cv_include=1 tasks with maximum detail
   - `--brief` : Compact version with key highlights only

## Data Loading

### Profile
```sql
SELECT key, value FROM profile
```
Extract: name, title, email, github, linkedin, summary, etc.

### Skills summary
```sql
SELECT s.name, s.category, COUNT(ts.task_id) as usage_count,
  GROUP_CONCAT(DISTINCT ts.usage_depth) as depths
FROM skills s
JOIN task_skills ts ON s.id = ts.skill_id
JOIN tasks t ON ts.task_id = t.id
WHERE t.cv_include = 1
GROUP BY s.id
ORDER BY usage_count DESC
```

### Projects with tasks
```sql
SELECT p.id, p.company, p.company_description, p.role, p.team_size,
  p.period_start, p.period_end, p.project_summary, p.cv_order
FROM projects p
WHERE p.cv_include = 1
ORDER BY COALESCE(p.cv_order, 999), p.period_start DESC
```

For each project, fetch tasks:
```sql
SELECT t.id, t.title, t.summary, t.phase, t.difficulty, t.period_start, t.period_end
FROM tasks t
WHERE t.project_id = '<project_id>' AND t.cv_include = 1
ORDER BY t.period_start
```

### CV entries (polished versions)
```sql
SELECT ce.content, ce.version
FROM cv_entries ce
WHERE ce.task_id = <task_id> AND ce.lang = '<lang>'
ORDER BY ce.version DESC LIMIT 1
```

### Key decisions per task
```sql
SELECT d.title, d.conclusion, d.reasoning
FROM decisions d WHERE d.task_id = <task_id>
```

### Key outcomes per task
```sql
SELECT o.type, o.before_state, o.after_state, o.metric, o.scope
FROM outcomes o WHERE o.task_id = <task_id>
```

### Contributions per task
```sql
SELECT c.action_type, c.description, c.versus_team
FROM contributions c WHERE c.task_id = <task_id>
```

### STAR stories (if available)
```sql
SELECT ss.situation, ss.task_description, ss.action, ss.result, ss.target_question
FROM star_stories ss
WHERE ss.task_id = <task_id> AND ss.lang = '<lang>'
```

## Output Generation

### Markdown format

Generate a structured CV with these sections:

```markdown
# [Name]

[Title/Role] | [Contact info]

## Summary
[Professional summary from profile, or generate from data]

## Skills
[Group by category: Frontend, Backend, Infra, etc.]
[Show skill names with usage depth indicators]

## Professional Experience

### [Company] - [Role]
[Period] | Team size: [N]

[Project summary]

#### [Task Title]
[If cv_entry exists, use polished version]
[Otherwise, generate from: summary + key decisions + outcomes + contributions]

**Key achievements:**
- [Outcomes with before/after metrics]
- [Significant decisions and their impact]

**Technologies:** [Skills from task_skills]
```

### JSON format

Output a structured JSON object:
```json
{
  "profile": { ... },
  "skills": [ { "name": "", "category": "", "usage_count": 0 } ],
  "experience": [
    {
      "company": "",
      "role": "",
      "period": "",
      "summary": "",
      "tasks": [
        {
          "title": "",
          "description": "",
          "achievements": [],
          "technologies": []
        }
      ]
    }
  ]
}
```

## Guidelines

- If `cv_entries` exist for a task in the requested language, use the polished version. Otherwise, generate from raw data (decisions, outcomes, contributions).
- Quantitative outcomes should be highlighted prominently (e.g., "Reduced API response time from 2s to 200ms").
- Contributions should clearly distinguish the user's personal role from team work.
- For Japanese output, use professional keigo-style language appropriate for a Japanese resume (shokumu-keireki-sho).
- For English output, use standard professional CV language with action verbs.
- If the database has very little data, warn the user and suggest running `/update-task` to add more experience before generating.
- After generating, suggest: "You can polish individual entries with `/review-career --cv-ready` and regenerate."
