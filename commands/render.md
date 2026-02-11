---
description: Generate content (blog, LinkedIn, talk, podcast) from career data
---

You are helping the user generate content from their Career Pipeline database. The `--target` flag determines the output type.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.
3. Parse the `--target` flag (required):
   - `--target blog` : Technical blog post
   - `--target linkedin` : LinkedIn post
   - `--target talk` : Conference talk proposal/outline
   - `--target podcast` : Podcast episode script/outline

If `--target` is not provided, ask the user which target they want.

---

## Common: Check existing ideas

For any target, first check the `content_ideas` table:

```sql
SELECT ci.id, ci.title, ci.angle, ci.status, ci.source_type, ci.source_id,
  CASE
    WHEN ci.source_type = 'decision' THEN (SELECT d.title FROM decisions d WHERE d.id = ci.source_id)
    WHEN ci.source_type = 'challenge' THEN (SELECT c.title FROM challenges c WHERE c.id = ci.source_id)
    WHEN ci.source_type = 'outcome' THEN (SELECT o.metric FROM outcomes o WHERE o.id = ci.source_id)
    WHEN ci.source_type = 'task' THEN (SELECT t.title FROM tasks t WHERE t.id = ci.source_id)
  END as source_title
FROM content_ideas ci
WHERE ci.render_target = '<target>' AND ci.status = 'idea'
ORDER BY ci.created_at DESC
```

If ideas exist, show them. Otherwise (or if user wants fresh suggestions), mine the DB.

## Common: Mine DB for material

Query for content-worthy material:

**Decisions with rich context** (3+ options, tradeoffs):
```sql
SELECT d.id, d.title, d.context, d.conclusion, d.tradeoffs,
  t.title as task_title, p.company,
  (SELECT COUNT(*) FROM decision_options WHERE decision_id = d.id) as option_count,
  GROUP_CONCAT(dt.tag) as tags
FROM decisions d
JOIN tasks t ON d.task_id = t.id
JOIN projects p ON t.project_id = p.id
LEFT JOIN decision_tags dt ON dt.decision_id = d.id
GROUP BY d.id HAVING option_count >= 2
ORDER BY option_count DESC
```

**Challenges with interesting debugging stories**:
```sql
SELECT c.id, c.title, c.symptom, c.root_cause, c.resolution, c.difficulty,
  t.title as task_title, p.company,
  (SELECT COUNT(*) FROM challenge_steps WHERE challenge_id = c.id) as step_count
FROM challenges c
JOIN tasks t ON c.task_id = t.id
JOIN projects p ON t.project_id = p.id
GROUP BY c.id HAVING step_count >= 2
ORDER BY c.difficulty DESC, step_count DESC
```

**Outcomes with quantitative metrics**:
```sql
SELECT o.id, o.type, o.before_state, o.after_state, o.metric, o.scope,
  t.title as task_title, p.company
FROM outcomes o
JOIN tasks t ON o.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE o.type = 'quantitative' AND o.before_state IS NOT NULL AND o.after_state IS NOT NULL
ORDER BY o.scope DESC
```

Present ranked suggestions with title, angle, and content-worthiness score.

---

## Target: blog

**Additional flags:**
- `--format outline|draft|full` (default: `draft`)
- `--tone technical|casual|tutorial` (default: `technical`)
- `--length short|medium|long` (default: `medium`)

**Generation:**

- **Outline**: Title, sections, key points, estimated length
- **Draft**: Full prose with introduction, body (using real decision context, challenge steps, outcomes), conclusion
- **Full**: Draft + SEO suggestions, code example placeholders, diagram descriptions, social media teaser

**Guidelines for blog:**
- Anonymize company names by default. Ask user if they want real names.
- For Japanese, write in Zenn/Qiita style. For English, write in dev.to/Medium style.
- Every claim must trace to actual DB records.

---

## Target: linkedin

**Additional flags:**
- `--type achievement|learning|decision|milestone` (default: auto-suggest)
- `--tone professional|conversational|storytelling` (default: `conversational`)

**Topic suggestions by type:**
- **Achievement**: Outcomes with quantitative before/after metrics
- **Learning**: Decisions with clear takeaways and tradeoffs
- **Decision**: Decisions with rich option analysis
- **Milestone**: Project completions, role changes from timeline

**Generation (300-1300 characters):**
1. **Hook line**: Bold statement or surprising insight (appears before "...see more")
2. **Body**: Story/insight drawn from DB data, short paragraphs for mobile
3. **Key takeaway**: 1-2 lines, actionable
4. **Hashtags**: 3-5 tags derived from skill categories and decision tags

Show character count and formatting tips after generation.

**Guidelines for LinkedIn:**
- First person, authentic voice. No "I'm thrilled to announce" cliches.
- Hook must fit within ~210 characters (desktop truncation point).

---

## Target: talk

**Additional flags:**
- `--format proposal|outline|slides` (default: `proposal`)
- `--duration 5|15|30|45` (default: `30`)
- `--level beginner|intermediate|advanced` (default: `intermediate`)

**Topic mining categories:**
- **Architecture talks**: Decisions with 3+ options and complex tradeoffs
- **War-story talks**: Challenges with surprising root causes, multi-step debugging
- **Case study talks**: Projects with impressive before/after outcomes
- **Tutorial talks**: Skills used across 3+ tasks (patterns)

**Generation:**
- **Proposal**: Title, abstract (~200 words), outline, speaker bio (from `profile` table), target audience, key takeaways
- **Outline**: Section-by-section with time allocation (respecting `--duration`), key points, demo ideas, real data from DB
- **Slides**: Slide-by-slide with speaker notes, data points, suggested visuals, pacing notes

Suggest relevant conferences or meetups after generation.

---

## Target: podcast

**Additional flags:**
- `--format topics|outline|script` (default: `topics`)
- `--style solo|interview|panel` (default: `solo`)
- `--duration 15|30|60` (default: `30`)

**Topic mining categories:**
- **Theme episodes**: Grouped decisions across projects by tag
- **Storytelling episodes**: Single challenge with multi-step debugging
- **Comparison episodes**: Same skill used across different projects
- **Career journey episodes**: Project timeline narrative

**Generation:**
- **Topics**: List of episode ideas with hooks and estimated appeal
- **Outline**: Episode structure with segments, talking points, time estimates
- **Script**: Full spoken-language script with cold open, segments, transitions, timing markers

For interview/panel style, additionally generate 8-12 interview questions with follow-up probes.

---

## Common: Save to content_ideas

After generation, ask: "Save this as a content idea?"

```sql
INSERT INTO content_ideas (source_type, source_id, render_target, title, angle, status)
VALUES ('<type>', <id>, '<target>', '<title>', '<angle>', 'drafted')
```

Check for duplicates before inserting. Always confirm before writing.

## Guidelines

- Always confirm before writing to the database.
- Use `career_read` to check existing data before inserting duplicates.
- Anonymize company names by default.
- Do not fabricate data. Every claim must trace to actual DB records.
- Support both English and Japanese output based on settings.
