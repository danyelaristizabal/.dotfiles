import sys
import json
from datetime import datetime

if len(sys.argv) > 1:
    data = sys.argv[1].strip().strip('"')
else:
    data = sys.stdin.read().strip().strip('"')

try:
    dt = datetime.strptime(data.strip(), '%Y-%m-%d %H:%M:%S')
    timestamp = int(dt.timestamp())
    print(json.dumps(timestamp, indent=2))
except Exception as e:
    print(json.dumps(f"Invalid date string: {data}", indent=2))
