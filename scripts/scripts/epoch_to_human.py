import sys
import json
from datetime import datetime

if len(sys.argv) > 1:
    data = sys.argv[1]
else:
    data = sys.stdin.read().strip()

try:
    timestamp = float(data)
    human_readable = datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S %Z')
    print(json.dumps(human_readable, indent=2))
except Exception as e:
    print(json.dumps(f"Invalid timestamp: {data}", indent=2))
