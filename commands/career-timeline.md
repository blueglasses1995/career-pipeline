---
description: Generate a visual career timeline showing projects, skills, and growth over time
---

Generate a career timeline visualization from the user's project, skill, and milestone data stored in the DB.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.

## Step 1: Parse flags

Accept the following optional flags from the user's input:

- `--scope all|work|personal|oss` (default: `all`)
- `--detail low|medium|high` (default: `medium`)
- `--format text|mermaid|json` (default: `text`)

## Step 2: Load all projects and tasks with dates

Query projects filtered by scope, along with task counts:

```sql
SELECT p.id, p.company, p.role, p.period_start, p.period_end, p.project_type,
  p.team_size, p.project_summary,
  COUNT(t.id) AS task_count
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
WHERE (p.project_type = '<scope>' OR '<scope>' = 'all')
GROUP BY p.id
ORDER BY p.period_start
```

## Step 3: Load skill evolution over time

Query the progression of skills across projects and tasks:

```sql
SELECT s.name, s.category, ts.usage_depth, t.period_start, p.company
FROM task_skills ts
JOIN skills s ON ts.skill_id = s.id
JOIN tasks t ON ts.task_id = t.id
JOIN projects p ON t.project_id = p.id
ORDER BY t.period_start
```

Build a skill-evolution map showing how each skill's `usage_depth` changed over time (used -> configured -> designed -> evaluated).

## Step 4: Load key milestones

Query significant events to annotate on the timeline:

1. **Major decisions**:
   ```sql
   SELECT d.title, d.conclusion, t.period_start, p.company
   FROM decisions d
   JOIN tasks t ON d.task_id = t.id
   JOIN projects p ON t.project_id = p.id
   ORDER BY t.period_start
   ```

2. **Significant outcomes**:
   ```sql
   SELECT o.type, o.metric, o.before_state, o.after_state, o.scope,
     t.period_start, p.company
   FROM outcomes o
   JOIN tasks t ON o.task_id = t.id
   JOIN projects p ON t.project_id = p.id
   ORDER BY t.period_start
   ```

3. **High-difficulty challenges**:
   ```sql
   SELECT c.title, c.difficulty, c.resolution, t.period_start, p.company
   FROM challenges c
   JOIN tasks t ON c.task_id = t.id
   JOIN projects p ON t.project_id = p.id
   WHERE c.difficulty >= 4
   ORDER BY t.period_start
   ```

## Step 5: Generate timeline based on format

### If `--format text`

Generate an ASCII/Unicode timeline:

- Use vertical or horizontal layout depending on the number of projects
- Show each project as a labeled block with start/end dates
- Mark key milestones (decisions, outcomes, challenges) as annotated points
- Include skill acquisition markers at the point each skill first appears
- At `--detail high`, include task-level entries within each project block
- At `--detail low`, show only project bars and role changes

Example structure:
```
2020 ──┬── Company A | Backend Engineer
       │   ├── [Decision] Migrated to microservices
       │   └── [Outcome] Latency reduced 40%
2021 ──┤
       │
2022 ──┼── Company B | Senior Engineer
       │   ├── [Challenge] Production memory leak
       │   └── [Outcome] Team velocity +25%
2023 ──┤
```

### If `--format mermaid`

Generate a Mermaid gantt diagram:

```
gantt
    title Career Timeline
    dateFormat YYYY-MM-DD

    section Company A
    Backend Engineer  :a1, 2020-04-01, 2022-03-31

    section Company B
    Senior Engineer   :a2, 2022-04-01, 2024-03-31
```

- Each project becomes a section
- Tasks become entries within sections (at `--detail medium` or `high`)
- Use milestone markers for key decisions and outcomes
- Include skill-category swimlanes at `--detail high`

### If `--format json`

Generate structured JSON suitable for external visualization tools:

```json
{
  "timeline": {
    "start": "2020-04-01",
    "end": "2024-12-31",
    "projects": [...],
    "milestones": [...],
    "skill_evolution": [...],
    "statistics": {...}
  }
}
```

Include all loaded data in a well-structured, documented schema.

## Step 6: Add annotations

Enrich the timeline with contextual annotations:

- **Role changes**: Mark transitions between roles or companies
- **Skill depth upgrades**: Highlight when a skill moved to a deeper usage level (e.g., "used" to "designed")
- **Significant outcomes**: Call out notable quantitative improvements
- **Team size changes**: Note shifts in team scale

## Step 7: Generate summary statistics

Compute and display career-wide statistics:

- Total years of experience (from earliest `period_start` to latest `period_end`)
- Number of projects by type (work, personal, OSS)
- Top skills by frequency and depth
- Average project duration
- Career progression narrative (role titles over time)
- Technology category distribution (from `skills.category`)

Use `career_stats` where possible, supplemented by custom queries.

## Step 8: Suggest patterns and gaps

Analyze the timeline data to surface insights:

- Identify career pivots (e.g., "You shifted from frontend to backend around 2022")
- Highlight skills that plateaued at a certain depth
- Note gaps in the timeline (periods without projects)
- Suggest areas for growth based on `career_goals` if available:
  ```sql
  SELECT cg.target_role, s.name AS skill, cg.desired_depth, cg.priority, cg.notes
  FROM career_goals cg
  LEFT JOIN skills s ON cg.skill_id = s.id
  ORDER BY cg.priority
  ```
- Compare current skill profile against goal requirements

## Guidelines

- Always confirm before writing to the DB.
- Use `career_read` to check existing data before inserting duplicates.
- Keep output actionable and professional.
- Ground every element in real data from the DB -- do not fabricate dates, metrics, or experiences.
- For text format, ensure the timeline renders correctly in monospace fonts.
- For mermaid format, validate syntax so it can be pasted directly into a Mermaid renderer.
- For JSON format, use consistent key naming and include a brief schema description.
- For Japanese output, use natural professional language appropriate for career documentation.
