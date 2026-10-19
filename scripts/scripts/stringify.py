import sys
import json

if len(sys.argv) > 1:
    data = sys.argv[1]
else:
    data = sys.stdin.read().strip()

print(json.dumps(data, indent=2) if isinstance(data := json.loads(data), str) else '"' + json.dumps(data, indent=2).replace('"', '\\"').replace('\n', '\\n') + '"')
