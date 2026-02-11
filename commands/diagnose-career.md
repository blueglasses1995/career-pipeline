---
description: Run a comprehensive career diagnosis analyzing strengths, patterns, and growth areas
---

Perform a multi-dimensional career diagnosis by analyzing the user's full history of projects, skills, decisions, challenges, outcomes, contributions, and stakeholder interactions stored in the database.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.

## Step 1: Parse Flags

Accept the following optional flags from the user's input:

- `--focus strengths|weaknesses|patterns|all` (default: `all`) -- Narrow the diagnosis to a specific dimension.
- `--depth quick|thorough` (default: `thorough`) -- `quick` produces a summary; `thorough` produces a full report with evidence.

## Step 2: Load Comprehensive Data

Use `career_read` to gather data across all relevant tables. Run the following queries (adjust as needed):

**Projects & Tasks**:
```sql
SELECT p.id, p.company, p.role, p.team_size, p.period_start, p.period_end, p.project_type,
  COUNT(t.id) AS task_count
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id
ORDER BY p.period_start DESC
```

**Skills with depth and recency**:
```sql
SELECT s.name, s.category,
  MAX(CASE ts.usage_depth
    WHEN 'designed' THEN 4 WHEN 'configured' THEN 3
    WHEN 'evaluated' THEN 2 WHEN 'used' THEN 1 END) AS depth_score,
  COUNT(DISTINCT t.id) AS task_count,
  MAX(t.period_end) AS last_used
FROM skills s
JOIN task_skills ts ON s.id = ts.skill_id
JOIN tasks t ON ts.task_id = t.id
GROUP BY s.id
```

**Decisions**:
```sql
SELECT d.id, d.title, d.context, d.conclusion, d.reasoning, d.tradeoffs, d.validation,
  GROUP_CONCAT(DISTINCT dt.tag) AS tags,
  COUNT(DISTINCT do2.id) AS options_count
FROM decisions d
LEFT JOIN decision_tags dt ON d.id = dt.decision_id
LEFT JOIN decision_options do2 ON d.id = do2.decision_id
GROUP BY d.id
```

**Challenges**:
```sql
SELECT c.id, c.title, c.difficulty, c.root_cause, c.resolution, c.impact, c.time_spent,
  COUNT(cs.id) AS step_count,
  SUM(CASE WHEN cs.was_dead_end = 1 THEN 1 ELSE 0 END) AS dead_end_count
FROM challenges c
LEFT JOIN challenge_steps cs ON c.id = cs.challenge_id
GROUP BY c.id
```

**Outcomes**:
```sql
SELECT o.type, o.before_state, o.after_state, o.metric, o.scope
FROM outcomes o
```

**Contributions**:
```sql
SELECT co.action_type, co.description, co.versus_team
FROM contributions co
```

**Stakeholder Interactions**:
```sql
SELECT si.*
FROM stakeholder_interactions si
```

If `--depth quick`, limit each query with appropriate LIMIT clauses or sample representative records.

## Step 3: Analyze Dimensions

Analyze the loaded data across six dimensions. For each dimension, compute concrete metrics and identify notable patterns.

### 3a. Technical Profile

- **Dominant categories**: Which skill categories have the most tasks? Is the user frontend-heavy, backend-heavy, full-stack, or infra-focused?
- **Depth distribution**: What percentage of skills are at each depth level (used / configured / designed / evaluated)? A healthy senior profile has a significant proportion at "designed" level.
- **Breadth vs. depth score**: Count of distinct skill categories (breadth) vs. average depth score across all skills (depth). Characterize the profile as "T-shaped", "generalist", "specialist", etc.

### 3b. Decision-Making Style

- **Options considered**: Average number of `decision_options` per decision. More options suggest thorough evaluation.
- **Domain spread**: Most frequent decision tags. Does the user make mostly architectural decisions? Tooling choices? Process decisions?
- **Tradeoff awareness**: Percentage of decisions where `tradeoffs` is non-empty. Higher is better.
- **Validation discipline**: Percentage of decisions where `validation` is non-empty. Indicates follow-through.

### 3c. Problem-Solving Capability

- **Difficulty distribution**: Histogram of challenge difficulties. Indicate whether the user tackles mostly easy, medium, or hard problems.
- **Dead-end resilience**: Ratio of dead-end steps to total steps across all challenges. A moderate ratio shows persistence and learning; zero may indicate only recording simple problems.
- **Resolution efficiency**: Average steps to resolution. Lower can mean efficiency; higher with successful resolution shows tenacity.
- **Root cause identification**: Percentage of challenges with a documented `root_cause`. Higher indicates analytical rigor.

### 3d. Impact Profile

- **Outcome type balance**: Ratio of quantitative vs. qualitative outcomes. Strong candidates have both.
- **Scope distribution**: Count outcomes by `scope` (team / product / user / company). Wider scope indicates senior-level impact.
- **Before/after clarity**: Note whether before_state and after_state are well-documented -- this shows the ability to articulate impact.

### 3e. Leadership & Collaboration

- **Contribution action types**: Distribution of `action_type` values (e.g., proposed, decided, implemented, reviewed, mentored). More "proposed" and "decided" suggest leadership; more "implemented" suggests execution focus.
- **Versus-team positioning**: Analyze `versus_team` to understand how the user frames their contributions relative to the team.
- **Stakeholder diversity**: Count of unique stakeholder types and interaction frequency. Broader engagement suggests stronger communication skills.
- **Team size range**: Range of `team_size` across projects. Experience with varied team sizes shows adaptability.

### 3f. Career Trajectory

- **Role progression**: List roles over time from projects. Identify upward movement (IC -> senior -> lead -> manager).
- **Project type diversity**: Distribution of `project_type` (work / personal / OSS). Side projects and OSS contributions show initiative.
- **Complexity trend**: Plot task difficulty over time. An upward trend indicates growth; flat may indicate a plateau.

## Step 4: Generate Diagnosis Report

Compose the report with these sections:

### Executive Summary
2-3 sentences capturing the most important findings. Lead with the user's strongest differentiator.

### Strengths (with evidence)
List 3-5 key strengths. Each MUST cite specific data from the DB:
- "Strong architectural decision-making: 85% of your 20 decisions document tradeoffs, well above typical."
- "Deep Kubernetes expertise: designed-level usage across 4 projects over 3 years."

### Growth Areas (with evidence)
List 2-4 areas for improvement. Each MUST cite specific data:
- "Limited outcome documentation: only 30% of tasks have associated outcomes. Capturing metrics strengthens your narrative."
- "Narrow stakeholder engagement: interactions are predominantly with engineering peers. Broadening to product/business stakeholders would demonstrate cross-functional skills."

### Patterns & Insights
Highlight non-obvious patterns discovered in the data:
- Seasonal trends in activity
- Correlation between project types and skill growth
- Decision-making evolution over time

### Actionable Recommendations
Provide 3-5 specific, concrete next steps ranked by impact:
1. "Document tradeoffs for your last 3 undocumented decisions using `update-task`."
2. "Your debugging stories around [X] are compelling -- consider turning them into a blog post using `talk-generate`."
3. "Add quantitative outcomes to your recent [Y] project tasks."

## Step 5: Career Goal Alignment

Check for existing career goals:

```sql
SELECT cg.target_role, s.name, cg.desired_depth, cg.priority, cg.notes
FROM career_goals cg
LEFT JOIN skills s ON cg.skill_id = s.id
ORDER BY cg.priority ASC
```

If goals exist, add a "Goal Progress" section:
- For each goal, assess current state vs. desired state based on the diagnosis.
- Flag goals that are on track, at risk, or not started.

If no goals exist, suggest setting goals using the `skill-gap` command.

## Step 6: Suggested Follow-up Actions

Based on the full diagnosis, suggest specific actions the user can take within the career-pipeline system:

- "Run `/tech-radar` to visualize your skill distribution."
- "Run `/skill-gap --role <suggested role>` to plan your next career move."
- "Use `/update-task` to backfill missing outcomes on high-impact tasks."
- "Consider writing about [specific strong area] using `/talk-generate`."

## Guidelines

- Always use `career_read` to fetch data; never assume or fabricate information.
- Every strength and growth area MUST be backed by concrete DB evidence with numbers.
- When the database has very little data, acknowledge limitations honestly and recommend what to record next rather than making thin conclusions.
- Keep the tone constructive and forward-looking, especially for growth areas.
- For `--depth quick`, produce a concise version: executive summary + top 3 strengths + top 3 growth areas + top 3 recommendations.
- For `--depth thorough`, produce the full report with all six dimensions.
- Support both English and Japanese output based on settings.
- Do not write to the database in this command; it is read-only.
- Provide actionable, specific recommendations rather than vague advice.
