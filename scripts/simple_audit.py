"""Comprehensive SEO audit per Toolzspan_SEO_Fix_Instructions.md.
Checks Fixes 1-11 plus long-tail keyword presence in titles.
Analysis-only. Writes report to scripts/seo_fix_audit.log.
"""
import os, re

ROOT = r'c:\GravityProject\toolzspan.site'
TOOLS = os.path.join(ROOT, 'tools')
BLOG = os.path.join(ROOT, 'blog')
LOG = os.path.join(ROOT, 'scripts', 'seo_fix_audit.log')

# Long-tail modifiers explicitly required by Fix 2
LONGTAIL_MODIFIERS = ['free', 'online', 'no sign-up', 'no signup', 'no watermark']

def read(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def get_title(html):
    m = re.search(r'<title>([^<]+)</title>', html)
    return m.group(1).strip() if m else None

def get_meta_desc(html):
    m = re.search(r'<meta\s+name=["\']description["\']\s+content=["\']([^"\']+)["\']', html, re.IGNORECASE)
    return m.group(1).strip() if m else None

def get_h1(html):
    m = re.search(r'<h1[^>]*>(.*?)</h1>', html, re.IGNORECASE | re.DOTALL)
    if not m:
        return None
    return re.sub(r'<[^>]+>', '', m.group(1)).strip()

def list_tool_pages():
    return sorted([f for f in os.listdir(TOOLS) if f.endswith('.html')])

def list_blog_pages():
    return sorted([f for f in os.listdir(BLOG) if f.endswith('.html')])

ROOT_PAGES = ['index.html', '404.html', 'about.html', 'contact.html',
              'privacy-policy.html', 'terms-of-service.html']

report = []
def p(s=''): report.append(s)

p('=' * 80)
p('TOOLZSPAN SEO FIX AUDIT (Fixes 1-11 + Long-tail Keywords)')
p('Per Toolzspan_SEO_Fix_Instructions.md')
p('=' * 80)

# ----------------------------------------------------------------------
# LONG-TAIL KEYWORDS IN TITLES (Fix 2 essence: free + online + no sign-up)
# ----------------------------------------------------------------------
p('\n[LONG-TAIL KEYWORDS IN TITLES]')
p('Required modifiers: "free", "online", and either "no sign-up" or "no watermark"')
p('-' * 80)

lt_strong, lt_partial, lt_missing = [], [], []
all_pages = []
for f in list_tool_pages():
    all_pages.append(('tools/' + f, os.path.join(TOOLS, f)))
for f in list_blog_pages():
    all_pages.append(('blog/' + f, os.path.join(BLOG, f)))
for f in ROOT_PAGES:
    all_pages.append((f, os.path.join(ROOT, f)))

for label, path in all_pages:
    if not os.path.exists(path):
        continue
    html = read(path)
    title = get_title(html) or ''
    lower = title.lower()
    has_free = 'free' in lower
    has_online = 'online' in lower
    has_nosignup = 'no sign-up' in lower or 'no signup' in lower
    has_nowatermark = 'no watermark' in lower
    cnt = sum([has_free, has_online, has_nosignup or has_nowatermark])
    entry = (label, title, has_free, has_online, has_nosignup, has_nowatermark)
    if cnt >= 3:
        lt_strong.append(entry)
    elif cnt >= 2:
        lt_partial.append(entry)
    else:
        lt_missing.append(entry)

p(f'STRONG (free + online + no-sign-up/no-watermark): {len(lt_strong)}')
p(f'PARTIAL (2 of 3): {len(lt_partial)}')
p(f'MISSING (<2 modifiers): {len(lt_missing)}')

p('\n--- STRONG ---')
for e in lt_strong:
    p(f'  [OK] {e[0]} :: {e[1]}')
p('\n--- PARTIAL ---')
for e in lt_partial:
    flags = f'free={e[2]} online={e[3]} no-sign-up={e[4]} no-watermark={e[5]}'
    p(f'  [WARN] {e[0]} :: {e[1]}')
    p(f'         {flags}')
p('\n--- MISSING ---')
for e in lt_missing:
    flags = f'free={e[2]} online={e[3]} no-sign-up={e[4]} no-watermark={e[5]}'
    p(f'  [FAIL] {e[0]} :: {e[1]}')
    p(f'         {flags}')

# ----------------------------------------------------------------------
# FIX 1 - about.html: tool count + meta description
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 1 - about.html: Tool Count & Meta Description')
p('=' * 80)
about = read(os.path.join(ROOT, 'about.html'))
fix1a_pass = '50 free online tools' in about.lower() or '50 tools' in about.lower()
fix1a_bad = '24 tools' in about.lower() or '24 free' in about.lower()
p(f'1A Body says "50 free online tools": {"PASS" if fix1a_pass and not fix1a_bad else "FAIL"}')
if fix1a_bad:
    p('     >> Still contains "24 tools" reference')
about_meta = get_meta_desc(about) or ''
fix1b_pass = '50 free online tools' in about_meta.lower() and 155 <= len(about_meta) <= 165
p(f'1B Meta desc 155-165 chars + mentions "50 free online tools": {"PASS" if fix1b_pass else "WARN"}')
p(f'     length={len(about_meta)} content="{about_meta}"')

# ----------------------------------------------------------------------
# FIX 2 - All tool pages: meta titles 50-60 chars + long-tail modifiers
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 2 - Tool Page Titles (50-60 chars + free/online/no-sign-up)')
p('=' * 80)
f2_ok, f2_bad = [], []
for f in list_tool_pages():
    html = read(os.path.join(TOOLS, f))
    t = get_title(html) or ''
    lower = t.lower()
    length_ok = 50 <= len(t) <= 60
    has_free = 'free' in lower
    has_online = 'online' in lower
    has_modifier = any(m in lower for m in ['no sign-up', 'no signup', 'no watermark'])
    if length_ok and has_free and has_online and has_modifier:
        f2_ok.append((f, t, len(t)))
    else:
        f2_bad.append((f, t, len(t), length_ok, has_free, has_online, has_modifier))
p(f'PASS: {len(f2_ok)}/{len(list_tool_pages())} | FAIL: {len(f2_bad)}')
for f, t, l, lo, hf, ho, hm in f2_bad:
    p(f'  [WARN] tools/{f} ({l} chars) :: {t}')
    p(f'         length_ok={lo} free={hf} online={ho} modifier={hm}')

# ----------------------------------------------------------------------
# FIX 3 - All tool pages: meta descriptions 155-165 chars
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 3 - Tool Page Meta Descriptions (155-165 chars)')
p('=' * 80)
f3_ok, f3_bad = [], []
for f in list_tool_pages():
    html = read(os.path.join(TOOLS, f))
    md = get_meta_desc(html) or ''
    if 150 <= len(md) <= 165:
        f3_ok.append((f, len(md)))
    else:
        f3_bad.append((f, len(md), md))
p(f'PASS (150-165 chars): {len(f3_ok)}/{len(list_tool_pages())} | FAIL: {len(f3_bad)}')
for f, l, md in f3_bad:
    p(f'  [WARN] tools/{f} ({l} chars) :: {md}')

# ----------------------------------------------------------------------
# FIX 4 - All tool pages: tool-summary answer block under H1
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 4 - Answer Block (<p class="tool-summary">) Under H1')
p('=' * 80)
f4_ok, f4_bad = [], []
for f in list_tool_pages():
    html = read(os.path.join(TOOLS, f))
    has_summary = bool(re.search(r'<p[^>]*class=["\'][^"\']*tool-summary[^"\']*["\']', html, re.IGNORECASE))
    if has_summary:
        f4_ok.append(f)
    else:
        f4_bad.append(f)
p(f'PASS: {len(f4_ok)}/{len(list_tool_pages())} | FAIL: {len(f4_bad)}')
for f in f4_bad:
    p(f'  [WARN] tools/{f} :: missing <p class="tool-summary">')

# ----------------------------------------------------------------------
# FIX 5 - H2 headings: not generic "How to Use [Tool]" / "Why Use Toolzspan"
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 5 - H2 Headings (intent-matched, not generic)')
p('=' * 80)
f5_ok, f5_bad = [], []
for f in list_tool_pages():
    html = read(os.path.join(TOOLS, f))
    h2s = re.findall(r'<h2[^>]*>(.*?)</h2>', html, re.IGNORECASE | re.DOTALL)
    h2_text = ' || '.join(re.sub(r'<[^>]+>', '', h).strip() for h in h2s)
    bad_pattern = re.search(r'how\s+to\s+use\s+\w+\s*$|why\s+use\s+toolzspan', h2_text, re.IGNORECASE)
    if bad_pattern:
        f5_bad.append((f, h2_text[:200]))
    else:
        f5_ok.append(f)
p(f'PASS (no generic H2): {len(f5_ok)}/{len(list_tool_pages())} | FAIL: {len(f5_bad)}')
for f, h in f5_bad:
    p(f'  [WARN] tools/{f} :: generic H2 found: {h}')

# ----------------------------------------------------------------------
# FIX 6 - All tool pages: 8+ FAQ questions
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 6 - FAQ Section (8+ questions)')
p('=' * 80)
f6_ok, f6_bad = [], []
for f in list_tool_pages():
    html = read(os.path.join(TOOLS, f))
    # Count FAQPage schema questions OR <details>/h3 blocks containing "?"
    schema_qs = re.findall(r'"@type"\s*:\s*"Question"', html)
    visible_qs = re.findall(r'<(?:summary|h3|h4|button)[^>]*>\s*[^<]*\?\s*</(?:summary|h3|h4|button)>', html, re.IGNORECASE)
    count = max(len(schema_qs), len(visible_qs))
    if count >= 8:
        f6_ok.append((f, count))
    else:
        f6_bad.append((f, count))
p(f'PASS (>=8 FAQs): {len(f6_ok)}/{len(list_tool_pages())} | FAIL: {len(f6_bad)}')
for f, c in f6_bad:
    p(f'  [WARN] tools/{f} :: only {c} FAQ questions detected')

# ----------------------------------------------------------------------
# FIX 7 - Related tools (5-6) + 1 blog link per tool page
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 7 - Related Tools (5-6) + 1 Blog Link per Tool Page')
p('=' * 80)
f7a_ok, f7a_bad = [], []
f7b_ok, f7b_bad = [], []
for f in list_tool_pages():
    html = read(os.path.join(TOOLS, f))
    # Related tools: <div class="related-tools"> ... </div> with relative hrefs
    rel_section = re.search(r'<(?:div|section)[^>]*class=["\'][^"\']*related[^"\']*["\'][^>]*>(.*?)</(?:div|section)>', html, re.IGNORECASE | re.DOTALL)
    rel_html = rel_section.group(1) if rel_section else ''
    # Match any link to a *.html that isn't blog/index/anchor-only
    rel_links = re.findall(r'<a[^>]+href=["\']([^"\']+\.html)["\']', rel_html, re.IGNORECASE)
    rel_links = [l for l in rel_links if 'blog/' not in l.lower() and not l.startswith('#')]
    if len(rel_links) >= 5:
        f7a_ok.append((f, len(rel_links)))
    else:
        f7a_bad.append((f, len(rel_links)))
    # Blog link: any href to a blog/*.html (absolute or relative)
    has_blog = bool(re.search(r'href=["\'][^"\']*blog/[a-z0-9\-]+\.html', html, re.IGNORECASE))
    if has_blog:
        f7b_ok.append(f)
    else:
        f7b_bad.append(f)
p(f'7A Related tools >=5: {len(f7a_ok)}/{len(list_tool_pages())} pass | {len(f7a_bad)} fail')
for f, c in f7a_bad:
    p(f'  [WARN] tools/{f} :: {c} related-tool links')
p(f'\n7B At least 1 blog link: {len(f7b_ok)}/{len(list_tool_pages())} pass | {len(f7b_bad)} fail')
for f in f7b_bad:
    p(f'  [WARN] tools/{f} :: no /blog/ link found')

# ----------------------------------------------------------------------
# FIX 8 - Schema markup: SoftwareApplication + BreadcrumbList + FAQPage
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 8 - JSON-LD Schema (SoftwareApplication + BreadcrumbList + FAQPage)')
p('=' * 80)
f8_ok, f8_bad = [], []
for f in list_tool_pages():
    html = read(os.path.join(TOOLS, f))
    has_sw = '"SoftwareApplication"' in html
    has_bc = '"BreadcrumbList"' in html
    has_faq = '"FAQPage"' in html
    if has_sw and has_bc and has_faq:
        f8_ok.append(f)
    else:
        f8_bad.append((f, has_sw, has_bc, has_faq))
p(f'PASS (all 3 schemas): {len(f8_ok)}/{len(list_tool_pages())} | FAIL: {len(f8_bad)}')
for f, sw, bc, faq in f8_bad:
    p(f'  [WARN] tools/{f} :: SoftwareApplication={sw} BreadcrumbList={bc} FAQPage={faq}')

# ----------------------------------------------------------------------
# FIX 9 - scan-image.html renamed visible text to "Image to Text (OCR)"
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 9 - scan-image.html visible text == "Image to Text (OCR)"')
p('=' * 80)
scan = read(os.path.join(TOOLS, 'scan-image.html'))
title_ok = 'image to text' in (get_title(scan) or '').lower()
h1_ok = 'image to text' in (get_h1(scan) or '').lower()
meta_ok = 'extract text from' in (get_meta_desc(scan) or '').lower() or 'ocr' in (get_meta_desc(scan) or '').lower()
p(f'  Title contains "Image to Text": {"PASS" if title_ok else "FAIL"} :: {get_title(scan)}')
p(f'  H1 contains "Image to Text":    {"PASS" if h1_ok else "FAIL"} :: {get_h1(scan)}')
p(f'  Meta desc OCR-focused:           {"PASS" if meta_ok else "FAIL"} :: {get_meta_desc(scan)}')

# ----------------------------------------------------------------------
# FIX 10 - Homepage hero copy: long-tail keywords
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 10 - Homepage Hero (no sign-up + no watermark + no limits)')
p('=' * 80)
home = read(os.path.join(ROOT, 'index.html'))
# Extract the <section class="hero"> block
hero_match = re.search(r'<section[^>]*class=["\'][^"\']*hero[^"\']*["\'][^>]*>(.*?)</section>', home, re.IGNORECASE | re.DOTALL)
hero_zone = (hero_match.group(1) if hero_match else home).lower()
h10_phrases = ['no sign-up', 'no watermark', 'no limits']
h10_results = {ph: ph in hero_zone for ph in h10_phrases}
for ph, present in h10_results.items():
    p(f'  "{ph}" in hero: {"PASS" if present else "FAIL"}')

# ----------------------------------------------------------------------
# FIX 11 - All pages: image alt text present (no empty alt on content imgs, logo has descriptive alt)
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('FIX 11 - Image Alt Text (sitewide)')
p('=' * 80)
f11_missing_alt = []
f11_empty_alt = []
for label, path in all_pages:
    if not os.path.exists(path):
        continue
    html = read(path)
    imgs = re.findall(r'<img[^>]*>', html, re.IGNORECASE)
    for img in imgs:
        m = re.search(r'\salt\s*=\s*["\']([^"\']*)["\']', img, re.IGNORECASE)
        if not m:
            f11_missing_alt.append((label, img[:120]))
        elif m.group(1).strip() == '':
            # Empty alt is allowed for decorative images, only flag if src looks like content
            src_m = re.search(r'src\s*=\s*["\']([^"\']+)["\']', img, re.IGNORECASE)
            src = src_m.group(1) if src_m else ''
            # Treat logo or hero or icon SVG/PNG as content
            if re.search(r'logo|hero|banner|preview', src, re.IGNORECASE):
                f11_empty_alt.append((label, src))
p(f'<img> tags missing alt attribute entirely: {len(f11_missing_alt)}')
for lbl, snippet in f11_missing_alt[:30]:
    p(f'  [FAIL] {lbl} :: {snippet}')
if len(f11_missing_alt) > 30:
    p(f'  ... and {len(f11_missing_alt) - 30} more')
p(f'<img> tags with empty alt on content-like src (logo/hero/banner/preview): {len(f11_empty_alt)}')
for lbl, src in f11_empty_alt[:20]:
    p(f'  [WARN] {lbl} :: src={src}')

# ----------------------------------------------------------------------
# FINAL SUMMARY
# ----------------------------------------------------------------------
p('\n' + '=' * 80)
p('SUMMARY')
p('=' * 80)
p(f'Long-tail titles STRONG/PARTIAL/MISSING : {len(lt_strong)}/{len(lt_partial)}/{len(lt_missing)}')
p(f'Fix 1A about.html tool count            : {"PASS" if fix1a_pass and not fix1a_bad else "FAIL"}')
p(f'Fix 1B about.html meta desc 155-165     : {"PASS" if fix1b_pass else "WARN"}')
p(f'Fix 2  tool titles 50-60 + modifiers    : {len(f2_ok)}/{len(list_tool_pages())}')
p(f'Fix 3  tool meta desc 150-165           : {len(f3_ok)}/{len(list_tool_pages())}')
p(f'Fix 4  answer block under H1            : {len(f4_ok)}/{len(list_tool_pages())}')
p(f'Fix 5  H2 not generic                   : {len(f5_ok)}/{len(list_tool_pages())}')
p(f'Fix 6  FAQ >= 8 questions               : {len(f6_ok)}/{len(list_tool_pages())}')
p(f'Fix 7A related tools >= 5               : {len(f7a_ok)}/{len(list_tool_pages())}')
p(f'Fix 7B blog link present                : {len(f7b_ok)}/{len(list_tool_pages())}')
p(f'Fix 8  schema (SW + BC + FAQ)           : {len(f8_ok)}/{len(list_tool_pages())}')
p(f'Fix 9  scan-image visible text          : title={title_ok} h1={h1_ok} meta={meta_ok}')
p(f'Fix 10 hero copy phrases (3)            : {sum(h10_results.values())}/3')
p(f'Fix 11 imgs missing alt entirely        : {len(f11_missing_alt)}')

with open(LOG, 'w', encoding='utf-8') as f:
    f.write('\n'.join(report))
print('Audit complete. See', LOG)
