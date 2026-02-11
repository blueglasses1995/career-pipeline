---
description: Generate a personal technology radar showing skill adoption, maturity, and trends
---

Generate a Technology Radar inspired by ThoughtWorks, classifying the user's skills into Adopt / Trial / Assess / Hold rings based on actual usage data.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.

## Step 1: Parse Flags

Accept the following optional flags from the user's input:

- `--scope all|work|personal` (default: `all`) -- Filter projects by `project_type`.
- `--format text|json|mermaid` (default: `text`) -- Output format.
- `--since YYYY` -- Only consider tasks/projects starting from this year onward.

## Step 2: Load Skill Usage Data

Use `career_read` to query all skills with aggregated usage information:

```sql
SELECT s.id, s.name, s.category,
  COUNT(DISTINCT t.id) AS task_count,
  COUNT(DISTINCT p.id) AS project_count,
  GROUP_CONCAT(DISTINCT ts.usage_depth) AS depths,
  MAX(t.period_end) AS last_used,
  MIN(t.period_start) AS first_used
FROM skills s
JOIN task_skills ts ON s.id = ts.skill_id
JOIN tasks t ON ts.task_id = t.id
JOIN projects p ON t.project_id = p.id
GROUP BY s.id
ORDER BY task_count DESC
```

Apply scope and since filters by adding appropriate WHERE clauses:

- If `--scope` is `work` or `personal`, add `WHERE p.project_type = '<scope>'`.
- If `--since` is provided, add `WHERE t.period_start >= '<YYYY>-01-01'`.

## Step 3: Classify Skills into Radar Rings

For each skill, determine its ring using these rules evaluated in order:

| Ring       | Criteria                                                                                         |
|------------|--------------------------------------------------------------------------------------------------|
| **Adopt**  | `depths` includes `designed` AND `project_count >= 2` AND `last_used` within the last 18 months  |
| **Trial**  | `last_used` within the last 12 months AND (`depths` includes `configured` OR `project_count = 1`)|
| **Assess** | `depths` is only `used` OR `project_count = 1` with no deep usage (`designed`/`configured`)      |
| **Hold**   | `last_used` is more than 18 months ago                                                           |

If a skill does not clearly fit one ring, use the best match and note the ambiguity internally.

## Step 4: Generate Radar Visualization

Produce output in the requested `--format`:

### Text (default)

Print a table grouped first by ring (Adopt > Trial > Assess > Hold), then by `category` within each ring. Include columns: Skill Name, Category, Projects, Tasks, Deepest Usage, Last Used.

### JSON

Output a structured JSON object compatible with external radar tools (e.g., tech-radar.io):

```json
{
  "title": "Personal Technology Radar",
  "date": "<today>",
  "rings": [
    { "id": "adopt", "name": "Adopt", "color": "#5ba300" },
    { "id": "trial", "name": "Trial", "color": "#009eb0" },
    { "id": "assess", "name": "Assess", "color": "#c7ba00" },
    { "id": "hold", "name": "Hold", "color": "#e09b96" }
  ],
  "quadrants": [
    { "id": "<category>", "name": "<Category>" }
  ],
  "entries": [
    {
      "id": "<skill_id>",
      "title": "<skill_name>",
      "quadrant": "<category>",
      "ring": "<ring>",
      "description": "<task_count> tasks across <project_count> projects, last used <last_used>"
    }
  ]
}
```

### Mermaid

Generate a Mermaid quadrant chart. Map the top 4 skill categories to quadrants. Place skills by mapping ring to the y-axis (Adopt=top, Hold=bottom) and task count to the x-axis.

```
quadrantChart
    title Personal Technology Radar
    x-axis Low Usage --> High Usage
    y-axis Hold --> Adopt
    quadrant-1 <Category 1>
    quadrant-2 <Category 2>
    quadrant-3 <Category 3>
    quadrant-4 <Category 4>
    <Skill Name>: [x, y]
```

## Step 5: Trend Analysis

Analyze skill movement over time and append a "Trends" section:

- **Ring transitions**: Identify skills whose ring classification would differ if you split the data into earlier vs. recent halves (e.g., "React: Assess -> Adopt over 2023-2024").
- **Emerging skills**: Skills whose `first_used` is within the last 12 months.
- **Declining skills**: Skills moving toward Hold (used extensively before but `last_used` is growing stale).

Present these as a concise bulleted list.

## Step 6: Career Goal Alignment

Check whether any career goals exist:

```sql
SELECT cg.target_role, s.name, cg.desired_depth, cg.priority
FROM career_goals cg
JOIN skills s ON cg.skill_id = s.id
ORDER BY cg.priority ASC
```

If goals exist, append a "Goal Alignment" section:

- For each goal skill, show the current ring vs. the desired depth.
- Highlight gaps: e.g., "Kubernetes is currently in **Assess** but your goal requires **designed** depth (Adopt level)."
- Suggest concrete next steps to close each gap.

If no goals exist, mention that the user can set career goals using the `skill-gap` command.

## Guidelines

- Always use `career_read` to fetch data; never assume or fabricate skill information.
- When there are no skills in the database, inform the user and suggest importing data first.
- Keep the radar actionable: after presenting it, offer to drill into any ring or category.
- Support both English and Japanese output based on settings.
- Do not write to the database in this command; it is read-only.
- Provide actionable, specific observations rather than vague summaries.
