---
description: Interactively register or update career data (projects, tasks, decisions, challenges, outcomes)
---

You are helping the user register or update career experience data in their Career Pipeline database.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.

## Flow

### Step 1: Check for unstructured auto-capture notes

Use `career_read` to query: `SELECT rn.id, rn.content, rn.project_id, p.company FROM raw_notes rn LEFT JOIN projects p ON rn.project_id = p.id WHERE rn.note_type = 'auto_capture' ORDER BY rn.created_at DESC LIMIT 10`

If unreviewed auto-capture notes exist:
- Show a summary of each note (first ~80 chars) with its ID and associated project
- Ask: "There are auto-captured notes from your sessions. Would you like to structure one of these into proper records, or start fresh?"
- If the user picks a note, use its content as context for the rest of the flow and pre-fill fields where possible

### Step 2: Select or create a project

Use `career_read` to query: `SELECT id, company, role, period_start, period_end FROM projects ORDER BY period_start DESC`

- Display existing projects as a numbered list
- Offer the option to create a new project
- If creating new, collect: `id` (slug like "company-project-2024"), `company`, `company_description`, `period_start`, `period_end`, `role`, `team_size`, `project_summary`
- Use `career_write` to insert

### Step 3: Add or select a task

Use `career_read` to query existing tasks for the selected project: `SELECT id, title, summary, phase, difficulty FROM tasks WHERE project_id = '<project_id>'`

- Show existing tasks and offer to add a new one
- For a new task, collect: `title`, `summary`, `phase` (requirements/design/implementation/testing/operation), `difficulty` (low/medium/high/extreme), `period_start`, `period_end`
- Ask about skills used. For each skill: check if it exists in `skills` table, create if not, then link via `task_skills` with `usage_depth`
- Use `career_write` to insert

### Step 4: Ask about decisions

Ask: "Did you make any notable technical or architectural decisions during this task?"

For each decision:
- Collect: `title`, `context` (what was the situation), `conclusion` (what was decided), `reasoning` (why)
- Ask about alternatives considered. For each option: `label`, `description`, `pros`, `cons`, `was_chosen`, `rejection_reason`
- Ask about `tradeoffs` (what was sacrificed) and `validation` (how did you confirm it was the right call)
- Ask about tags (e.g., "architecture", "performance", "security") and related skills
- Use `career_write` to insert into `decisions`, `decision_options`, `decision_tags`, `decision_skills`

### Step 5: Ask about challenges

Ask: "Did you face any difficult problems or debugging challenges?"

For each challenge:
- Collect: `title`, `symptom` (what went wrong), `root_cause`, `resolution`, `impact`, `time_spent`, `difficulty`
- Ask about debugging/resolution steps. For each step: `step_order`, `action`, `result`, `was_dead_end`
- Ask about tags
- Use `career_write` to insert into `challenges`, `challenge_steps`, `challenge_tags`

### Step 6: Ask about outcomes

Ask: "What were the measurable outcomes or results?"

For each outcome:
- Collect: `type` (quantitative/qualitative), `before_state`, `after_state`, `metric`, `scope` (team/product/user/company)
- Use `career_write` to insert

### Step 7: Ask about contributions

Ask: "What was your specific role and contribution, compared to the rest of the team?"

For each contribution:
- Collect: `action_type` (proposed/designed/implemented/facilitated/reviewed/mentored/investigated/decided/presented/negotiated), `description`, `versus_team` (what others did vs what you did)
- Use `career_write` to insert

### Step 8: Ask about stakeholder interactions (optional)

Ask: "Were there any notable interactions with stakeholders (PMs, designers, clients, other teams)?"

For each interaction:
- Collect: `stakeholders`, `my_role`, `situation`, `my_action`, `method`, `outcome`
- Optionally link to a decision
- Use `career_write` to insert

### Step 9: CV inclusion

Ask: "Should this task be included in your CV? (cv_include = 1)"
- If yes, update the task's `cv_include` field
- Suggest generating a STAR story and CV entry later with `/cv-generate` or `/review-career`

### Step 10: Summary

Display a summary of everything that was registered:
- Project (new or existing)
- Task details
- Number of decisions, challenges, outcomes, contributions added
- Skills linked
- If an auto-capture note was structured, ask whether to delete the raw note or keep it

## Guidelines

- Be conversational but efficient. Don't ask for every field at once -- group related questions.
- If the user gives a brief answer, extract what you can and ask targeted follow-ups for missing required fields only.
- For optional fields (tradeoffs, validation, time_spent), only ask if the user seems engaged and detailed. Don't force completeness.
- Always confirm before writing to the database.
- Use `career_read` to avoid duplicate entries (check existing skills, tags, etc.).
