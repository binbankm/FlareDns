import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # We want to remove elevation, margin, shape from Card
    # But only if it's the exact ones we missed. Let's just use a more permissive regex.
    # We will search for "elevation: \d+," and replace it with ""
    # We will search for "margin: .*(?:EdgeInsets).*?," and replace it with ""
    # We will search for "shape: RoundedRectangleBorder\([^)]+\)," and replace it with ""
    
    # Wait, the previous regex failed because `RoundedRectangleBorder(...)` contains nested parenthesis like `BorderRadius.circular(12)`
    # To match nested parenthesis in Python regex is hard.
    # Let's match shape: RoundedRectangleBorder(.*?side: BorderSide\(.*?\),\n\s*),
    
    # Actually, let's just use a loop to remove specific matched strings.
    # First let's find all occurrences in the files and see what they are exactly.
    pass

import sys

for root, dirs, files in os.walk('lib/features'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            # Find the string "Card(" and the next 15 lines
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if 'elevation:' in line:
                    print(f"File: {filepath}")
                    print('\n'.join(lines[i-1:i+6]))
                    print("-" * 40)
