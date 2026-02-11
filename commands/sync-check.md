---
description: Check database integrity, find orphaned records, and manage data exports
---

You are running a consistency and integrity check on the user's Career Pipeline database.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language. Default to English.
2. Respond in the user's preferred language.

## Step 1: Database overview

Use `career_stats` to get a quick overview of record counts across all tables.

Display a summary table:
```
Table              | Count
-------------------|------
projects           | N
tasks              | N
decisions          | N
decision_options   | N
challenges         | N
challenge_steps    | N
outcomes           | N
contributions      | N
stakeholder_inter. | N
raw_notes          | N
cv_entries         | N
star_stories       | N
skills             | N
```

## Step 2: Orphan check

Run queries to detect orphaned records:

**Tasks without projects:**
```sql
SELECT t.id, t.title FROM tasks t
LEFT JOIN projects p ON t.project_id = p.id
WHERE p.id IS NULL
```

**Decisions without tasks:**
```sql
SELECT d.id, d.title FROM decisions d
LEFT JOIN tasks t ON d.task_id = t.id
WHERE t.id IS NULL
```

**Challenges without tasks:**
```sql
SELECT c.id, c.title FROM challenges c
LEFT JOIN tasks t ON c.task_id = t.id
WHERE t.id IS NULL
```

**Outcomes without tasks:**
```sql
SELECT o.id FROM outcomes o
LEFT JOIN tasks t ON o.task_id = t.id
WHERE t.id IS NULL
```

**Contributions without tasks:**
```sql
SELECT c.id FROM contributions c
LEFT JOIN tasks t ON c.task_id = t.id
WHERE t.id IS NULL
```

**Unused skills (not linked to any task):**
```sql
SELECT s.id, s.name FROM skills s
LEFT JOIN task_skills ts ON s.id = ts.skill_id
WHERE ts.skill_id IS NULL
```

**Decision options without decisions:**
```sql
SELECT do2.id, do2.label FROM decision_options do2
LEFT JOIN decisions d ON do2.decision_id = d.id
WHERE d.id IS NULL
```

**Challenge steps without challenges:**
```sql
SELECT cs.id FROM challenge_steps cs
LEFT JOIN challenges c ON cs.challenge_id = c.id
WHERE c.id IS NULL
```

Report any orphans found with their IDs and enough context to identify them.

## Step 3: Data integrity checks

**Decisions with no options:**
```sql
SELECT d.id, d.title, t.title as task_title FROM decisions d
JOIN tasks t ON d.task_id = t.id
LEFT JOIN decision_options do2 ON d.id = do2.decision_id
WHERE do2.id IS NULL
```

**Challenges with no steps:**
```sql
SELECT c.id, c.title, t.title as task_title FROM challenges c
JOIN tasks t ON c.task_id = t.id
LEFT JOIN challenge_steps cs ON c.id = cs.challenge_id
WHERE cs.id IS NULL
```

**Tasks with cv_include=1 but no meaningful content:**
```sql
SELECT t.id, t.title, p.company,
  (SELECT COUNT(*) FROM decisions WHERE task_id = t.id) as decision_count,
  (SELECT COUNT(*) FROM outcomes WHERE task_id = t.id) as outcome_count,
  (SELECT COUNT(*) FROM contributions WHERE task_id = t.id) as contribution_count
FROM tasks t
JOIN projects p ON t.project_id = p.id
WHERE t.cv_include = 1
```

## Step 4: Export check

Check if a SQL dump exists:
- Look for `~/.career-pipeline/dumps/career.sql` or similar
- If it exists, report its file size and modification date
- If the dump is older than 7 days or doesn't exist, suggest running a fresh export

Offer: "Would you like me to run `career_dump` to create a fresh SQL export for backup?"

## Step 5: Report

Present a summary:
- Total records across all tables
- Number of orphaned records found (if any)
- Number of integrity issues (if any)
- Export status
- Overall health: "Healthy" / "Minor issues" / "Needs attention"

If issues were found, offer to:
- Delete orphaned records (with confirmation)
- Fill gaps using `/review-career`
- Run a fresh export

## Guidelines

- This is a diagnostic tool. Do not modify data unless the user explicitly confirms.
- Be precise about what each issue means and its potential impact.
- For orphaned records, explain how they might have occurred (e.g., manual DB edits, interrupted writes).
