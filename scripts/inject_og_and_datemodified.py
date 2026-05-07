"""
Inject two fixes across the toolzspan.site codebase:

FIX A — og:image + twitter:image
  Insert meta tags on every HTML page that currently lacks og:image.
  Standard pages: insert immediately after <meta property="og:url">
    (fallback: after og:type, then after og:title).
  Special case: 404.html has only og:title/twitter:title. Insert a
    full standard OG/Twitter block right after <title>.

FIX B — Article schema dateModified
  For every blog/post-NN.html whose Article JSON-LD has datePublished
  but no dateModified, add "dateModified":"<same-as-datePublished>".

Idempotent: skips files that already contain og:image / dateModified.
Writes a per-file log to scripts/og_datemod_inject.log.
"""

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'og_datemod_inject.log')

OG_IMAGE_TAG = (
    '  <meta property="og:image" content="https://toolzspan.site/og-image.png">'
)
TW_IMAGE_TAG = (
    '  <meta property="twitter:image" content="https://toolzspan.site/og-image.png">'
)

# Block for 404.html (which only has og:title + twitter:title)
FOUR_OH_FOUR_BLOCK = '''  <meta property="og:description" content="Page not found on Toolzspan. Explore 50 free online tools for PDF, video, audio, and image conversion and editing. No sign-up required. Fast and secure.">
  <meta property="og:url" content="https://toolzspan.site/404.html">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="Toolzspan">
  <meta property="og:image" content="https://toolzspan.site/og-image.png">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:description" content="Page not found on Toolzspan. Explore 50 free online tools for PDF, video, audio, and image conversion and editing. No sign-up required. Fast and secure.">
  <meta property="twitter:image" content="https://toolzspan.site/og-image.png">'''

log_lines = []


def log(msg):
    log_lines.append(msg)
    print(msg)


def iter_html_files():
    for dirpath, _, filenames in os.walk(ROOT):
        # Skip node_modules, .git, scripts
        if any(part in dirpath.replace('\\', '/').split('/')
               for part in ('node_modules', '.git', 'scripts')):
            continue
        for f in filenames:
            if f.lower().endswith('.html'):
                yield os.path.join(dirpath, f)


def inject_og_image(path, html):
    """Return (new_html, action). action in {'INSERTED','SKIPPED','FAIL'}."""
    if 'og:image' in html:
        return html, 'SKIPPED (og:image already present)'

    rel = os.path.relpath(path, ROOT).replace('\\', '/')

    # Special case: 404.html needs the full block
    if rel == '404.html':
        # Insert after </title>
        m = re.search(r'(</title>\s*\n)', html)
        if not m:
            return html, 'FAIL (no </title>)'
        insertion = m.group(1) + FOUR_OH_FOUR_BLOCK + '\n'
        new_html = html[:m.start()] + insertion + html[m.end():]
        return new_html, 'INSERTED (full 404 block)'

    # Standard: find og:url (preferred), og:type, or og:title.
    # Use a single regex without trailing-newline requirement so condensed
    # one-line meta blocks also match. Insert with a leading newline so
    # the new tags land on their own lines regardless of source style.
    new_tags = '\n' + OG_IMAGE_TAG + '\n' + TW_IMAGE_TAG

    for label, anchor in (
        ('og:url',   r'<meta\s+property=["\']og:url["\'][^>]*>'),
        ('og:type',  r'<meta\s+property=["\']og:type["\'][^>]*>'),
        ('og:title', r'<meta\s+property=["\']og:title["\'][^>]*>'),
    ):
        m = re.search(anchor, html, re.IGNORECASE)
        if m:
            new_html = html[:m.end()] + new_tags + html[m.end():]
            return new_html, f'INSERTED (after {label})'

    return html, 'FAIL (no og:url/og:type/og:title anchor)'


def inject_date_modified(path, html):
    """Only applies to blog/post-NN.html files."""
    rel = os.path.relpath(path, ROOT).replace('\\', '/')
    if not re.match(r'blog/post-\d{2}\.html$', rel):
        return html, 'NOT APPLICABLE'

    if 'dateModified' in html:
        return html, 'SKIPPED (dateModified already present)'

    # Find the Article JSON-LD block and its datePublished
    # Pattern matches: "datePublished":"2026-04-17"
    m = re.search(r'"datePublished"\s*:\s*"(\d{4}-\d{2}-\d{2})"', html)
    if not m:
        return html, 'FAIL (no datePublished found)'

    date_val = m.group(1)
    # Insert "dateModified":"<date>" immediately after datePublished pair
    insertion = f',"dateModified":"{date_val}"'
    # m.end() is right after the closing quote of the date value
    new_html = html[:m.end()] + insertion + html[m.end():]
    return new_html, f'INSERTED (dateModified={date_val})'


def main():
    total = 0
    og_inserted = og_skipped = og_failed = 0
    dm_inserted = dm_skipped = dm_failed = dm_na = 0

    log('=' * 78)
    log('Toolzspan injection pass — og:image + twitter:image + dateModified')
    log('=' * 78)

    for path in iter_html_files():
        total += 1
        rel = os.path.relpath(path, ROOT).replace('\\', '/')
        with open(path, 'r', encoding='utf-8') as fh:
            html = fh.read()
        original = html

        # Fix A: og:image
        html, og_action = inject_og_image(path, html)
        if og_action.startswith('INSERTED'):
            og_inserted += 1
        elif og_action.startswith('SKIPPED'):
            og_skipped += 1
        else:
            og_failed += 1

        # Fix B: dateModified
        html, dm_action = inject_date_modified(path, html)
        if dm_action.startswith('INSERTED'):
            dm_inserted += 1
        elif dm_action.startswith('SKIPPED'):
            dm_skipped += 1
        elif dm_action.startswith('NOT APPLICABLE'):
            dm_na += 1
        else:
            dm_failed += 1

        if html != original:
            with open(path, 'w', encoding='utf-8', newline='\n') as fh:
                fh.write(html)

        log(f'{rel:70s}  OG={og_action:45s}  DM={dm_action}')

    log('-' * 78)
    log(f'Total HTML files scanned : {total}')
    log(f'OG image INSERTED        : {og_inserted}')
    log(f'OG image SKIPPED         : {og_skipped}')
    log(f'OG image FAILED          : {og_failed}')
    log(f'dateModified INSERTED    : {dm_inserted}')
    log(f'dateModified SKIPPED     : {dm_skipped}')
    log(f'dateModified N/A         : {dm_na}')
    log(f'dateModified FAILED      : {dm_failed}')

    with open(LOG_PATH, 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(log_lines))
    log(f'\nLog written to {LOG_PATH}')


if __name__ == '__main__':
    main()
