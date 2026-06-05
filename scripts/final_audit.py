import os

# Known mangled sequences that indicate encoding issues
mangled_sequences = ["ðŸ", "â€”", "â€“", "ðŸŽ‰", "â—", "ðŸ”", "â–"]

root_dir = r"c:\GravityProject\toolzspan.site"
errors_found = []

for root, dirs, files in os.walk(root_dir):
    for name in files:
        if name.endswith(".html"):
            path = os.path.join(root, name)
            try:
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                for seq in mangled_sequences:
                    if seq in content:
                        errors_found.append(f"{name}: Found '{seq}'")
                        break
            except Exception as e:
                errors_found.append(f"{name}: Error reading file: {e}")

if not errors_found:
    print("ENCODING AUDIT: CLEAN. No mangled sequences found.")
else:
    print("ENCODING AUDIT: FAIL. Issues found:")
    for err in errors_found:
        print(err)

# Check for broken internal links
print("\nLINK AUDIT:")
has_post_links = False
for root, dirs, files in os.walk(root_dir):
    for name in files:
        if name.endswith(".html"):
            path = os.path.join(root, name)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            if "post-" in content and ".html" in content:
                # Some post-XX might be valid text, but "post-XX.html" is definitely a link
                import re
                if re.search(r'post-\d\d\.html', content):
                    print(f"{name}: Found unmigrated link 'post-XX.html'")
                    has_post_links = True

if not has_post_links:
    print("LINK AUDIT: CLEAN. All 'post-XX.html' links migrated.")
