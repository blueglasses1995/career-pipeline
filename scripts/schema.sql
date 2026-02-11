-- Career Pipeline Schema v1
-- Migration version: 1

-- ============================================
-- 0. Schema versioning
-- ============================================

CREATE TABLE IF NOT EXISTS schema_versions (
  version INTEGER PRIMARY KEY,
  applied_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 1. Skills master
-- ============================================

CREATE TABLE IF NOT EXISTS skills (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  category TEXT NOT NULL CHECK (category IN (
    'frontend', 'backend', 'infra', 'ai', 'data', 'devops', 'mobile', 'testing', 'other'
  )),
  created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 2. Projects
-- ============================================

CREATE TABLE IF NOT EXISTS projects (
  id TEXT PRIMARY KEY,
  company TEXT NOT NULL,
  company_description TEXT,
  period_start TEXT NOT NULL,
  period_end TEXT,
  role TEXT NOT NULL,
  team_size INTEGER,
  project_summary TEXT,
  cv_include INTEGER DEFAULT 0,
  cv_order INTEGER,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 3. Tasks
-- ============================================

CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id TEXT NOT NULL REFERENCES projects(id),
  title TEXT NOT NULL,
  summary TEXT,
  period_start TEXT,
  period_end TEXT,
  phase TEXT CHECK (phase IN ('requirements', 'design', 'implementation', 'testing', 'operation')),
  difficulty TEXT CHECK (difficulty IN ('low', 'medium', 'high', 'extreme')),
  cv_include INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS task_skills (
  task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  skill_id INTEGER NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  usage_depth TEXT CHECK (usage_depth IN ('used', 'configured', 'designed', 'evaluated')),
  PRIMARY KEY (task_id, skill_id)
);

-- ============================================
-- 4. Decisions (core entity)
-- ============================================

CREATE TABLE IF NOT EXISTS decisions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  context TEXT NOT NULL,
  conclusion TEXT NOT NULL,
  reasoning TEXT NOT NULL,
  tradeoffs TEXT,
  validation TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS decision_options (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  decision_id INTEGER NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  description TEXT,
  pros TEXT,
  cons TEXT,
  was_chosen INTEGER DEFAULT 0,
  rejection_reason TEXT
);

CREATE TABLE IF NOT EXISTS decision_tags (
  decision_id INTEGER NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  PRIMARY KEY (decision_id, tag)
);

CREATE TABLE IF NOT EXISTS decision_skills (
  decision_id INTEGER NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
  skill_id INTEGER NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  PRIMARY KEY (decision_id, skill_id)
);

-- ============================================
-- 5. Challenges (problem-solving stories)
-- ============================================

CREATE TABLE IF NOT EXISTS challenges (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  symptom TEXT NOT NULL,
  root_cause TEXT,
  resolution TEXT,
  impact TEXT,
  time_spent TEXT,
  difficulty TEXT CHECK (difficulty IN ('low', 'medium', 'high', 'extreme')),
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS challenge_steps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  challenge_id INTEGER NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  step_order INTEGER NOT NULL,
  action TEXT NOT NULL,
  result TEXT NOT NULL,
  was_dead_end INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS challenge_tags (
  challenge_id INTEGER NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  PRIMARY KEY (challenge_id, tag)
);

-- ============================================
-- 6. Stakeholder interactions
-- ============================================

CREATE TABLE IF NOT EXISTS stakeholder_interactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER REFERENCES tasks(id) ON DELETE CASCADE,
  decision_id INTEGER REFERENCES decisions(id) ON DELETE SET NULL,
  stakeholders TEXT NOT NULL,
  my_role TEXT NOT NULL,
  situation TEXT NOT NULL,
  my_action TEXT NOT NULL,
  method TEXT,
  outcome TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 7. Outcomes (with before/after)
-- ============================================

CREATE TABLE IF NOT EXISTS outcomes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('quantitative', 'qualitative')),
  before_state TEXT,
  after_state TEXT,
  metric TEXT,
  scope TEXT CHECK (scope IN ('team', 'product', 'user', 'company')),
  created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 8. Contributions (my role clarity)
-- ============================================

CREATE TABLE IF NOT EXISTS contributions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  action_type TEXT NOT NULL CHECK (action_type IN (
    'proposed', 'designed', 'implemented', 'facilitated',
    'reviewed', 'mentored', 'investigated', 'decided',
    'presented', 'negotiated'
  )),
  description TEXT NOT NULL,
  versus_team TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 9. Raw notes (unstructured dump)
-- ============================================

CREATE TABLE IF NOT EXISTS raw_notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER REFERENCES tasks(id) ON DELETE CASCADE,
  project_id TEXT REFERENCES projects(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  note_type TEXT DEFAULT 'general' CHECK (note_type IN (
    'general', 'interview_prep', 'blog_idea', 'retrospective', 'auto_capture'
  )),
  created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 10. CV & interview output (polished)
-- ============================================

CREATE TABLE IF NOT EXISTS cv_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  lang TEXT NOT NULL DEFAULT 'ja',
  content TEXT NOT NULL,
  version INTEGER DEFAULT 1,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS star_stories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  situation TEXT NOT NULL,
  task_description TEXT NOT NULL,
  action TEXT NOT NULL,
  result TEXT NOT NULL,
  lang TEXT NOT NULL DEFAULT 'ja',
  target_question TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- 11. Profile (key-value)
-- ============================================

CREATE TABLE IF NOT EXISTS profile (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- Indexes
-- ============================================

CREATE INDEX IF NOT EXISTS idx_tasks_project ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_decisions_task ON decisions(task_id);
CREATE INDEX IF NOT EXISTS idx_challenges_task ON challenges(task_id);
CREATE INDEX IF NOT EXISTS idx_challenge_steps_order ON challenge_steps(challenge_id, step_order);
CREATE INDEX IF NOT EXISTS idx_outcomes_task ON outcomes(task_id);
CREATE INDEX IF NOT EXISTS idx_contributions_task ON contributions(task_id);
CREATE INDEX IF NOT EXISTS idx_contributions_type ON contributions(action_type);
CREATE INDEX IF NOT EXISTS idx_stakeholder_task ON stakeholder_interactions(task_id);
CREATE INDEX IF NOT EXISTS idx_stakeholder_decision ON stakeholder_interactions(decision_id);
CREATE INDEX IF NOT EXISTS idx_cv_entries_lang ON cv_entries(task_id, lang);
CREATE INDEX IF NOT EXISTS idx_raw_notes_task ON raw_notes(task_id);
CREATE INDEX IF NOT EXISTS idx_decision_tags_tag ON decision_tags(tag);
CREATE INDEX IF NOT EXISTS idx_challenge_tags_tag ON challenge_tags(tag);

-- Record this migration
INSERT OR IGNORE INTO schema_versions (version) VALUES (1);
