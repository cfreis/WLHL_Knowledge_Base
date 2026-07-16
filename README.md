# WLHL Knowledge Base

A portable, offline-first local search engine for The Weight Loss Hotline. The Streamlit application is the product. SQLite Full Text Search powers it; Excel, CSV, and JSON are backup/export formats.

The home screen behaves like a focused search engine: type a topic, phrase, caller problem, or coaching concept and results update immediately. When the search box is empty, it shows recently added episodes and the most common topics. Dedicated pages cover topics, callers, quotes, email ideas, short-form ideas, and review work.

The **All Episodes** page lists every episode by number and title. Its natural-language search separates results into:

- **Main topic is …** — the concept is central in the title, main category, central question, struggle, or core coaching theme.
- **… is mentioned** — the concept appears in frameworks, tags, discovery metadata, or the transcript but is not classified as the main focus.

For example, search `videos where I talked about the Common Sense Diet` to see episodes centered on the framework before episodes that only mention it.

## Manual content editing

Open any episode and expand **Edit Content — Quotes, Email Ideas & Short Hooks**. From there you can add, edit, or delete:

- memorable quotes, including speaker and topic;
- email ideas, including subject line and CTA;
- short hooks, marked as an exact quote or an adaptation.

Changes are saved immediately in `database.sqlite`. Quotes are also refreshed in the episode search index.

## Add an episode manually

Open **Add Episode** in the sidebar. Enter the episode number, title, date, YouTube URL, exact transcript filename, and either upload or paste the transcript. All analysis fields are optional and manual; separate multiple values with semicolons.

The app does not call an AI service. It saves the episode, analysis, and full-text search entries locally. Existing episode numbers and transcript filenames are rejected to protect current records. Uploaded transcript content is stored in SQLite and the original file is not moved, renamed, or overwritten.

## Project layout

- `app.py` — primary search interface
- `database.sqlite` — normalized database and full-text index
- `database/` — Excel, CSV, and JSON exports
- `scripts/` — build, incremental update, search, and Excel export tools
- `config.json` — relative transcript-folder setting
- `processing_log.txt` — latest run summary
- `transcripts/` — optional portable inbox for newly published canonical transcript files
- `../YT Transcripts/` — original canonical read-only source used for this build (never copied or changed)

All saved transcript paths are relative. The application itself is self-contained because searchable transcript text is stored in SQLite. The original `.txt` source files were not duplicated.

## Install and launch

Install Python 3.10 or newer, open a terminal in this folder, then run:

```bash
python -m pip install -r requirements.txt
streamlit run app.py
```

The app opens locally in a browser. It needs no account, server, cloud service, or internet connection after Streamlit is installed.

## Search

Use the large search box for a word, phrase, problem, title, topic, transcript passage, or indexed search term. Results use SQLite FTS5 and rank stronger metadata matches above ordinary transcript occurrences. Filters narrow by episode type, topic, weight-loss stage, caller, and success story.

Command-line search is also available:

```bash
python scripts/search_wlhl_knowledge_base.py "emotional eating"
python scripts/search_wlhl_knowledge_base.py "temporary goals" --limit 10
```

## Add or update episodes

1. Add the new `.txt` file to the project’s `transcripts` folder, or to the configured sibling transcript folder, using the canonical `EP-###` filename.
2. Do not rename older files after indexing unless the filename itself is intentionally being corrected.
3. Run `python update_database.py` or `python scripts/update_wlhl_knowledge_base.py`.
4. Restart or refresh Streamlit.

The update compares SHA-256 file hashes and processes only new or changed transcripts. Existing records remain in place and the search index is refreshed only for changed records. Processing commits after every episode, so an interrupted run resumes safely.

To perform a clean full build, run `python scripts/build_wlhl_knowledge_base.py`.

## Import updated episode analysis

Place the latest reviewed CSV at:

```text
imports/WLHL_episode_enrichment.csv
```

Then run:

```bash
.venv/bin/python scripts/import_enrichment.py
```

The importer matches primarily by normalized episode number (`EP-090`, `EP 090`, `090`, and `90` are equivalent), validates the title, ignores identical duplicate rows, and refuses ambiguous matches. It updates the normalized `episode_enrichment`, `enrichment_values`, and `enrichment_search` tables inside `database.sqlite`. It never updates transcript text or YouTube URLs. A timestamped database backup is created under `database/backups/` before each import, and the validation result is saved to `database/enrichment_import_report.json`.

After importing, stop and reopen the app using `Abrir WLHL.command`, or refresh the browser if the app was already restarted.

## SQLite

Open `database.sqlite` with DB Browser for SQLite or the `sqlite3` command. Core tables are `episodes`, `topics`, `episode_topics`, `episode_terms`, `quotes`, `email_ideas`, `short_hooks`, and `processing_issues`. `episode_search` is the FTS5 index.

Example:

```sql
SELECT e.episode_id, e.episode_title
FROM episode_search s JOIN episodes e ON e.id=s.episode_db_id
WHERE episode_search MATCH 'plateau';
```

## Excel and exports

`database/WLHL_Episode_Database.xlsx` is a formatted backup/export with the complete episode table, indexes, review queue, and dashboard. JSON keeps list fields as arrays. CSV serializes list fields as JSON arrays so commas inside values are preserved.

## Move to another computer

Zip `WLHL Knowledge Base` and send it normally. The application, indexed transcript text, database, and exports are already inside it. The original source files are not required for searching.

If Nick also needs the complete original source-file collection for maintenance, transfer the parent folder containing both sibling folders:

```text
youtube-transcripts/
├── YT Transcripts/
└── WLHL Knowledge Base/
```

Unzip without changing that relationship, install the one requirement, and launch Streamlit. Windows, macOS, and Linux all resolve the same relative paths.

## Semantic-enrichment status

Exact metadata and every transcript are fully indexed locally. Reviewed spreadsheet enrichment is available for the imported episode range and receives stronger search weight than incidental transcript mentions. Episodes without reviewed enrichment retain their existing metadata and full-text transcript search.

For highest-quality enrichment, use a reviewed batch produced by a trusted AI workflow. The safest options are a local model with adequate context and structured-output support, or an approved API after explicit consent regarding cost and data transfer. Import reviewed enrichment into the normalized tables, then rebuild exports and FTS.
