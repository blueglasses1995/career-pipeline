---
description: Career analysis (diagnosis, skill gap) from your career database
---

You are analyzing the user's career data from the Career Pipeline database. The `--type` flag determines the analysis mode.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.
3. Parse the `--type` flag (required):
   - `--type diagnosis` : Comprehensive career diagnosis (strengths, patterns, growth areas)
   - `--type skill-gap` : Skill gap analysis against a target role

If `--type` is not provided, ask the user which analysis they want.

---

## Type: diagnosis

Comprehensive multi-dimensional career diagnosis.

### Additional flags
- `--focus strengths|weaknesses|patterns|all` (default: `all`)
- `--depth quick|thorough` (default: `thorough`)

### Data loading

Use `career_read` to gather data across all tables:

**Projects & Tasks:**
```sql
SELECT p.id, p.company, p.role, p.team_size, p.period_start, p.period_end, p.project_type,
  COUNT(t.id) AS task_count
FROM projects p LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id ORDER BY p.period_start DESC
```

**Skills with depth and recency:**
```sql
SELECT s.name, s.category,
  MAX(CASE ts.usage_depth
    WHEN 'designed' THEN 4 WHEN 'configured' THEN 3
    WHEN 'evaluated' THEN 2 WHEN 'used' THEN 1 END) AS depth_score,
  COUNT(DISTINCT t.id) AS task_count, MAX(t.period_end) AS last_used
FROM skills s
JOIN task_skills ts ON s.id = ts.skill_id
JOIN tasks t ON ts.task_id = t.id
GROUP BY s.id
```

**Decisions (with option counts and tags):**
```sql
SELECT d.id, d.title, d.tradeoffs, d.validation,
  GROUP_CONCAT(DISTINCT dt.tag) AS tags,
  COUNT(DISTINCT do2.id) AS options_count
FROM decisions d
LEFT JOIN decision_tags dt ON d.id = dt.decision_id
LEFT JOIN decision_options do2 ON d.id = do2.decision_id
GROUP BY d.id
```

**Challenges (with step counts and dead ends):**
```sql
SELECT c.id, c.title, c.difficulty, c.root_cause,
  COUNT(cs.id) AS step_count,
  SUM(CASE WHEN cs.was_dead_end = 1 THEN 1 ELSE 0 END) AS dead_end_count
FROM challenges c
LEFT JOIN challenge_steps cs ON c.id = cs.challenge_id
GROUP BY c.id
```

**Outcomes, Contributions, Stakeholder Interactions:**
```sql
SELECT type, scope FROM outcomes
```
```sql
SELECT action_type FROM contributions
```
```sql
SELECT COUNT(*) as count FROM stakeholder_interactions
```

### Analysis dimensions

**Technical Profile:**
- Dominant skill categories, depth distribution, breadth vs depth (T-shaped/generalist/specialist)

**Decision-Making Style:**
- Average options per decision, most frequent tags, tradeoff documentation rate, validation rate

**Problem-Solving Capability:**
- Difficulty distribution, dead-end resilience ratio, average steps to resolution, root cause identification rate

**Impact Profile:**
- Quantitative vs qualitative outcome ratio, scope distribution (team/product/user/company)

**Leadership & Collaboration:**
- Contribution type distribution (proposed/decided vs implemented), stakeholder diversity, team size range

**Career Trajectory:**
- Role progression over time, project type diversity, complexity trend

### Report format

- **Executive Summary**: 2-3 sentences with strongest differentiator
- **Strengths**: 3-5, each backed by specific DB evidence with numbers
- **Growth Areas**: 2-4, each backed by specific DB evidence
- **Patterns & Insights**: Non-obvious patterns in the data
- **Actionable Recommendations**: 3-5 concrete next steps

For `--depth quick`: Executive summary + top 3 strengths + top 3 growth areas + top 3 recommendations only.

Check `career_goals` table and add goal progress section if goals exist.

---

## Type: skill-gap

Skill gap analysis against a target role or job posting.

### Additional flags
- `--role [target role]` : Target role title (e.g., "Staff Engineer", "Engineering Manager")
- `--compare [job posting URL or pasted text]` : Parse a job posting for requirements

### Load current skill profile

```sql
SELECT s.id, s.name, s.category,
  MAX(CASE ts.usage_depth
    WHEN 'designed' THEN 4 WHEN 'configured' THEN 3
    WHEN 'evaluated' THEN 2 WHEN 'used' THEN 1 END) AS depth_score,
  COUNT(DISTINCT t.id) AS task_count,
  COUNT(DISTINCT p.id) AS project_count,
  MAX(t.period_end) AS last_used
FROM skills s
JOIN task_skills ts ON s.id = ts.skill_id
JOIN tasks t ON ts.task_id = t.id
JOIN projects p ON t.project_id = p.id
GROUP BY s.id ORDER BY depth_score DESC, task_count DESC
```

### Determine target requirements

Resolution order:
1. **career_goals table** (if exists and no flags provided)
2. **--role flag**: Use Claude's industry knowledge for typical requirements (label as "typical expectations")
3. **--compare flag**: Parse job posting for required/preferred skills
4. **Interactive**: Ask user for target role or job posting

### Gap analysis

Categorize skills into 4 buckets:

- **Match**: Current depth >= required depth. Show evidence (task count, projects, last used).
- **Needs deepening**: Have the skill but at lower depth. Show gap size and what deepening means concretely.
- **Missing entirely**: Not in DB at all. Note related/adjacent skills that could accelerate learning.
- **Bonus**: Skills you have that aren't required but add value.

### Match score

Weighted average: required skills weight=3, preferred weight=1.
- Fully matched: 100%
- Partially matched: (current_depth / required_depth) * 100
- Missing: 0%

Context: 80-100% strong, 60-79% moderate, 40-59% partial, <40% stretch.

### Action plan

For each gap, produce:

| Skill | Gap | Suggested Action | Effort | Priority |
|-------|-----|-----------------|--------|----------|

Effort: Small (1-2 weeks), Medium (1-3 months), Large (3-6+ months).
Actions: seek task at work, side project, OSS contribution, course, write about it, pair with expert.

### Save goals

After analysis, offer to save gaps to `career_goals` table. Check for duplicates first. Confirm before writing.

---

## Guidelines

- Always use `career_read` to fetch data. Never fabricate information.
- Every assessment must be backed by concrete DB evidence with numbers.
- If the database has very little data, acknowledge limitations and suggest using `/update-task` or `/import-cv` first.
- Keep tone constructive, especially for weaknesses and gaps.
- Support both English and Japanese output based on settings.
- This command is primarily read-only. Only write to `career_goals` if explicitly approved by user.
- Provide actionable, specific recommendations, not vague advice.
