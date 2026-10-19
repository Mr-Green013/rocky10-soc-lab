**English** · [ภาษาไทย](README.th.md)

# Bilingual tooling (Thai / English)

The repo is maintained in Thai first (it accompanies a Thai book) and every part has an English layer. These tools keep the two in step and fail loudly when something new has not been translated yet.

| What | English version | Tool | Translations |
| --- | --- | --- | --- |
| Docs | `X.md` (English) next to `X.th.md` (Thai), switcher on line 1 | `md_split.py check` | written by hand |
| Comments in scripts and configs | an `EN:` comment above each Thai comment, or `(EN: …)` on the same line | `comments.py` | `comments.en.json` |
| Diagrams | `assets/diagrams/chNN/en/*.svg` + `.png` | `diagrams-en.js` | `diagrams.en.json` |
| 60-day study plan | `docs/study-plan.md` | `gen-studyplan-md.js` in the book build (writes both languages) | English overlay of the plan data |

What stays Thai on purpose: the messages scripts print and the `<description>` of Wazuh rules. They are program output that the book shows, so they must match it. The Thai diagram set is the one the book uses and is never modified.

## Checks (run before every commit)

```bash
python3 tools/i18n/md_split.py check       # every doc has both languages, switchers, links resolve
python3 tools/i18n/comments.py check       # every Thai comment has its English line
node tools/i18n/diagrams-en.js --check     # every Thai diagram label has a translation
```

## When you change something

- **New or edited Thai comment**: run `python3 tools/i18n/comments.py scan` to list comments without a translation, add them to `comments.en.json`, then `python3 tools/i18n/comments.py apply`. `apply` is idempotent and keeps each file's line endings and BOM; `strip` removes every English line again (the exact inverse). A translation that starts with `@inline ` stays on the same line — used for marker lines that scripts search for, such as `# SOCLAB-BEGIN`, so a rerun never leaves an extra line behind.
- **New or edited diagram**: add any new Thai label to `diagrams.en.json`, then rebuild the English set (needs Node and playwright; `FONT_DIR` points at the Sarabun/JetBrains Mono `.woff2` files):

  ```bash
  NODE_PATH=<dir>/node_modules FONT_DIR=<fonts dir> node tools/i18n/diagrams-en.js
  ```

  Each translated label is measured in Chromium; if it is wider than both its box and the original Thai label, its font size is reduced until it fits (down to 60%). The run prints how many labels were shrunk and any that still do not fit.
- **Doc**: edit both `X.md` and `X.th.md`. Commands inside code blocks must stay identical in both; only comments and prose are translated.
- **Files under `chNN-*/files/`**: these are generated from the book by `export-files.js`, which also writes both READMEs and runs `comments.py apply`, so regenerate rather than editing by hand.
