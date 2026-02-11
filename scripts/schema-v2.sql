-- Career Pipeline Schema v2
-- Migration version: 2
-- Adds: project_type, content_ideas, career_goals

-- ============================================
-- 1. Add project_type to projects
-- ============================================

ALTER TABLE projects ADD COLUMN project_type TEXT DEFAULT 'work'
  CHECK(project_type IN ('work', 'personal', 'oss'));

-- ============================================
-- 2. Content ideas (Render pipeline candidates)
-- ============================================

CREATE TABLE IF NOT EXISTS content_ideas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  source_type TEXT NOT NULL CHECK(source_type IN ('decision', 'challenge', 'outcome', 'task')),
  source_id INTEGER NOT NULL,
  render_target TEXT NOT NULL CHECK(render_target IN ('blog', 'talk', 'podcast', 'linkedin', 'other')),
  title TEXT,
  angle TEXT,
  status TEXT DEFAULT 'idea' CHECK(status IN ('idea', 'drafted', 'published')),
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_content_ideas_source ON content_ideas(source_type, source_id);
CREATE INDEX IF NOT EXISTS idx_content_ideas_target ON content_ideas(render_target);
CREATE INDEX IF NOT EXISTS idx_content_ideas_status ON content_ideas(status);

-- ============================================
-- 3. Career goals (skill gap analysis)
-- ============================================

CREATE TABLE IF NOT EXISTS career_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  target_role TEXT,
  skill_id INTEGER REFERENCES skills(id) ON DELETE CASCADE,
  desired_depth TEXT CHECK(desired_depth IN ('used', 'configured', 'designed', 'evaluated')),
  priority TEXT DEFAULT 'medium' CHECK(priority IN ('high', 'medium', 'low')),
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_career_goals_skill ON career_goals(skill_id);
CREATE INDEX IF NOT EXISTS idx_career_goals_role ON career_goals(target_role);

-- Record this migration
INSERT OR IGNORE INTO schema_versions (version) VALUES (2);
