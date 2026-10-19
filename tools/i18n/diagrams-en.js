#!/usr/bin/env node
// Builds the English diagram set from the Thai one:
//   assets/diagrams/<dir>/<name>.svg  ->  assets/diagrams/<dir>/en/<name>.svg + .png
//
// 1. Every Thai <text>/<title> is replaced from tools/i18n/diagrams.en.json. Any Thai left over is an
//    error, so a new Thai label cannot slip through untranslated.
// 2. In Chromium (playwright), each translated label is measured. If it no longer fits its box (or the
//    canvas) and is wider than the original Thai label was, its font-size is reduced until it fits.
// 3. The SVG is saved and rendered to PNG at 2x, the same way the Thai set is rendered for the book.
//
// usage:  node tools/i18n/diagrams-en.js            (needs playwright, e.g. NODE_PATH=<dir>/node_modules)
//         node tools/i18n/diagrams-en.js --check    (text replacement only; exit 1 if anything is missing)
// env:    FONT_DIR = directory with sarabun-{thai,latin}-{400,600,700}-normal.woff2 and
//                    jetbrains-mono-latin-400-normal.woff2 (optional; system fonts are used otherwise)
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');
const DIAG = path.join(ROOT, 'assets', 'diagrams');
const MAP = JSON.parse(fs.readFileSync(path.join(__dirname, 'diagrams.en.json'), 'utf8'));
const THAI = /[฀-๿]/;
const CHECK_ONLY = process.argv.includes('--check');

const unesc = (s) => s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&amp;/g, '&');
const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

function sources() {
  const out = [];
  for (const d of fs.readdirSync(DIAG, { withFileTypes: true })) {
    if (!d.isDirectory()) continue;
    for (const f of fs.readdirSync(path.join(DIAG, d.name))) if (f.endsWith('.svg')) out.push(path.join(DIAG, d.name, f));
  }
  return out.sort();
}

// translate one run of character data, keeping its leading/trailing spaces
function run(raw, missing, file) {
  const t = unesc(raw);
  if (!THAI.test(t)) return { s: raw, hit: false };
  const lead = t.match(/^\s*/)[0], trail = t.match(/\s*$/)[0], key = t.trim();
  const en = MAP[key];
  if (!en) { missing.push(`${path.relative(ROOT, file)}: ${key}`); return { s: raw, hit: false }; }
  return { s: esc(lead + en + trail), hit: true };
}

function translate(svg, missing, file) {
  // <text> may contain <tspan> children: translate every run of text between tags
  return svg.replace(/<(text|title)\b([^>]*)>([\s\S]*?)<\/\1>/g, (m, tag, attrs, body) => {
    let hit = false;
    const inner = body.split(/(<[^>]+>)/).map((part) => {
      if (part.startsWith('<')) return part;
      const r = run(part, missing, file);
      hit = hit || r.hit;
      return r.s;
    }).join('');
    if (!hit) return m;
    const mark = tag === 'text' ? ' data-en="1"' : '';
    return `<${tag}${attrs}${mark}>${inner}</${tag}>`;
  });
}

function fontCss() {
  const dir = process.env.FONT_DIR;
  if (!dir || !fs.existsSync(dir)) return '';
  return [400, 600, 700].flatMap((w) => [
    `@font-face{font-family:'Sarabun';font-weight:${w};src:url('file://${dir}/sarabun-thai-${w}-normal.woff2');unicode-range:U+0E01-0E5B,U+200C-200D,U+25CC}`,
    `@font-face{font-family:'Sarabun';font-weight:${w};src:url('file://${dir}/sarabun-latin-${w}-normal.woff2');unicode-range:U+0000-00FF,U+2000-206F,U+2190-21FF,U+2212,U+2264-2265,U+25A0-25FF}`,
  ]).join('') + `@font-face{font-family:'JetBrains Mono';src:url('file://${dir}/jetbrains-mono-latin-400-normal.woff2')}`;
}

// runs in the page: widths of every <text>, in document order
const MEASURE = () => [...document.querySelectorAll('svg text')].map((t) => t.getBBox().width);

// runs in the page: shrink translated labels that overflow; returns a report
const FIT = (thaiWidths) => {
  const svg = document.querySelector('svg');
  const W = svg.viewBox.baseVal && svg.viewBox.baseVal.width ? svg.viewBox.baseVal.width : +svg.getAttribute('width');
  const rects = [...svg.querySelectorAll('rect')].map((r) => r.getBBox()).filter((b) => !(b.x <= 0 && b.y <= 0 && b.width >= W - 1));
  const report = { shrunk: [], tight: [] };
  [...svg.querySelectorAll('text')].forEach((t, i) => {
    if (t.getAttribute('data-en') !== '1') return;
    const x = +t.getAttribute('x'), y = +t.getAttribute('y');
    const anchor = t.getAttribute('text-anchor') || 'start';
    let box = null;
    for (const r of rects) {
      if (x >= r.x - 1 && x <= r.x + r.width + 1 && y - 4 >= r.y && y - 4 <= r.y + r.height && (!box || r.width * r.height < box.width * box.height)) box = r;
    }
    const left = box ? box.x + 8 : 8, right = box ? box.x + box.width - 8 : W - 8;
    const avail = anchor === 'middle' ? 2 * Math.min(x - left, right - x) : anchor === 'end' ? x - left : right - x;
    const limit = Math.max(avail, (thaiWidths[i] || 0) + 1);
    let w = t.getBBox().width;
    if (w <= limit) return;
    const fs0 = parseFloat(t.getAttribute('font-size') || getComputedStyle(t).fontSize);
    let fs1 = Math.max(Math.floor((fs0 * limit / w) * 10) / 10, +(fs0 * 0.6).toFixed(1));
    t.setAttribute('font-size', fs1);
    w = t.getBBox().width;
    (w <= limit + 0.5 ? report.shrunk : report.tight).push(`${t.textContent.slice(0, 50)} (${fs0}→${fs1})`);
  });
  svg.querySelectorAll('[data-en]').forEach((e) => e.removeAttribute('data-en'));
  return { report, svg: new XMLSerializer().serializeToString(svg) };
};

(async () => {
  const missing = [];
  const jobs = sources().map((f) => {
    const thai = fs.readFileSync(f, 'utf8');
    let en = translate(thai, missing, f);
    // some generators set the font in page CSS only; put it on the SVG so the file renders on its own
    if (!/^<svg\b[^>]*font-family=/.test(en)) en = en.replace(/^<svg\b/, `<svg font-family="Sarabun, 'Leelawadee UI', Tahoma, sans-serif"`);
    return { f, thai, en };
  });
  const left = jobs.filter((j) => THAI.test(j.en.replace(/<!--[\s\S]*?-->/g, ''))).map((j) => path.relative(ROOT, j.f));
  if (missing.length || left.length) {
    console.error(`untranslated diagram text (${missing.length}):\n  ` + missing.slice(0, 40).join('\n  '));
    if (left.length) console.error('Thai still present in: ' + left.join(', '));
    process.exit(1);
  }
  console.log(`${jobs.length} diagrams: every Thai label has a translation`);
  if (CHECK_ONLY) return;

  const { chromium } = require('playwright');
  const browser = await chromium.launch();
  const page = await browser.newPage({ deviceScaleFactor: 2 });
  const css = fontCss();
  const load = async (svg) => {
    await page.setContent(`<html><head><style>${css} html,body{margin:0} *{font-variant-ligatures:none}</style></head><body>${svg}</body></html>`);
    await page.evaluate(() => document.fonts.ready);
  };
  let shrunk = 0, tight = [];
  for (const j of jobs) {
    await load(j.thai);
    const thaiWidths = await page.evaluate(MEASURE);
    await load(j.en);
    const { report, svg } = await page.evaluate(FIT, thaiWidths);
    const outDir = path.join(path.dirname(j.f), 'en');
    fs.mkdirSync(outDir, { recursive: true });
    const out = path.join(outDir, path.basename(j.f));
    fs.writeFileSync(out, svg + '\n');
    await load(svg);
    await page.locator('svg').screenshot({ path: out.replace(/\.svg$/, '.png') });
    shrunk += report.shrunk.length;
    tight.push(...report.tight.map((t) => `${path.relative(ROOT, out)}: ${t}`));
  }
  await browser.close();
  console.log(`rendered ${jobs.length} English diagrams; ${shrunk} label(s) shrunk to fit`);
  if (tight.length) console.log(`still tight at the minimum size (${tight.length}):\n  ` + tight.join('\n  '));
})().catch((e) => { console.error(e); process.exit(1); });
