---
description: Import existing CV/resume data (Word, Excel, markdown, or pasted text) into the career-pipeline database
---

You are helping the user import their existing CV or resume data into the Career Pipeline database. This is a bootstrapping tool for users who already have a CV and want to populate their database quickly.

## Setup

1. Read settings from `~/.career-pipeline/settings.json` to determine the user's preferred language (`language`: "en" or "ja"). Default to English if the file does not exist or cannot be read.
2. Conduct the entire interaction in the user's preferred language.

## Flow

### Step 1: Choose import method

Ask the user how they want to import their CV data:

1. **Paste text** - Copy and paste CV content directly into the chat
2. **Provide file path** - Give a local file path (supports `.md`, `.txt`, `.docx`, `.xlsx`, `.csv`)
3. **Provide URL** - Link to an online CV or portfolio page

If the user provides a file path, read the file contents. If the user pastes text, proceed directly with parsing.

### Step 2: Parse the CV content

Extract the following from the CV content:

- **Profile information**: Name, title/role, email, phone, location, GitHub, LinkedIn, website, professional summary
- **Projects/Companies**: Company names, project descriptions, employment periods, roles held, team sizes
- **Skills**: Technical skills, tools, frameworks, languages, methodologies
- **Achievements/Responsibilities**: Key tasks performed at each company/project, deliverables, responsibilities
- **Quantitative results**: Any metrics, percentages, performance improvements, cost savings mentioned

### Step 3: Show parsed data and confirm

Display the parsed data in a structured format organized by:

1. **Profile** - Key-value pairs extracted
2. **Projects** - Table or list of companies/projects with periods and roles
3. **Skills** - Grouped by inferred category (Frontend, Backend, Infrastructure, Database, etc.)
4. **Tasks per project** - Bullet list of responsibilities/achievements under each project
5. **Outcomes** - Any quantitative results detected

Ask the user: "Here's what I extracted from your CV. Please review and let me know if anything needs correction before I write it to the database."

Allow the user to:
- Correct any misinterpreted data
- Add missing information
- Remove entries they don't want imported
- Merge or split projects as needed

### Step 4: Map parsed data to DB tables

Before writing, check for existing data to avoid duplicates:

```sql
SELECT key, value FROM profile
```

```sql
SELECT id, company, role, period_start, period_end FROM projects ORDER BY period_start DESC
```

```sql
SELECT id, name, category FROM skills ORDER BY category, name
```

Map the parsed data as follows:

- **Profile info** -> `profile` table (key-value pairs: name, title, email, github, linkedin, summary, etc.)
- **Each company/project** -> `projects` table (company, company_description, period_start, period_end, role, team_size, project_summary, project_type)
- **Skills mentioned** -> `skills` table (create if not existing, assign inferred category) + `task_skills` (link to relevant tasks with estimated usage_depth)
- **Achievements/responsibilities** -> `tasks` table (one task per distinct responsibility/achievement under each project, with title, summary, inferred phase and difficulty)
- **Quantitative results** -> `outcomes` table (type='quantitative', extract before_state, after_state, metric where possible)

For skill `usage_depth`, infer from context:
- "designed/architected" -> `designed`
- "configured/set up" -> `configured`
- "used/worked with" -> `used`
- "evaluated/compared" -> `evaluated`
- Default to `used` if unclear

### Step 5: Confirm project types

For each project, ask the user to classify its `project_type`:

- `work` - Professional/employment project
- `personal` - Side project or personal work
- `oss` - Open source contribution

Present as a quick list: "Please confirm the type for each project:"
- [Company A] - Project X: `work` / `personal` / `oss`?
- [Company B] - Project Y: `work` / `personal` / `oss`?

### Step 6: Write to DB and show summary

Confirm one final time before writing: "I'm about to write the following to the database: [count] profile entries, [count] projects, [count] tasks, [count] skills, [count] skill links, [count] outcomes. Proceed?"

Use `career_write` to insert all records in this order:
1. `profile` entries
2. `skills` entries (check for existing first)
3. `projects` entries
4. `tasks` entries (under their respective projects)
5. `task_skills` links
6. `outcomes` entries (if any)

After writing, display a summary:

```
Import complete!
- Profile: [N] entries
- Projects: [N] created
- Tasks: [N] created across all projects
- Skills: [N] new skills added, [M] existing skills linked
- Outcomes: [N] quantitative results recorded
```

### Step 7: Post-import guidance

Inform the user:

> **Note:** Imported data from a CV is typically lower-fidelity than data entered interactively via `/update-task`. CV bullet points often lack the rich context (decision reasoning, debugging steps, tradeoffs, specific contributions) that makes your career data truly powerful for interview prep and content generation.
>
> I recommend enriching your most important entries by running:
> - `/update-task` to add decisions, challenges, and detailed contributions for key projects
> - `/review-career` to identify and fill gaps in the imported data
> - Set `cv_include = 1` on tasks you want in your generated CV

## Guidelines

- Always confirm before writing to the database.
- Use `career_read` to check existing data before inserting duplicates (especially skills and profile entries).
- Generate reasonable `id` slugs for projects (e.g., "companyname-projectname-2024") and tasks (e.g., "companyname-task-title").
- If the CV is sparse or hard to parse, ask clarifying questions rather than guessing.
- For skills categorization, use consistent categories: Frontend, Backend, Infrastructure, Database, DevOps, Mobile, Testing, Design, Management, etc.
- Be transparent about what could not be extracted and suggest the user add it manually.
- Keep output actionable and professional.
