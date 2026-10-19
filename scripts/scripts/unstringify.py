import sys
import json

if len(sys.argv) > 1:
    data = sys.argv[1]
else:
    data = sys.stdin.read().strip()

print(json.loads(data))
