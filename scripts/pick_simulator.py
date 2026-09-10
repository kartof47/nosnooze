"""Print the UDID of an available iPhone simulator on the newest iOS runtime."""
import json
import re
import subprocess
import sys

raw = subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "-j"], text=True
)
best = None
for runtime, devices in json.loads(raw)["devices"].items():
    match = re.search(r"SimRuntime\.iOS-(\d+)-(\d+)", runtime)
    if not match:
        continue
    version = (int(match.group(1)), int(match.group(2)))
    for device in devices:
        if device["name"].startswith("iPhone") and (best is None or version > best[0]):
            best = (version, device["udid"], device["name"])
if best is None:
    sys.exit("no available iPhone simulator")
print(f"iOS {best[0][0]}.{best[0][1]} {best[2]}", file=sys.stderr)
print(best[1])
