-- Schema for the GPLX theory-prep clone. SQLite, used through drift (Flutter).
-- Two databases, on purpose:
--   content.db  read-only, built by the content pipeline and shipped in assets.
--               Replaced wholesale when the official question set or the rules change.
--   user.db     read-write, created on first launch. Never shipped, never replaced.
-- User data points at content by stable text keys (question_key, class_code),
-- so a new content.db does not break progress.
--
-- Deviations from the server defaults in the skill, and why:
--   * no uuid / owner columns: one person per install, no server, no accounts.
--   * no row level security: there is no multi-user access. The only access rule is
--     "content.db is opened read-only".
--   * times are INTEGER unix milliseconds in UTC (SQLite has no timestamptz).
--   * no money columns: the app is free.

------------------------------------------------------------------------------
-- content.db
------------------------------------------------------------------------------

-- Which official set and rules this file was built from. One row.
CREATE TABLE content_meta (
  id              INTEGER PRIMARY KEY CHECK (id = 1),
  content_version INTEGER NOT NULL,          -- bumps on every rebuild
  bank_code       TEXT    NOT NULL,          -- e.g. '2025' for the 600-question set
  source_ref      TEXT    NOT NULL,          -- e.g. 'Cong van 2262/CSGT-P5, 2025-05-07'
  rules_ref       TEXT    NOT NULL,          -- e.g. 'Thong tu 12/2025/TT-BCA'
  effective_from  TEXT    NOT NULL,          -- ISO date the set is used in real exams
  built_at        INTEGER NOT NULL
);

CREATE TABLE license_classes (
  code               TEXT PRIMARY KEY
                     CHECK (code IN ('A1','A','B1','B','C1','C','D1','D2','D',
                                     'BE','C1E','CE','D1E','D2E','DE')),
  name               TEXT    NOT NULL,       -- 'Hạng A1'
  vehicle_group      TEXT    NOT NULL CHECK (vehicle_group IN ('moto','car','truck','bus','trailer')),
  description        TEXT    NOT NULL,       -- own writing
  exam_question_count INTEGER NOT NULL CHECK (exam_question_count > 0),
  exam_minutes       INTEGER NOT NULL CHECK (exam_minutes > 0),
  pass_mark          INTEGER NOT NULL,
  critical_per_exam  INTEGER NOT NULL DEFAULT 1 CHECK (critical_per_exam >= 0),
  rules_verified     INTEGER NOT NULL DEFAULT 0 CHECK (rules_verified IN (0,1)),
  sort_order         INTEGER NOT NULL,
  CHECK (pass_mark BETWEEN 1 AND exam_question_count)
);

CREATE TABLE topics (
  id          INTEGER PRIMARY KEY,           -- official chapter number
  name        TEXT    NOT NULL,
  short_name  TEXT    NOT NULL,
  sort_order  INTEGER NOT NULL
);

CREATE TABLE questions (
  key          TEXT PRIMARY KEY,             -- '2025-001'..'2025-600', stable forever
  number       INTEGER NOT NULL,             -- official number 1..600
  topic_id     INTEGER NOT NULL REFERENCES topics(id) ON DELETE RESTRICT,
  text         TEXT    NOT NULL,
  image        TEXT,                         -- asset path, NULL if text-only
  is_critical  INTEGER NOT NULL DEFAULT 0 CHECK (is_critical IN (0,1)),
  explanation  TEXT    NOT NULL,             -- own writing, never copied
  tip          TEXT,                         -- own writing
  UNIQUE (number)
);
CREATE INDEX questions_topic   ON questions (topic_id, number);
CREATE INDEX questions_critical ON questions (is_critical) WHERE is_critical = 1;

CREATE TABLE question_options (
  question_key TEXT    NOT NULL REFERENCES questions(key) ON DELETE CASCADE,
  position     INTEGER NOT NULL CHECK (position BETWEEN 1 AND 4),
  text         TEXT    NOT NULL,
  is_correct   INTEGER NOT NULL CHECK (is_correct IN (0,1)),
  PRIMARY KEY (question_key, position)
);
-- Exactly one correct option per question.
CREATE UNIQUE INDEX one_correct_option ON question_options (question_key) WHERE is_correct = 1;

-- Which questions can appear for which class (250 for motorbike classes, etc.).
CREATE TABLE class_questions (
  class_code   TEXT NOT NULL REFERENCES license_classes(code) ON DELETE CASCADE,
  question_key TEXT NOT NULL REFERENCES questions(key) ON DELETE CASCADE,
  PRIMARY KEY (class_code, question_key)
);
CREATE INDEX class_questions_question ON class_questions (question_key);

-- How many questions of each topic a real exam for this class draws.
-- Sum per class must equal exam_question_count (checked by the pipeline).
-- Critical questions are drawn separately (critical_per_exam), from the class pool.
CREATE TABLE class_topic_quota (
  class_code  TEXT    NOT NULL REFERENCES license_classes(code) ON DELETE CASCADE,
  topic_id    INTEGER NOT NULL REFERENCES topics(id) ON DELETE RESTRICT,
  count       INTEGER NOT NULL CHECK (count >= 0),
  PRIMARY KEY (class_code, topic_id)
);

-- Fixed numbered practice sets ("Đề 1", "Đề 2"...), generated once by the
-- pipeline with the same rules as a random exam, so they are stable across users.
CREATE TABLE exam_sets (
  id          INTEGER PRIMARY KEY,
  class_code  TEXT    NOT NULL REFERENCES license_classes(code) ON DELETE CASCADE,
  number      INTEGER NOT NULL,
  UNIQUE (class_code, number)
);
CREATE TABLE exam_set_questions (
  exam_set_id  INTEGER NOT NULL REFERENCES exam_sets(id) ON DELETE CASCADE,
  position     INTEGER NOT NULL,
  question_key TEXT    NOT NULL REFERENCES questions(key) ON DELETE RESTRICT,
  PRIMARY KEY (exam_set_id, position),
  UNIQUE (exam_set_id, question_key)
);

CREATE TABLE sign_groups (
  id          INTEGER PRIMARY KEY,
  name        TEXT    NOT NULL,              -- 'Biển báo cấm'
  sort_order  INTEGER NOT NULL
);
CREATE TABLE signs (
  code        TEXT PRIMARY KEY,              -- 'P.102'
  group_id    INTEGER NOT NULL REFERENCES sign_groups(id) ON DELETE RESTRICT,
  name        TEXT    NOT NULL,
  meaning     TEXT    NOT NULL,              -- own writing, based on QCVN 41
  image       TEXT    NOT NULL,              -- own redrawn SVG/WebP
  sort_order  INTEGER NOT NULL
);
CREATE INDEX signs_group ON signs (group_id, sort_order);

CREATE TABLE articles (
  id          INTEGER PRIMARY KEY,
  kind        TEXT    NOT NULL CHECK (kind IN ('tip','faq')),
  topic_id    INTEGER REFERENCES topics(id) ON DELETE SET NULL,
  title       TEXT    NOT NULL,
  body_md     TEXT    NOT NULL,              -- own writing, markdown
  sort_order  INTEGER NOT NULL
);
CREATE INDEX articles_kind ON articles (kind, sort_order);

-- Search over question text (could-have, cheap to ship now).
CREATE VIRTUAL TABLE questions_fts USING fts5 (
  key UNINDEXED, text, content='questions', content_rowid='rowid',
  tokenize = 'unicode61 remove_diacritics 2'   -- 'bien bao' matches 'biển báo'
);

------------------------------------------------------------------------------
-- user.db
------------------------------------------------------------------------------

-- Key/value app state: selected class, onboarding done, theme, last content_version seen.
CREATE TABLE settings (
  key         TEXT PRIMARY KEY,
  value       TEXT NOT NULL,
  updated_at  INTEGER NOT NULL
);

-- One row per question per class. Progress is per class because pools differ
-- and a learner switching from A1 to B wants a clean B progress bar.
CREATE TABLE question_progress (
  class_code       TEXT    NOT NULL,
  question_key     TEXT    NOT NULL,
  times_seen       INTEGER NOT NULL DEFAULT 0,
  times_wrong      INTEGER NOT NULL DEFAULT 0,
  last_correct     INTEGER CHECK (last_correct IN (0,1)),   -- NULL = never answered
  in_wrong_list    INTEGER NOT NULL DEFAULT 0 CHECK (in_wrong_list IN (0,1)),
  last_answered_at INTEGER,
  updated_at       INTEGER NOT NULL,
  PRIMARY KEY (class_code, question_key)
);
CREATE INDEX progress_wrong ON question_progress (class_code, last_answered_at)
  WHERE in_wrong_list = 1;

-- Bookmarks are global: a saved question is saved whatever class you are on.
CREATE TABLE bookmarks (
  question_key TEXT PRIMARY KEY,
  created_at   INTEGER NOT NULL
);
CREATE INDEX bookmarks_created ON bookmarks (created_at);

-- Where the learner stopped in each topic, to resume.
CREATE TABLE topic_cursor (
  class_code    TEXT    NOT NULL,
  topic_id      INTEGER NOT NULL,
  position      INTEGER NOT NULL DEFAULT 0,
  updated_at    INTEGER NOT NULL,
  PRIMARY KEY (class_code, topic_id)
);

CREATE TABLE exam_attempts (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  class_code         TEXT    NOT NULL,
  exam_set_id        INTEGER,                -- NULL = random exam
  content_version    INTEGER NOT NULL,       -- content.db it was taken against
  status             TEXT    NOT NULL DEFAULT 'in_progress'
                     CHECK (status IN ('in_progress','submitted','timed_out','abandoned')),
  started_at         INTEGER NOT NULL,
  deadline_at        INTEGER NOT NULL,       -- started_at + exam_minutes; the timer reads this
  finished_at        INTEGER,
  question_count     INTEGER NOT NULL,
  pass_mark          INTEGER NOT NULL,       -- copied, so old results stay right after a rules change
  score              INTEGER,
  passed             INTEGER CHECK (passed IN (0,1)),
  failed_on_critical INTEGER CHECK (failed_on_critical IN (0,1)),
  CHECK (deadline_at > started_at),
  CHECK (status = 'in_progress' OR finished_at IS NOT NULL)
);
CREATE INDEX attempts_history ON exam_attempts (class_code, started_at DESC);
CREATE INDEX attempts_set     ON exam_attempts (exam_set_id, score DESC) WHERE exam_set_id IS NOT NULL;
-- At most one exam running at a time.
CREATE UNIQUE INDEX one_running_exam ON exam_attempts (status) WHERE status = 'in_progress';

-- The questions of an attempt, in order, with the answer as it was given.
-- Written on every tap, so a killed app resumes exactly where it was.
CREATE TABLE attempt_answers (
  attempt_id      INTEGER NOT NULL REFERENCES exam_attempts(id) ON DELETE CASCADE,
  position        INTEGER NOT NULL,
  question_key    TEXT    NOT NULL,
  is_critical     INTEGER NOT NULL CHECK (is_critical IN (0,1)),  -- copied at generation
  chosen_position INTEGER CHECK (chosen_position BETWEEN 1 AND 4), -- NULL = unanswered
  is_correct      INTEGER CHECK (is_correct IN (0,1)),            -- set at grading
  answered_at     INTEGER,
  PRIMARY KEY (attempt_id, position),
  UNIQUE (attempt_id, question_key)
);
