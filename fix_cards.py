import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # We want to find Card( ... ) and remove elevation, margin, shape.
    # To be extremely safe, we only remove:
    # 1. elevation: 0,
    # 2. margin: const EdgeInsets... or margin: EdgeInsets.zero,
    # 3. shape: RoundedRectangleBorder(...)
    # We can do this with regex substitutions.

    # 1. Remove elevation: 0,
    content = re.sub(r'^\s*elevation:\s*0,\n', '', content, flags=re.MULTILINE)
    
    # 2. Remove margin: const EdgeInsets.only(bottom: 10), etc
    content = re.sub(r'^\s*margin:\s*(?:const\s+)?EdgeInsets\.[a-zA-Z0-9_\(\)\s:]+,\n', '', content, flags=re.MULTILINE)
    
    # 3. Remove shape: RoundedRectangleBorder(...)
    # This spans multiple lines. Let's match from "shape: RoundedRectangleBorder(" to its closing "),"
    # It usually looks like:
    # shape: RoundedRectangleBorder(
    #   borderRadius: BorderRadius.circular(14),
    #   side: BorderSide(color: colorScheme.outlineVariant, width: 1),
    # ),
    shape_pattern = r'^\s*shape:\s*RoundedRectangleBorder\([^)]*\),\n'
    # Actually, the content inside RoundedRectangleBorder has nested parentheses, so [^)]* fails.
    # We can just match non-greedy until "),\n"
    content = re.sub(r'^\s*shape:\s*RoundedRectangleBorder\(.*?\),\n', '', content, flags=re.MULTILINE | re.DOTALL)

    with open(filepath, 'w') as f:
        f.write(content)

for root, dirs, files in os.walk('lib/features'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

