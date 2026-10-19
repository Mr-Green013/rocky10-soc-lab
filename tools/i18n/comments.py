#!/usr/bin/env python3
"""Bilingual comments for scripts and config files.

Every Thai comment gets an English translation from comments.en.json:

  full-line comment   ->  an "EN:" comment line is inserted above it, same indent
                          and same comment marker, e.g.
                              # EN: Check rules for each CVE
                              # ตรวจ rule ของแต่ละ CVE
  trailing comment    ->  the English is appended inside the same comment, so the
                          code on that line (and any line continuation) is untouched:
                              cmd ...   # ภาษาไทย (EN: English)

A translation that starts with "@inline " is always appended on the same line. That is
used for marker lines that scripts search for (e.g. "# SOCLAB-BEGIN") and for commented
usage examples, so a rerun of the script never leaves an extra line behind.

Strings that scripts print, and rule descriptions, are NOT changed: they are
program output and must match the book.

  comments.py scan  [PATH...]   list Thai comments that have no translation yet
  comments.py apply [PATH...]   insert/append translations (idempotent)
  comments.py check [PATH...]   exit 1 if any Thai comment lacks its English line
  comments.py strip [PATH...]   remove every EN: line/suffix (exact inverse of apply)
PATH defaults to the whole repo.
"""
import json
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
MAP_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'comments.en.json')
THAI = re.compile('[฀-๿]')
SKIP_EXT = {'.md', '.svg', '.png', '.pyc', '.json', '.csv'}
HASH_EXT = {'.sh', '.bash', '.py', '.yaml', '.yml', '.conf', '.rules', '.tf', '.ps1', '.env',
            '.example', '.service', '.timer', '.tfvars', ''}


def trailing_ok(path):
    """Formats where '# comment' after code is a real comment. Elsewhere (systemd units,
    .gitignore, audit .rules, logrotate, .env) a mid-line '#' is part of the value."""
    ext = os.path.splitext(path)[1]
    if ext in {'.sh', '.bash', '.py', '.yaml', '.yml', '.tf', '.ps1', '.conf'}:
        return not path.endswith('.d/smbd_audit')
    if ext == '':
        try:
            return open(path, encoding='utf-8').readline().startswith('#!')
        except (UnicodeDecodeError, OSError):
            return False
    return False


def kind_of(path):
    ext = os.path.splitext(path)[1]
    if path.endswith('.tfvars.example'):
        return 'hash'
    if ext == '.xml':
        return 'xml'
    if ext in HASH_EXT:
        return 'hash'
    return None


def split_hash(line, kind_path):
    """Return (code, marker, comment) for a '#'-comment language, quote-aware.
    marker is the comment opener ('#', '//' for .tf); comment excludes it."""
    q = None
    i = 0
    tf = kind_path.endswith('.tf')
    while i < len(line):
        c = line[i]
        if q:
            if c == '\\' and q == '"':
                i += 2
                continue
            if c == q:
                q = None
        elif c in '"\'':
            # a lone apostrophe inside a word (it's, don't) is not a quote
            if c == "'" and i > 0 and line[i - 1].isalnum() and i + 1 < len(line) and line[i + 1].isalnum():
                pass
            else:
                q = c
        elif c == '#' and (i == 0 or line[i - 1] in ' \t'):
            j = i
            while j < len(line) and line[j] == '#':
                j += 1
            return line[:i], line[i:j], line[j:]
        elif tf and line.startswith('//', i) and (i == 0 or line[i - 1] in ' \t'):
            return line[:i], '//', line[i + 2:]
        i += 1
    return line, '', ''


XML_COMMENT = re.compile(r'<!--(.*?)-->')


def read_lines(path):
    """Lines without their EOL, plus the EOL to write back (CRLF files stay CRLF)."""
    text = open(path, encoding='utf-8', newline='').read()
    eol = '\r\n' if '\r\n' in text else '\n'
    return text.split(eol), eol


def write_lines(path, lines, eol):
    open(path, 'w', encoding='utf-8', newline='').write(eol.join(lines))


def norm(text):
    return re.sub(r'\s+', ' ', text).strip()


def thai_comments(path):
    """Yield (lineno, code, marker, comment_text) for each comment containing Thai."""
    k = kind_of(path)
    if not k:
        return
    try:
        lines, _ = read_lines(path)
    except (UnicodeDecodeError, IsADirectoryError, FileNotFoundError):
        return
    in_ps_block = False
    for n, line in enumerate(lines):
        if k == 'xml':
            for m in XML_COMMENT.finditer(line):
                if THAI.search(m.group(1)):
                    yield n, line[:m.start()], '<!--', m.group(1)
            continue
        if path.endswith('.ps1'):
            s = line.strip().lstrip('\ufeff')
            if s.startswith('<#'):
                in_ps_block = True
            if in_ps_block:
                if THAI.search(line):
                    yield n, '', 'ps-block', line
                if '#>' in s:
                    in_ps_block = False
                continue
        code, marker, comment = split_hash(line, path)
        if marker and THAI.search(comment):
            yield n, code, marker, comment


def files_under(paths):
    out = []
    for p in paths:
        p = os.path.abspath(p)
        if os.path.isfile(p):
            out.append(p)
            continue
        for d, dirs, fs in os.walk(p):
            dirs[:] = [x for x in dirs if x not in ('.git', '__pycache__', 'node_modules', '.terraform')
                       and os.path.join(d, x) != os.path.join(ROOT, 'tools', 'i18n')]
            out += [os.path.join(d, f) for f in fs]
    return sorted(f for f in out if os.path.splitext(f)[1] not in SKIP_EXT and kind_of(f))


def load_map():
    if not os.path.exists(MAP_FILE):
        return {}
    return json.load(open(MAP_FILE, encoding='utf-8'))


EN_SUFFIX = re.compile(r' \(EN: [^()]*(?:\([^()]*\)[^()]*)*\)$')


def is_en_line(line):
    s = line.strip()
    return bool(re.match(r'^(#+|//) EN: ', s) or re.match(r'^<!-- EN: .* -->$', s) or re.match(r'^EN: ', s))


def apply_file(path, tr, mode):
    lines, eol = read_lines(path)
    hits = {n: (code, marker, comment) for n, code, marker, comment in thai_comments(path)}
    out, missing, changed = [], [], False
    for n, line in enumerate(lines):
        if mode == 'strip':
            if is_en_line(line) and n + 1 < len(lines) and THAI.search(lines[n + 1]):
                changed = True
                continue
            if EN_SUFFIX.search(line):
                line = EN_SUFFIX.sub('', line)
                changed = True
            out.append(line)
            continue
        if n not in hits:
            out.append(line)
            continue
        code, marker, comment = hits[n]
        key = norm(EN_SUFFIX.sub('', comment) if marker != '<!--' else comment)
        en = tr.get(key)
        if not en:
            missing.append((n + 1, key))
            out.append(line)
            continue
        indent = re.match(r'\s*', line.lstrip('\ufeff')).group(0)
        # "@inline <text>": keep the English on the same comment line. Used for marker lines that
        # scripts search for (SOCLAB-BEGIN ...) and commented usage examples ("cmd   # thai").
        if en.startswith('@inline ') and marker != '<!--':
            if not EN_SUFFIX.search(line):
                out.append(f'{line.rstrip()} (EN: {en[8:]})')
                changed = True
            else:
                out.append(line)
            continue
        if marker == 'ps-block':
            en_line = f'{indent}EN: {en}'
            if not (out and out[-1].strip() == en_line.strip()):
                out.append(en_line)
                changed = True
            out.append(line)
        elif code.strip() == '' and marker == '<!--':
            en_line = f'{indent}<!-- EN: {en} -->'
            if not (out and out[-1].strip() == en_line.strip()):
                out.append(en_line)
                changed = True
            out.append(line)
        elif marker == '<!--':
            # comment after an XML element on the same line: insert a line above
            en_line = f'{indent}<!-- EN: {en} -->'
            if not (out and out[-1].strip() == en_line.strip()):
                out.append(en_line)
                changed = True
            out.append(line)
        elif code.strip() == '':
            en_line = f'{indent}{marker} EN: {en}'
            if not (out and out[-1].strip() == en_line.strip()):
                out.append(en_line)
                changed = True
            out.append(line)
        else:
            if not trailing_ok(path):
                missing.append((n + 1, 'TRAILING COMMENT NOT SAFE TO EDIT: ' + key))
                out.append(line)
                continue
            if EN_SUFFIX.search(line):
                out.append(line)
            else:
                out.append(f'{line.rstrip()} (EN: {en})')
                changed = True
    if mode in ('apply', 'strip') and changed:
        write_lines(path, out, eol)
    return missing, changed


def has_en(path, n, lines, code, marker):
    if EN_SUFFIX.search(lines[n]):
        return True
    if code.strip() == '' or marker in ('<!--', 'ps-block'):
        return n > 0 and is_en_line(lines[n - 1])
    return bool(EN_SUFFIX.search(lines[n]))


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'scan'
    paths = sys.argv[2:] or [ROOT]
    tr = load_map()
    files = files_under(paths)
    if cmd == 'scan':
        seen = {}
        for f in files:
            for n, code, marker, comment in thai_comments(f):
                key = norm(EN_SUFFIX.sub('', comment))
                if key not in tr:
                    seen.setdefault(key, f'{os.path.relpath(f, ROOT)}:{n + 1}')
        json.dump(seen, sys.stdout, ensure_ascii=False, indent=1)
        print(f'\n{len(seen)} untranslated comment(s)', file=sys.stderr)
    elif cmd in ('apply', 'strip'):
        nchg, miss = 0, []
        for f in files:
            m, c = apply_file(f, tr, cmd)
            nchg += c
            miss += [(os.path.relpath(f, ROOT), ln, k) for ln, k in m]
        print(f'{cmd}: {nchg} file(s) changed, {len(miss)} comment(s) without translation')
        for f, ln, k in miss[:20]:
            print(f'  MISSING {f}:{ln}: {k[:70]}')
        sys.exit(1 if miss else 0)
    elif cmd == 'check':
        bad = 0
        for f in files:
            lines, _ = read_lines(f)
            for n, code, marker, comment in thai_comments(f):
                if not has_en(f, n, lines, code, marker):
                    bad += 1
                    print(f'NO EN: {os.path.relpath(f, ROOT)}:{n + 1}: {comment.strip()[:60]}')
        print(f'{len(files)} files checked, {bad} Thai comment(s) without English')
        sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
