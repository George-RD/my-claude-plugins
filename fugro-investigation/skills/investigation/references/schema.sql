-- ──────────────────────────────────────────────────────────────
-- investigation.db — Schema for Fugro incident investigations
-- Located at: /Users/george/COWORK/investigation.db
-- ──────────────────────────────────────────────────────────────

PRAGMA foreign_keys = ON;
PRAGMA busy_timeout = 15000;

-- ── CASE METADATA ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS case_meta (
    id              INTEGER PRIMARY KEY,
    case_id         TEXT NOT NULL UNIQUE,          -- 'F263551'
    title           TEXT,
    sphera_number   TEXT,
    status          TEXT DEFAULT 'active'
                    CHECK(status IN ('active','closed','on_hold')),
    client          TEXT,
    vessel          TEXT,
    field_area      TEXT,
    summary         TEXT,
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    updated_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── PEOPLE ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS person (
    id              TEXT PRIMARY KEY,              -- slug: 'george-reid-dowd'
    name            TEXT NOT NULL,
    role            TEXT,
    email           TEXT,
    location        TEXT,
    tier            TEXT CHECK(tier IN ('primary','secondary','supporting','peripheral')),
    involvement     TEXT,                          -- narrative description
    email_count     INTEGER DEFAULT 0,
    first_email     TEXT,                          -- ISO date
    last_email      TEXT,                          -- ISO date
    poet            TEXT CHECK(poet IN ('People','Organisation','Environment','Technology')),
    departure_date  TEXT,                          -- ISO date, NULL if still employed
    gender          TEXT CHECK(gender IN ('M','F')),
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── TIMELINE EVENTS ────────────────────────────────────────

CREATE TABLE IF NOT EXISTS timeline_event (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    event_date      TEXT NOT NULL,                 -- ISO date or descriptive ('~mid October')
    title           TEXT NOT NULL,
    description     TEXT,
    type            TEXT CHECK(type IN ('action','escalation','gap','milestone','departure'))
                    DEFAULT 'action',
    is_key_event    INTEGER DEFAULT 0,             -- 0 or 1
    poet            TEXT CHECK(poet IN ('People','Organisation','Environment','Technology')),
    people          TEXT,                           -- JSON array: '["George Reid-Dowd","Dirk Bester"]'
    email_ids       TEXT,                           -- JSON array: '["#865","#844"]'
    sort_order      INTEGER,                        -- for ordering ambiguous dates
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── CONFIRMED EVIDENCE ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS evidence (
    id              TEXT PRIMARY KEY,              -- 'E01', 'E02', etc.
    text            TEXT NOT NULL,
    sources         TEXT NOT NULL DEFAULT '[]',    -- JSON array: '["#865","#844"]'
    poet            TEXT CHECK(poet IN ('People','Organisation','Environment','Technology')),
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── ASSUMPTIONS (UNVERIFIED) ───────────────────────────────

CREATE TABLE IF NOT EXISTS assumption (
    id              TEXT PRIMARY KEY,              -- 'A01', 'A02', etc.
    text            TEXT NOT NULL,
    confidence      TEXT CHECK(confidence IN ('LOW','MED','HIGH')) DEFAULT 'MED',
    sources         TEXT DEFAULT '[]',             -- JSON array
    poet            TEXT CHECK(poet IN ('People','Organisation','Environment','Technology')),
    resolved        INTEGER DEFAULT 0,             -- 0=open, 1=resolved
    resolution      TEXT,                          -- what we found out
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    updated_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── OPEN QUESTIONS / INVESTIGATION ANGLES ──────────────────

CREATE TABLE IF NOT EXISTS question (
    id              TEXT PRIMARY KEY,              -- 'Q01', 'Q02', etc.
    text            TEXT NOT NULL,
    priority        TEXT CHECK(priority IN ('CRITICAL','HIGH','MEDIUM','LOW')) DEFAULT 'MEDIUM',
    poet            TEXT CHECK(poet IN ('People','Organisation','Environment','Technology')),
    status          TEXT DEFAULT 'open'
                    CHECK(status IN ('open','investigating','answered','closed')),
    answer          TEXT,                          -- filled when answered
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    updated_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── INVESTIGATION NOTES ────────────────────────────────────
-- Freeform findings, thoughts, angles, interview notes.
-- This is the "working memory" — lower rigour than evidence.

CREATE TABLE IF NOT EXISTS note (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    type            TEXT CHECK(type IN ('finding','thought','angle','interview_note','correction'))
                    DEFAULT 'finding',
    content         TEXT NOT NULL,
    related_ids     TEXT DEFAULT '[]',             -- JSON array of E/A/Q IDs: '["E12","Q06"]'
    related_people  TEXT DEFAULT '[]',             -- JSON array of person names
    source          TEXT,                          -- where this came from
    status          TEXT DEFAULT 'pending'
                    CHECK(status IN ('pending','verified','dismissed','incorporated')),
    poet            TEXT CHECK(poet IN ('People','Organisation','Environment','Technology')),
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    updated_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── CONNECTIONS (PEOPLE RELATIONSHIPS) ─────────────────────

CREATE TABLE IF NOT EXISTS connection (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    from_person     TEXT NOT NULL,                 -- person name
    to_person       TEXT NOT NULL,                 -- person name
    type            TEXT DEFAULT 'collaboration',
    label           TEXT,
    strength        REAL DEFAULT 0.5
                    CHECK(strength >= 0.0 AND strength <= 1.0),
    email_ids       TEXT DEFAULT '[]',             -- JSON array
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── COMMUNICATION GAPS ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS gap (
    id              TEXT PRIMARY KEY,              -- 'GAP1', 'GAP2'
    start_date      TEXT NOT NULL,                 -- ISO date
    end_date        TEXT NOT NULL,                 -- ISO date
    duration_days   INTEGER,
    label           TEXT,
    description     TEXT,
    what_should_have_happened TEXT,
    status          TEXT DEFAULT 'unaccounted'
                    CHECK(status IN ('unaccounted','partially_explained','explained'))
);

-- ── DELIVERABLES ───────────────────────────────────────────

CREATE TABLE IF NOT EXISTS deliverable (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT NOT NULL,
    status          TEXT CHECK(status IN (
                        'not_started','blocked','unknown','pending',
                        'not_assembled','in_progress','complete'
                    )) DEFAULT 'not_started',
    blocker         TEXT,
    effort_estimate TEXT,
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    updated_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── POET CAUSAL FACTORS (for TOP SET storyboard) ──────────

CREATE TABLE IF NOT EXISTS poet_factor (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    category        TEXT NOT NULL
                    CHECK(category IN ('People','Organisation','Environment','Technology')),
    factor_type     TEXT NOT NULL
                    CHECK(factor_type IN ('contributing','systemic','mitigating','disputed','context')),
    text            TEXT NOT NULL,
    related_evidence TEXT DEFAULT '[]',            -- JSON array of evidence IDs
    created_at      TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ── TOP SET STEPS ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS topset_step (
    id              INTEGER PRIMARY KEY,           -- 1-6
    name            TEXT NOT NULL,
    status          TEXT DEFAULT 'not_started'
                    CHECK(status IN ('not_started','in_progress','partial','complete')),
    items           TEXT DEFAULT '[]'              -- JSON array of {text, done} objects
);

-- ── INVESTIGATION PHASES ───────────────────────────────────

CREATE TABLE IF NOT EXISTS investigation_phase (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT NOT NULL,
    status          TEXT DEFAULT 'not_started'
                    CHECK(status IN ('not_started','in_progress','mostly_complete','complete')),
    sort_order      INTEGER,
    items           TEXT DEFAULT '[]'              -- JSON array of {text, done} objects
);

-- ── VIEWS ──────────────────────────────────────────────────

CREATE VIEW IF NOT EXISTS v_evidence_summary AS
SELECT
    'confirmed' as category,
    COUNT(*) as count,
    GROUP_CONCAT(DISTINCT poet) as poet_categories
FROM evidence
UNION ALL
SELECT 'assumption', COUNT(*), GROUP_CONCAT(DISTINCT poet) FROM assumption WHERE resolved = 0
UNION ALL
SELECT 'question', COUNT(*), GROUP_CONCAT(DISTINCT poet) FROM question WHERE status != 'closed'
UNION ALL
SELECT 'note', COUNT(*), GROUP_CONCAT(DISTINCT poet) FROM note WHERE status = 'pending';

CREATE VIEW IF NOT EXISTS v_timeline_with_gaps AS
SELECT
    event_date,
    title,
    description,
    type,
    is_key_event,
    poet,
    people,
    email_ids,
    sort_order
FROM timeline_event
ORDER BY
    CASE
        WHEN event_date GLOB '[0-9][0-9][0-9][0-9]-*' THEN event_date
        ELSE '9999-99-99'
    END,
    sort_order;

CREATE VIEW IF NOT EXISTS v_unsourced_evidence AS
SELECT id, text FROM evidence
WHERE sources IS NULL OR sources = '[]' OR sources = '';

CREATE VIEW IF NOT EXISTS v_open_questions AS
SELECT id, text, priority, poet, status
FROM question
WHERE status IN ('open', 'investigating')
ORDER BY
    CASE priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END;

CREATE VIEW IF NOT EXISTS v_pending_notes AS
SELECT id, type, content, related_ids, source, created_at
FROM note
WHERE status = 'pending'
ORDER BY created_at DESC;
