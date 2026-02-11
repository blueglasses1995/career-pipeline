---
description: Generate LinkedIn posts from career achievements, decisions, and learnings
---

You are helping the user generate LinkedIn posts based on their real career experiences stored in the Career Pipeline database.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.
3. Parse flags from the user's input:
   - `--type achievement|learning|decision|milestone` : Post type (default: auto-suggest)
   - `--tone professional|conversational|storytelling` : Writing tone (default: `conversational`)

## Flow

### Step 1: Check existing LinkedIn ideas

Query the `content_ideas` table for previously saved LinkedIn ideas:

```sql
SELECT ci.id, ci.title, ci.angle, ci.status, ci.source_type, ci.source_id,
  CASE
    WHEN ci.source_type = 'decision' THEN (SELECT d.title FROM decisions d WHERE d.id = ci.source_id)
    WHEN ci.source_type = 'challenge' THEN (SELECT c.title FROM challenges c WHERE c.id = ci.source_id)
    WHEN ci.source_type = 'outcome' THEN (SELECT o.metric FROM outcomes o WHERE o.id = ci.source_id)
    WHEN ci.source_type = 'task' THEN (SELECT t.title FROM tasks t WHERE t.id = ci.source_id)
  END as source_title
FROM content_ideas ci
WHERE ci.render_target = 'linkedin' AND ci.status = 'idea'
ORDER BY ci.created_at DESC
```

If ideas exist, show them as a numbered list with their angle and source context.

### Step 2: Parse flags and determine post type

If `--type` is specified, focus suggestions on that type. Otherwise, suggest from all types.

### Step 3: Suggest topics from the database (if no specific topic provided)

Query for material suited to each post type:

**Achievement posts** - Recent outcomes with quantitative metrics:
```sql
SELECT o.id, o.type, o.before_state, o.after_state, o.metric, o.scope,
  t.title as task_title, p.company, p.role,
  GROUP_CONCAT(DISTINCT s.name) as skills_used
FROM outcomes o
JOIN tasks t ON o.task_id = t.id
JOIN projects p ON t.project_id = p.id
LEFT JOIN task_skills ts ON ts.task_id = t.id
LEFT JOIN skills s ON s.id = ts.skill_id
WHERE o.type = 'quantitative' AND o.before_state IS NOT NULL AND o.after_state IS NOT NULL
GROUP BY o.id
ORDER BY t.period_end DESC
LIMIT 5
```

**Learning posts** - Interesting decisions with clear takeaways:
```sql
SELECT d.id, d.title, d.context, d.conclusion, d.reasoning, d.tradeoffs,
  t.title as task_title, p.company,
  (SELECT COUNT(*) FROM decision_options WHERE decision_id = d.id) as option_count,
  GROUP_CONCAT(DISTINCT dt.tag) as tags
FROM decisions d
JOIN tasks t ON d.task_id = t.id
JOIN projects p ON t.project_id = p.id
LEFT JOIN decision_tags dt ON dt.decision_id = d.id
GROUP BY d.id
ORDER BY option_count DESC
LIMIT 5
```

**Decision posts** - Decisions with rich tradeoff context:
```sql
SELECT d.id, d.title, d.context, d.conclusion, d.tradeoffs, d.validation,
  t.title as task_title, p.company
FROM decisions d
JOIN tasks t ON d.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE d.tradeoffs IS NOT NULL AND d.validation IS NOT NULL
ORDER BY t.period_end DESC
LIMIT 5
```

**Milestone posts** - Career milestones from project timelines:
```sql
SELECT p.id, p.company, p.role, p.period_start, p.period_end, p.project_summary, p.project_type,
  (SELECT COUNT(*) FROM tasks WHERE project_id = p.id) as task_count,
  (SELECT COUNT(DISTINCT s.category) FROM task_skills ts
   JOIN skills s ON s.id = ts.skill_id
   JOIN tasks t ON ts.task_id = t.id
   WHERE t.project_id = p.id) as skill_categories
FROM projects p
ORDER BY p.period_end DESC
LIMIT 5
```

**Skill progression stories** - Growth visible through task_skills depth changes:
```sql
SELECT s.name, s.category,
  MIN(t.period_start) as first_used,
  MAX(t.period_end) as latest_used,
  GROUP_CONCAT(DISTINCT ts.usage_depth) as depth_progression,
  COUNT(DISTINCT t.id) as task_count
FROM skills s
JOIN task_skills ts ON ts.skill_id = s.id
JOIN tasks t ON ts.task_id = t.id
GROUP BY s.id
HAVING COUNT(DISTINCT ts.usage_depth) >= 2
ORDER BY task_count DESC
LIMIT 5
```

Present suggestions grouped by post type with:
- Suggested angle
- Key data point (the hook)
- Recommended `--type` and `--tone`

### Step 4: User selects a topic

Let the user pick a suggestion or describe their own topic. If they describe their own, use `career_search` to find relevant records.

### Step 5: Generate the LinkedIn post

Fetch full context for the selected topic (related decisions, outcomes, skills, contributions) using `career_read`.

Generate a LinkedIn post following this structure (target: 300-1300 characters):

**Hook line** (first 1-2 lines - this appears before "...see more"):
- Start with a bold statement, surprising insight, or compelling question
- Must grab attention immediately - this determines whether people click "see more"
- Examples: "I reduced our API response time by 90%. Here's the one change that did it.", "The best technical decision I made last year was saying no."

**Body** (the story/insight):
- Draw directly from DB data - use real context, reasoning, and results
- For **achievement** posts: State the challenge, what you did (from contributions), the result (from outcomes with before/after)
- For **learning** posts: Set up the situation (from decision context), share the insight (from reasoning/tradeoffs), connect to broader principle
- For **decision** posts: Present the dilemma (from decision context), walk through the key options briefly (from decision_options), explain your choice and why (from conclusion/reasoning)
- For **milestone** posts: Reflect on the journey (from project timeline), highlight key moments (from tasks/outcomes), share what you learned
- Keep paragraphs short (1-3 sentences) for mobile readability
- Use line breaks between paragraphs for visual breathing room

**Key takeaway** (1-2 lines):
- Distill the main lesson or insight
- Make it actionable and relatable to the reader

**Hashtags** (3-5 relevant tags):
- Derive from skill categories and decision/challenge tags
- Map categories: Frontend -> #FrontendDevelopment, Backend -> #BackendEngineering, Infrastructure -> #CloudInfrastructure, etc.
- Include general tags like #SoftwareEngineering, #TechLeadership, #WebDevelopment as appropriate
- For Japanese posts, mix English hashtags with Japanese ones (e.g., #エンジニア, #技術選定)

### Step 6: Save to content_ideas

Check if this topic is already tracked:
```sql
SELECT id FROM content_ideas WHERE source_type = '<type>' AND source_id = <id> AND render_target = 'linkedin'
```

If not tracked, ask: "Would you like me to save this as a content idea?" and use `career_write` to insert:
- `source_type`, `source_id`, `render_target = 'linkedin'`
- `title` (the post topic)
- `angle` (the post angle/type)
- `status = 'drafted'`

If already tracked, update the status to `'drafted'`.

### Step 7: Show post with metadata and tips

Display the final post with:

**Post preview:**
> [The generated LinkedIn post text]

**Post metadata:**
- Character count: [N] / 3000 max (recommended: 300-1300)
- Estimated read time: [N] seconds
- Post type: [achievement/learning/decision/milestone]
- Tone: [professional/conversational/storytelling]

**Formatting tips:**
- LinkedIn truncates after ~210 characters on desktop (~140 on mobile). Make sure your hook fits.
- Use line breaks liberally - walls of text get scrolled past.
- Emojis are optional but can help with visual hierarchy (use sparingly for professional tone).
- Best posting times: Tuesday-Thursday, 8-10 AM in your timezone.
- Consider adding a relevant image or diagram to boost engagement.

**Next steps:**
- Copy and post directly to LinkedIn
- Run `/blog-generate` to expand this into a full blog post if the topic has depth
- Generate alternative versions with different `--tone` flags

## Guidelines

- Always confirm before writing to the database.
- Use `career_read` to check existing data before inserting duplicates.
- Anonymize company names and sensitive details by default. Ask the user if they want to use real names.
- Do not fabricate data. Every claim must be backed by actual DB records. If data is insufficient for a compelling post, suggest enriching the data with `/update-task` first.
- LinkedIn posts should feel authentic and personal, not like marketing copy. Write in first person.
- Avoid cliches like "I'm thrilled to announce" or "Excited to share". Start with substance.
- For Japanese output, write in a natural LinkedIn style appropriate for the Japanese professional community. Use polite but not overly formal language.
- For English output, write in a clear, engaging professional style that feels genuine.
- Keep output actionable and professional.
