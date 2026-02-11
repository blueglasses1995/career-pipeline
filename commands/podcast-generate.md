---
description: Generate podcast episode scripts and topic outlines from career experience data
---

Generate podcast episode topics, outlines, or full scripts based on the user's real career experience stored in the DB.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.

## Step 1: Check existing podcast ideas

Query the DB for any previously saved podcast ideas:

```sql
SELECT * FROM content_ideas WHERE render_target = 'podcast' AND status = 'idea'
```

If results exist, present them to the user as starting-point options.

## Step 2: Parse flags

Accept the following optional flags from the user's input:

- `--format topics|outline|script` (default: `topics`)
- `--style solo|interview|panel` (default: `solo`)
- `--duration 15|30|60` (default: `30`)

## Step 3: Mine the DB for podcast material

If the user has not specified a topic, query the DB to surface episode ideas:

1. **Theme episodes** -- Group related decisions across projects:
   ```sql
   SELECT dt.tag, GROUP_CONCAT(d.title, ' | ') AS decisions,
     COUNT(DISTINCT p.id) AS project_count
   FROM decision_tags dt
   JOIN decisions d ON dt.decision_id = d.id
   JOIN tasks t ON d.task_id = t.id
   JOIN projects p ON t.project_id = p.id
   GROUP BY dt.tag HAVING COUNT(d.id) >= 2
   ORDER BY COUNT(d.id) DESC
   ```

2. **Storytelling episodes** -- Deep-dive on a single challenge with multi-step debugging:
   ```sql
   SELECT c.id, c.title, c.symptom, c.root_cause, c.resolution,
     c.difficulty, c.time_spent,
     COUNT(cs.id) AS step_count
   FROM challenges c
   JOIN challenge_steps cs ON c.id = cs.challenge_id
   GROUP BY c.id HAVING step_count >= 3
   ORDER BY step_count DESC
   ```

3. **Comparison episodes** -- Compare similar tasks across different projects:
   ```sql
   SELECT s.name AS skill, GROUP_CONCAT(DISTINCT p.company) AS companies,
     COUNT(DISTINCT t.id) AS task_count
   FROM task_skills ts
   JOIN skills s ON ts.skill_id = s.id
   JOIN tasks t ON ts.task_id = t.id
   JOIN projects p ON t.project_id = p.id
   GROUP BY s.id HAVING COUNT(DISTINCT p.id) >= 2
   ORDER BY task_count DESC
   ```

4. **Career journey episodes** -- Career progression narrative from the project timeline:
   ```sql
   SELECT p.company, p.role, p.period_start, p.period_end, p.project_type,
     p.project_summary, p.team_size
   FROM projects p ORDER BY p.period_start
   ```

Present the candidates grouped by episode type with a brief description of why each makes a good episode.

## Step 4: User selects topic

Ask the user to pick one of the suggested topics or provide their own. Confirm the selection before proceeding.

## Step 5: Generate output based on format

### If `--format topics`

Generate a list of episode ideas containing:

- **Episode title**: Catchy, podcast-friendly title
- **One-liner**: Single-sentence hook
- **Description**: 2-3 sentences on what the episode covers
- **Estimated appeal**: Who would listen and why
- **Source data**: Which DB records feed into this topic

### If `--format outline`

Generate a structured episode outline:

- **Episode title and description**
- **Intro segment**: Hook, context setting, what the listener will learn (with time estimate)
- **Main segments**: 2-4 segments with talking points, data references from the DB, and transition notes (with time estimates per segment)
- **Key quotes / anecdotes**: Pull actual decision reasoning, challenge symptoms, or outcome metrics to weave in naturally
- **Outro segment**: Summary, key takeaway, call-to-action (with time estimate)
- Total time should align with `--duration`

### If `--format script`

Generate a full episode script:

- **Cold open**: Attention-grabbing hook drawn from a real challenge or decision
- **Intro**: Episode introduction, topic framing, what the listener will get
- **Segments**: Fully written segments with natural spoken language, including:
  - Actual quotes from decisions (`conclusion`, `reasoning`)
  - Step-by-step narration of challenges (`challenge_steps` in order)
  - Before/after data from outcomes
  - Transitions between segments
- **Outro**: Recap, key takeaway, call-to-action, preview of next episode
- Timing markers aligned to `--duration`

Adjust tone for the `--style` flag:
- **Solo**: First-person narrative, reflective, conversational
- **Interview**: Frame as Q&A with suggested host questions and guest answers
- **Panel**: Frame as multi-perspective discussion with role assignments

## Step 6: Generate guest questions (interview/panel style)

If `--style` is `interview` or `panel`, additionally generate:

- 8-12 potential interview questions, ordered from warm-up to deep technical
- For each question, note which DB records provide the strongest answer material
- Suggested follow-up probes for interesting tangents
- For panel style, indicate which perspective each question targets

## Step 7: Save to content_ideas

After the user approves the generated output, save it to the DB:

```sql
INSERT INTO content_ideas (source_type, source_id, render_target, title, angle, status)
VALUES ('<source_type>', <source_id>, 'podcast', '<title>', '<angle_summary>', 'drafted')
```

Always confirm with the user before writing.

## Guidelines

- Always confirm before writing to the DB.
- Use `career_read` to check existing data before inserting duplicates.
- Keep output actionable and professional.
- Ground every claim in real data from the DB -- do not fabricate metrics or experiences.
- Write scripts in natural spoken language, not written-essay style.
- Include pauses, emphasis cues, and pacing notes in scripts.
- For Japanese output, use natural podcast-conversation style appropriate to the chosen `--style`.
