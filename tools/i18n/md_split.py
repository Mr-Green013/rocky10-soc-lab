#!/usr/bin/env python3
"""Split repo docs into English (X.md) + Thai (X.th.md).

Step 1 (run once): `md_split.py rename` — git mv every Thai X.md to X.th.md,
point relative .md links inside Thai files at the .th.md siblings, and put the
language switcher on the first line.

`md_split.py check` — verify every X.md has X.th.md (and vice versa), each file
starts with the right switcher, and every relative link resolves.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
LINK = re.compile(r'(\]\()([^)\s#]+)(#[^)]*)?(\))')


def tracked_md():
    out = subprocess.check_output(['git', 'ls-files', '*.md'], cwd=ROOT, text=True)
    return [p for p in out.split() if p]


def switch_en(name):
    return f'**English** · [ภาษาไทย]({name}.th.md)'


def switch_th(name):
    return f'[English]({name}.md) · **ภาษาไทย**'


def stem(path):
    """README.md -> README, README.th.md -> README."""
    b = os.path.basename(path)
    return b[:-6] if b.endswith('.th.md') else b[:-3]


def to_thai_link(src_th, target):
    """Rewrite a relative link in a Thai file so it lands on the Thai page."""
    if re.match(r'^[a-z]+:', target) or target.startswith('/'):
        return target
    base = os.path.dirname(os.path.join(ROOT, src_th))
    full = os.path.normpath(os.path.join(base, target))
    if target.endswith('/') or os.path.isdir(full):
        if os.path.exists(os.path.join(full, 'README.th.md')):
            return target.rstrip('/') + '/README.th.md'
        return target
    if target.endswith('.md') and not target.endswith('.th.md'):
        th = target[:-3] + '.th.md'
        if os.path.exists(os.path.normpath(os.path.join(base, th))):
            return th
    return target


def rename():
    files = [p for p in tracked_md() if not p.endswith('.th.md')]
    for p in files:
        subprocess.check_call(['git', 'mv', p, p[:-3] + '.th.md'], cwd=ROOT)
    for p in files:
        th = p[:-3] + '.th.md'
        fp = os.path.join(ROOT, th)
        s = open(fp, encoding='utf-8').read()
        s = LINK.sub(lambda m: m.group(1) + to_thai_link(th, m.group(2)) + (m.group(3) or '') + m.group(4), s)
        line = switch_th(stem(th))
        if not s.startswith(line):
            s = line + '\n\n' + s
        open(fp, 'w', encoding='utf-8').write(s)
    print(f'renamed {len(files)} files to .th.md')


def check():
    md = set(tracked_md()) | {os.path.relpath(os.path.join(d, f), ROOT)
                               for d, _, fs in os.walk(ROOT) if '.git' not in d
                               for f in fs if f.endswith('.md')}
    bad = 0
    for p in sorted(md):
        if p.endswith('.th.md'):
            pair, want = p[:-6] + '.md', switch_th(stem(p))
        else:
            pair, want = p[:-3] + '.th.md', switch_en(stem(p))
        if pair not in md:
            print(f'MISSING pair: {p} -> {pair}'); bad += 1
        first = open(os.path.join(ROOT, p), encoding='utf-8').readline().rstrip('\n')
        if first != want:
            print(f'BAD switcher: {p}: {first[:60]!r}'); bad += 1
        s = open(os.path.join(ROOT, p), encoding='utf-8').read()
        s = re.sub(r'```.*?```', '', s, flags=re.S)  # ignore links inside code blocks
        for m in LINK.finditer(s):
            t = m.group(2)
            if re.match(r'^[a-z]+:', t):
                continue
            full = os.path.normpath(os.path.join(ROOT, os.path.dirname(p), t))
            if not os.path.exists(full):
                print(f'BROKEN link: {p}: {t}'); bad += 1
            elif p.endswith('.th.md') and t.endswith('.md') and not t.endswith('.th.md') \
                    and os.path.normpath(os.path.join(os.path.dirname(p), t)) != pair:
                print(f'THAI page links to English: {p}: {t}'); bad += 1
            elif not p.endswith('.th.md') and t.endswith('.th.md') and stem(t) != stem(p):
                print(f'ENGLISH page links to Thai: {p}: {t}'); bad += 1
    print(f'{len(md)} markdown files checked, {bad} problem(s)')
    return bad


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'check'
    if cmd == 'rename':
        rename()
    else:
        sys.exit(1 if check() else 0)
