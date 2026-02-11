---
description: Analyze skill gaps between current capabilities and target roles or goals
---

Compare the user's current skill profile against a target role, job posting, or career goals to identify gaps, generate a match score, and produce an actionable learning plan.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.

## Step 1: Parse Flags

Accept the following optional flags from the user's input:

- `--role [target role]` -- A target role title (e.g., "Senior Backend Engineer", "Engineering Manager", "SRE Lead").
- `--compare [job posting URL or pasted text]` -- A job posting to parse for required and preferred skills.

Both flags are optional. If neither is provided and no `career_goals` exist, proceed to the interactive prompt in Step 3.

## Step 2: Load Current Skill Profile

Use `career_read` to query the user's full skill inventory with depth scores:

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
GROUP BY s.id
ORDER BY depth_score DESC, task_count DESC
```

Also load the user's profile for context:

```sql
SELECT key, value FROM profile
```

## Step 3: Determine Target Skill Requirements

Resolve the target requirements using the first matching strategy:

### Strategy A: Career Goals Exist

Check for existing career goals:

```sql
SELECT cg.id, cg.target_role, s.id AS skill_id, s.name AS skill_name,
  cg.desired_depth, cg.priority, cg.notes
FROM career_goals cg
JOIN skills s ON cg.skill_id = s.id
ORDER BY cg.priority ASC
```

If goals exist and no `--role` or `--compare` flag was provided, use these as the target. Map `desired_depth` to a numeric score using the same scale (designed=4, configured=3, evaluated=2, used=1).

### Strategy B: --role Provided

Use Claude's knowledge of the industry to suggest typical skill requirements for the given role. Structure the output as a list of skills, each with:
- Skill name
- Required depth (used / configured / designed)
- Whether the skill is "required" or "preferred"
- Category

Be specific and practical. For example, "Senior Backend Engineer" should include concrete technologies commonly expected, not just abstract concepts.

### Strategy C: --compare Provided

If a URL is provided, fetch and parse the job posting content. If pasted text is provided, parse it directly. Extract:
- Required skills with inferred depth levels
- Preferred/nice-to-have skills
- Years of experience expectations
- Any domain-specific requirements

Normalize extracted skill names to match existing skills in the database where possible.

### Strategy D: Interactive Prompt

If none of the above apply, ask the user:
1. "What role are you targeting?" -- Accept a role title.
2. "Would you like to paste a job posting for more precise analysis?" -- Accept optional text.

Then proceed with Strategy B or C based on the response.

## Step 4: Generate Gap Analysis

Compare the current skill profile (Step 2) against the target requirements (Step 3). Categorize every skill into one of four buckets:

### Skills That Match

Skills present in both the current profile and the target, where `depth_score >= required_depth`. List each with:
- Skill name
- Current depth (with label)
- Required depth
- Evidence: task count, project count, last used date

### Skills That Need Deepening

Skills present in the current profile but at a lower depth than required. List each with:
- Skill name
- Current depth vs. required depth
- Gap size (numeric difference)
- Current evidence summary
- What "deepening" means concretely (e.g., "Move from using React to designing component architectures and state management patterns")

### Skills Entirely Missing

Skills required by the target that do not appear in the user's database at all. List each with:
- Skill name
- Required depth
- Why it matters for the target role
- Whether the user has related/adjacent skills that could accelerate learning

### Bonus Skills

Skills the user has that are NOT required by the target but add value. Explain the value proposition briefly (e.g., "Your GraphQL experience complements the REST API requirements and could modernize the team's approach").

## Step 5: Compute Match Score

Calculate an overall match percentage:

1. Assign each target skill a weight based on priority/requirement level:
   - Required skills: weight = 3
   - Preferred skills: weight = 1
2. For each target skill, compute a fulfillment score:
   - Fully matched (depth >= required): 100%
   - Partially matched (has skill but depth < required): `(current_depth / required_depth) * 100`
   - Missing entirely: 0%
3. Overall score = weighted average of all fulfillment scores.

Present the score with context:
- 80-100%: "Strong match. Focus on closing the remaining gaps to be a standout candidate."
- 60-79%: "Moderate match. Several gaps exist but are addressable with focused effort."
- 40-59%: "Partial match. This role requires significant skill development. Consider intermediate steps."
- Below 40%: "This role is a stretch. Consider targeting a closer role first and building toward this one."

## Step 6: Generate Action Plan

For each gap (skills needing deepening + missing skills), produce a concrete action plan entry:

| Skill | Gap | Suggested Action | Effort | Priority |
|-------|-----|-----------------|--------|----------|
| Kubernetes | used -> designed | Lead a cluster migration at work or set up a production-grade home lab | Large | High |
| Terraform | missing | Start with an Infrastructure-as-Code side project; contribute to existing modules | Medium | High |
| GraphQL | configured -> designed | Design a schema for an existing project; write a technical decision record | Medium | Medium |

**Effort levels**:
- **Small**: Can be achieved in 1-2 weeks of focused work (e.g., tutorials, small contributions)
- **Medium**: Requires 1-3 months of consistent practice (e.g., side project, course + application)
- **Large**: Requires 3-6+ months or significant work experience (e.g., leading a migration, production ownership)

**Suggested action types**:
- Seek a relevant task at current job
- Build a side project
- Contribute to an open-source project
- Take a structured course or certification
- Write about it (blog/talk) to solidify understanding
- Pair with a colleague who has expertise

## Step 7: Save Goals to Database

After presenting the full analysis, ask the user:

> "Would you like to save these skill gaps as career goals? This will let other commands (like `/tech-radar` and `/diagnose-career`) track your progress."

If the user approves:

1. First, check for existing career goals to avoid duplicates:
   ```sql
   SELECT cg.id, s.name, cg.desired_depth
   FROM career_goals cg
   JOIN skills s ON cg.skill_id = s.id
   ```

2. For skills that already exist in the `skills` table, insert career goals directly:
   ```sql
   INSERT INTO career_goals (target_role, skill_id, desired_depth, priority, notes)
   VALUES ('<role>', <skill_id>, '<depth>', <priority>, '<action plan note>')
   ```

3. For skills that are missing from the `skills` table entirely, first insert the skill:
   ```sql
   INSERT INTO skills (name, category) VALUES ('<skill_name>', '<category>')
   ```
   Then insert the career goal referencing the new skill ID.

4. Use `career_write` for all INSERT operations. Confirm each batch before executing.

5. Report what was saved and what was skipped (already existed).

## Guidelines

- Always use `career_read` to fetch data; never assume or fabricate the user's skill information.
- Always confirm before writing to the database using `career_write`.
- Use `career_read` to check for existing data before inserting to avoid duplicates.
- When using Strategy B (Claude's knowledge for role requirements), clearly label these as "typical industry expectations" rather than definitive requirements.
- When parsing job postings (Strategy C), handle ambiguity gracefully -- not every posting maps cleanly to depth levels.
- Back all current-state assessments with actual DB evidence, not assumptions.
- Support both English and Japanese output based on settings.
- Provide actionable, specific recommendations rather than vague advice like "learn more about X".
- If the database has very few skills recorded, acknowledge this limitation and suggest the user import more experience data first.
