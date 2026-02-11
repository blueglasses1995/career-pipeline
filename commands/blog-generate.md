---
description: Generate technical blog post drafts from career data (decisions, challenges, outcomes)
---

You are helping the user generate technical blog post drafts based on their real career experiences stored in the Career Pipeline database.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.
3. Parse flags from the user's input:
   - `--format outline|draft|full` : Level of detail to generate (default: `draft`)
   - `--tone technical|casual|tutorial` : Writing tone (default: `technical`)
   - `--length short|medium|long` : Target length - short ~800 words, medium ~1500 words, long ~2500+ words (default: `medium`)

## Flow

### Step 1: Check existing blog ideas

Query the `content_ideas` table for previously saved blog ideas:

```sql
SELECT ci.id, ci.title, ci.angle, ci.status, ci.source_type, ci.source_id,
  CASE
    WHEN ci.source_type = 'decision' THEN (SELECT d.title FROM decisions d WHERE d.id = ci.source_id)
    WHEN ci.source_type = 'challenge' THEN (SELECT c.title FROM challenges c WHERE c.id = ci.source_id)
    WHEN ci.source_type = 'outcome' THEN (SELECT o.metric FROM outcomes o WHERE o.id = ci.source_id)
    WHEN ci.source_type = 'task' THEN (SELECT t.title FROM tasks t WHERE t.id = ci.source_id)
  END as source_title
FROM content_ideas ci
WHERE ci.render_target = 'blog' AND ci.status = 'idea'
ORDER BY ci.created_at DESC
```

If ideas exist, show them as a numbered list with their angle and source context.

### Step 2: Suggest new topics (if no ideas exist or user wants fresh suggestions)

Query the database for blog-worthy material:

**Decisions with rich context** (3+ options considered, significant tradeoffs):
```sql
SELECT d.id, d.title, d.context, d.conclusion, d.tradeoffs,
  t.title as task_title, p.company,
  (SELECT COUNT(*) FROM decision_options WHERE decision_id = d.id) as option_count,
  GROUP_CONCAT(dt.tag) as tags
FROM decisions d
JOIN tasks t ON d.task_id = t.id
JOIN projects p ON t.project_id = p.id
LEFT JOIN decision_tags dt ON dt.decision_id = d.id
GROUP BY d.id
HAVING option_count >= 2
ORDER BY option_count DESC
```

**Challenges with interesting debugging stories** (multi-step resolution, non-obvious root causes):
```sql
SELECT c.id, c.title, c.symptom, c.root_cause, c.resolution, c.difficulty,
  t.title as task_title, p.company,
  (SELECT COUNT(*) FROM challenge_steps WHERE challenge_id = c.id) as step_count,
  (SELECT COUNT(*) FROM challenge_steps WHERE challenge_id = c.id AND was_dead_end = 1) as dead_ends,
  GROUP_CONCAT(ct.tag) as tags
FROM challenges c
JOIN tasks t ON c.task_id = t.id
JOIN projects p ON t.project_id = p.id
LEFT JOIN challenge_tags ct ON ct.challenge_id = c.id
GROUP BY c.id
HAVING step_count >= 2
ORDER BY c.difficulty DESC, step_count DESC
```

**Outcomes with impressive metrics**:
```sql
SELECT o.id, o.type, o.before_state, o.after_state, o.metric, o.scope,
  t.title as task_title, p.company
FROM outcomes o
JOIN tasks t ON o.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE o.type = 'quantitative' AND o.before_state IS NOT NULL AND o.after_state IS NOT NULL
ORDER BY o.scope DESC
```

**Score and rank by blog-worthiness:**
- **Uniqueness**: Unusual technology combinations, rare problem scenarios, counter-intuitive conclusions
- **Learning value**: Clear takeaways, transferable lessons, common pitfalls avoided
- **Storytelling potential**: Dramatic before/after, interesting dead ends, satisfying resolution
- **Depth of data**: More decision options, challenge steps, and outcomes = richer blog material

Present the top 5-8 suggestions with:
- Suggested title
- Blog angle (e.g., "Why I chose X over Y", "How I debugged a mysterious Z issue", "The impact of switching to W")
- Source data summary
- Blog-worthiness score (High / Medium / Low)

### Step 3: User selects a topic

Let the user pick a topic from the suggestions or existing ideas, or describe their own topic. If they describe their own, search the database for relevant data:

```sql
-- Use career_search to find related records
```

### Step 4: Gather full context for the selected topic

Depending on the source type, fetch all related data:

**For decision-based posts:**
```sql
SELECT d.*, GROUP_CONCAT(DISTINCT ds_skill.name) as related_skills
FROM decisions d
LEFT JOIN decision_skills dsk ON dsk.decision_id = d.id
LEFT JOIN skills ds_skill ON ds_skill.id = dsk.skill_id
WHERE d.id = <decision_id>
GROUP BY d.id
```

```sql
SELECT * FROM decision_options WHERE decision_id = <decision_id>
```

```sql
SELECT * FROM decision_tags WHERE decision_id = <decision_id>
```

**For challenge-based posts:**
```sql
SELECT * FROM challenge_steps WHERE challenge_id = <challenge_id> ORDER BY step_order
```

**For outcome-based posts:**
```sql
SELECT * FROM contributions WHERE task_id = <task_id>
```

Also fetch the parent task and project context for any source type.

### Step 5: Generate the blog post

Based on the `--format` flag:

#### Outline (`--format outline`)
Generate:
- **Title**: Compelling, specific title
- **Target audience**: Who would benefit from reading this
- **Sections**: 4-6 section headings with 2-3 key points each, referencing specific DB data
- **Key data points**: Which decisions, metrics, or challenge steps to highlight
- **Estimated length**: Word count estimate

#### Draft (`--format draft`)
Generate full prose including:
- **Introduction**: Hook the reader with the problem or question. Establish context from the project/task data.
- **Body**:
  - For decision posts: Present the situation, walk through each option (from `decision_options` with pros/cons), explain the chosen path and reasoning, discuss tradeoffs
  - For challenge posts: Describe the symptom, walk through debugging steps (from `challenge_steps`, including dead ends), reveal the root cause, explain the resolution
  - For outcome posts: Set the baseline (before_state), describe what was done (from tasks/contributions), show the results (after_state with metrics)
- **Conclusion**: Key takeaways, lessons learned, what you'd do differently
- **Author note**: Brief context about the project (anonymized if needed)

#### Full (`--format full`)
Generate everything in draft, plus:
- **SEO suggestions**: Title tag, meta description, target keywords (derived from skill names and tags)
- **Code example placeholders**: Suggest where code snippets would strengthen the post, with descriptions of what to include
- **Diagram descriptions**: Suggest architecture diagrams, flowcharts, or before/after comparisons where relevant
- **Related reading**: Suggest topics for follow-up posts from other DB entries
- **Social media teaser**: A short summary for sharing on Twitter/X or LinkedIn

### Step 6: Save to content_ideas

Check if this topic is already tracked:
```sql
SELECT id FROM content_ideas WHERE source_type = '<type>' AND source_id = <id> AND render_target = 'blog'
```

If not tracked, ask: "Would you like me to save this as a content idea?" and use `career_write` to insert:
- `source_type`, `source_id`, `render_target = 'blog'`
- `title` (the generated title)
- `angle` (the blog angle)
- `status = 'drafted'`

If already tracked, update the status to `'drafted'`.

### Step 7: Output and next steps

Display the generated content and suggest next steps:
- "Review and edit the draft, then publish to your blog platform"
- "Run `/blog-generate` again with `--format full` for publication-ready output" (if they used outline or draft)
- "Consider generating a LinkedIn post about this topic with `/linkedin-generate`"
- "Share the draft with colleagues for technical review before publishing"

## Guidelines

- Always confirm before writing to the database.
- Use `career_read` to check existing data before inserting duplicates.
- Anonymize company names and sensitive details by default. Ask the user if they want to use real names.
- Do not fabricate data. Every claim in the blog post must be traceable to actual DB records. If data is thin, note where the user should add more detail.
- For Japanese output, write in a natural blog style appropriate for platforms like Zenn or Qiita.
- For English output, write in a clear, engaging technical blog style suitable for Medium, dev.to, or a personal blog.
- Keep output actionable and professional.
