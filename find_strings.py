import os
import re

def is_human_text(s):
    # Ignore empty strings, pure numbers, or strings without letters
    if not re.search(r'[a-zA-Z]', s):
        return False
    # Ignore camelCase or snake_case without spaces
    if not ' ' in s and (re.search(r'^[a-z]+[A-Z][a-zA-Z]*$', s) or re.search(r'^[a-z]+(_[a-z]+)+$', s)):
        return False
    # Ignore URL paths or simple keys
    if s.startswith('/') or s.startswith('http') or s.startswith('api.') or s.startswith('new-worker-'):
        return False
    # Ignore common code identifiers/symbols like 'plain_text', 'kv_namespace'
    if s in ['plain_text', 'kv_namespace', 'd1', 'production', 'preview', 'secret_text', 'environment', 'name']:
        return False
    # Require at least one space or a capital letter to be considered text
    if not (' ' in s or re.search(r'^[A-Z]', s)):
        return False
    return True

results = []
for root, _, files in os.walk('lib/features'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Find all single quoted and double quoted strings
            # We use a simple regex for dart strings
            strings = re.findall(r"'([^'\\]*(?:\\.[^'\\]*)*)'", content)
            strings += re.findall(r'"([^"\\]*(?:\\.[^"\\]*)*)"', content)
            
            human_strings = [s for s in strings if is_human_text(s)]
            if human_strings:
                results.append((filepath, human_strings))

with open('leftover_strings.txt', 'w') as f:
    for filepath, strings in results:
        f.write(f"--- {filepath} ---\n")
        for s in set(strings):
            f.write(f"  {s}\n")

