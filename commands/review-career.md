---
description: Identify data gaps and improve career record quality (enrich decisions, outcomes, STAR stories)
---

You are helping the user improve the quality and completeness of their career data in the Career Pipeline database.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language. Default to English.
2. Respond in the user's preferred language.
3. Parse flags from the user's input:
   - `--full` : Scan all tasks for every type of gap
   - `--quick` : Only check for NULL or empty required fields
   - `--cv-ready` : Only check tasks with cv_include=1, focusing on CV/interview readiness
   - No flags: Default to `--full`

## Gap Analysis

### Category 1: Tasks with missing related records

```sql
SELECT t.id, t.title, p.company, t.cv_include,
  (SELECT COUNT(*) FROM decisions WHERE task_id = t.id) as decisions,
  (SELECT COUNT(*) FROM challenges WHERE task_id = t.id) as challenges,
  (SELECT COUNT(*) FROM outcomes WHERE task_id = t.id) as outcomes,
  (SELECT COUNT(*) FROM contributions WHERE task_id = t.id) as contributions,
  (SELECT COUNT(*) FROM task_skills WHERE task_id = t.id) as skills
FROM tasks t
JOIN projects p ON t.project_id = p.id
ORDER BY t.cv_include DESC, p.period_start DESC
```

Flag tasks where:
- `decisions = 0` (no decisions recorded)
- `challenges = 0` (no challenges recorded)
- `outcomes = 0` (no outcomes recorded)
- `contributions = 0` (no contributions recorded)
- `skills = 0` (no skills linked)

### Category 2: Incomplete decisions

```sql
SELECT d.id, d.title, d.tradeoffs, d.validation, t.title as task_title, p.company,
  (SELECT COUNT(*) FROM decision_options WHERE decision_id = d.id) as option_count
FROM decisions d
JOIN tasks t ON d.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE d.tradeoffs IS NULL
   OR d.validation IS NULL
   OR (SELECT COUNT(*) FROM decision_options WHERE decision_id = d.id) = 0
```

Flag decisions where:
- `tradeoffs` is NULL
- `validation` is NULL
- No `decision_options` recorded

### Category 3: Incomplete outcomes

```sql
SELECT o.id, o.type, o.before_state, o.after_state, o.metric, o.scope,
  t.title as task_title, p.company
FROM outcomes o
JOIN tasks t ON o.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE o.before_state IS NULL
   OR o.after_state IS NULL
   OR o.metric IS NULL
```

Flag outcomes where:
- `before_state` is NULL (no baseline)
- `after_state` is NULL (no result state)
- `metric` is NULL (no measurable indicator)

### Category 4: Incomplete challenges

```sql
SELECT c.id, c.title, c.root_cause, c.resolution, c.impact,
  t.title as task_title, p.company,
  (SELECT COUNT(*) FROM challenge_steps WHERE challenge_id = c.id) as step_count
FROM challenges c
JOIN tasks t ON c.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE c.root_cause IS NULL
   OR c.resolution IS NULL
   OR (SELECT COUNT(*) FROM challenge_steps WHERE challenge_id = c.id) = 0
```

### Category 5: CV readiness (only for --cv-ready or --full)

**Tasks with cv_include=1 but no STAR stories:**
```sql
SELECT t.id, t.title, p.company
FROM tasks t
JOIN projects p ON t.project_id = p.id
LEFT JOIN star_stories ss ON ss.task_id = t.id
WHERE t.cv_include = 1 AND ss.id IS NULL
```

**Tasks with cv_include=1 but no cv_entries:**
```sql
SELECT t.id, t.title, p.company
FROM tasks t
JOIN projects p ON t.project_id = p.id
LEFT JOIN cv_entries ce ON ce.task_id = t.id
WHERE t.cv_include = 1 AND ce.id IS NULL
```

**Projects with cv_include=1 but missing summary:**
```sql
SELECT id, company FROM projects WHERE cv_include = 1 AND (project_summary IS NULL OR project_summary = '')
```

## Presentation

Show a gap report organized by severity:

**Critical (for CV/interview readiness):**
- CV tasks with no STAR stories
- CV tasks with no cv_entries
- CV tasks with no outcomes

**Important:**
- Tasks with no decisions
- Decisions with no tradeoffs or validation
- Outcomes with no metrics

**Nice to have:**
- Tasks with no challenges
- Tasks with no contributions
- Challenges with no steps

For each category, show the count of issues and list affected tasks with project context.

## Interactive Gap Filling

After showing the report, ask: "Which gaps would you like to fill? I can walk you through them one by one."

For each gap the user wants to fill:

### Missing decisions
Ask: "For the task '[title]' at [company], what technical or design decisions did you make?"
- Guide through: context, conclusion, reasoning, alternatives, tradeoffs
- Use `career_write` to insert

### Missing outcomes
Ask: "For '[title]', what was the measurable impact? What was the state before and after?"
- Guide through: type, before_state, after_state, metric, scope
- Use `career_write` to insert

### Missing STAR stories
Ask: "Let's create a STAR story for '[title]'. This will be useful for behavioral interviews."
- Guide through: situation, task_description, action, result
- Ask: "What interview question would this story be a good answer for?" (target_question)
- Use `career_write` to insert into `star_stories`

### Missing cv_entries
Based on existing data (decisions, outcomes, contributions), draft a polished CV entry.
- Show the draft and ask for feedback
- Use `career_write` to insert into `cv_entries`

### Incomplete decisions (tradeoffs/validation)
Show the existing decision context and ask:
- "What tradeoffs did you accept with this decision?"
- "How did you validate or confirm this was the right choice?"
- Use `career_write` to update

### Incomplete outcomes (before/after/metric)
Show the existing outcome and ask targeted questions for the missing fields.
- Use `career_write` to update

## Guidelines

- Prioritize gaps by impact: CV-included tasks first, then high-difficulty tasks.
- Don't overwhelm the user. After showing the report, work through gaps one at a time.
- If there are many gaps, suggest focusing on the top 3-5 most impactful ones per session.
- After filling gaps, show a quick before/after count of issues remaining.
- Suggest running `/cv-generate` after enriching CV-ready tasks.
