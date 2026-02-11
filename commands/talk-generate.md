---
description: Generate conference talk proposals and outlines from career experience data
---

Generate a conference talk proposal, outline, or slide plan based on the user's real career experience stored in the DB.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.

## Step 1: Check existing talk ideas

Query the DB for any previously saved talk ideas:

```sql
SELECT * FROM content_ideas WHERE render_target = 'talk' AND status = 'idea'
```

If results exist, present them to the user as starting-point options.

## Step 2: Parse flags

Accept the following optional flags from the user's input:

- `--format proposal|outline|slides` (default: `proposal`)
- `--duration 5|15|30|45` (default: `30`)
- `--level beginner|intermediate|advanced` (default: `intermediate`)

## Step 3: Mine the DB for compelling talk material

If the user has not specified a topic, query the DB to surface strong candidates:

1. **Architecture talks** -- Decisions that involved multiple complex tradeoffs:
   ```sql
   SELECT d.id, d.title, d.context, d.conclusion, COUNT(do2.id) AS option_count
   FROM decisions d
   JOIN decision_options do2 ON d.id = do2.decision_id
   GROUP BY d.id HAVING option_count >= 3
   ORDER BY option_count DESC
   ```
2. **War-story talks** -- Challenges with surprising root causes:
   ```sql
   SELECT c.id, c.title, c.symptom, c.root_cause, c.resolution, c.difficulty,
     COUNT(cs.id) AS step_count
   FROM challenges c
   LEFT JOIN challenge_steps cs ON c.id = cs.challenge_id
   GROUP BY c.id ORDER BY c.difficulty DESC, step_count DESC
   ```
3. **Case study talks** -- Projects with impressive outcomes and clear before/after metrics:
   ```sql
   SELECT o.id, o.type, o.before_state, o.after_state, o.metric, o.scope,
     t.title AS task_title, p.company
   FROM outcomes o
   JOIN tasks t ON o.task_id = t.id
   JOIN projects p ON t.project_id = p.id
   WHERE o.before_state IS NOT NULL AND o.after_state IS NOT NULL
   ```
4. **Tutorial / how-to talks** -- Patterns across multiple tasks using the same skills:
   ```sql
   SELECT s.name, s.category, COUNT(DISTINCT t.id) AS task_count,
     COUNT(DISTINCT p.id) AS project_count
   FROM task_skills ts
   JOIN skills s ON ts.skill_id = s.id
   JOIN tasks t ON ts.task_id = t.id
   JOIN projects p ON t.project_id = p.id
   GROUP BY s.id HAVING task_count >= 3
   ORDER BY task_count DESC
   ```
5. **Hot topics** -- Cross-reference `decision_tags` and `challenge_tags` for recurring themes:
   ```sql
   SELECT tag, COUNT(*) AS freq FROM (
     SELECT tag FROM decision_tags
     UNION ALL
     SELECT tag FROM challenge_tags
   ) GROUP BY tag ORDER BY freq DESC LIMIT 10
   ```

Present the mined candidates grouped by talk type with a brief explanation of why each is compelling.

## Step 4: User selects topic

Ask the user to pick one of the suggested topics or provide their own. Confirm the selection before proceeding.

## Step 5: Generate output based on format

### If `--format proposal`

Generate a complete CFP-ready proposal containing:

- **Title**: Concise, engaging title
- **Abstract**: Approximately 200 words summarizing the talk
- **Outline**: Bulleted section breakdown
- **Speaker bio**: Pull from the `profile` table (`SELECT value FROM profile WHERE key IN ('name', 'bio', 'title', 'company')`)
- **Target audience**: Who will benefit most
- **Key takeaways**: 3-5 concrete things the audience will learn

### If `--format outline`

Generate a detailed section-by-section breakdown:

- Time allocation per section (respecting `--duration`)
- Key points and sub-points for each section
- Demo or live-coding ideas where appropriate
- Real data points and anecdotes pulled from the DB (decisions, challenges, outcomes)
- Suggested transitions between sections

### If `--format slides`

Generate a slide-by-slide outline:

- Slide number and title
- Bullet points for slide content
- Speaker notes for each slide
- Data points and metrics to display (sourced from outcomes, challenges)
- Suggested visuals (diagrams, charts, code snippets, before/after comparisons)
- Pacing notes based on `--duration`

Tailor technical depth to the `--level` flag throughout all formats.

## Step 6: Save to content_ideas

After the user approves the generated output, save it to the DB:

```sql
INSERT INTO content_ideas (source_type, source_id, render_target, title, angle, status)
VALUES ('<source_type>', <source_id>, 'talk', '<title>', '<angle_summary>', 'drafted')
```

Always confirm with the user before writing.

## Step 7: Suggest venues

Based on the topic and technology tags, suggest:

- Relevant conferences or CFPs currently accepting proposals
- Local meetup groups where the talk could be workshopped
- Online events or lightning-talk opportunities for shorter formats

## Guidelines

- Always confirm before writing to the DB.
- Use `career_read` to check existing data before inserting duplicates.
- Keep output actionable and professional.
- Ground every claim in real data from the DB -- do not fabricate metrics or experiences.
- Adapt tone and structure to the target conference culture (academic vs. community vs. corporate).
- For Japanese output, use natural conference-presentation style, not literal translations.
