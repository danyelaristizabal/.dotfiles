import uuid
import sys

def derive_uuid_from_string(data: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_OID, data))

if len(sys.argv) > 1:
    data = sys.argv[1]
else:
    data = sys.stdin.read().strip()

print(derive_uuid_from_string(data))
