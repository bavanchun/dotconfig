#!/bin/bash
exec python3 - "$@" <<'EOF'
import sys, re, subprocess, time
from pathlib import Path
from datetime import datetime

TS_LOG = Path.home() / ".cache/cliphist/timestamps.log"
now    = int(time.time())

# ── 1. Load cliphist entries ─────────────────────────────────────
raw = subprocess.run(["cliphist", "list"], capture_output=True, text=True).stdout
entries = []       # [(id_int, id_str, content)]
content_map = {}   # id_int → content
for line in raw.splitlines():
    if "\t" not in line:
        continue
    id_str, content = line.split("\t", 1)
    try:
        id_int = int(id_str)
    except ValueError:
        continue
    entries.append((id_int, id_str, content))
    content_map[id_int] = content

# ── 2. Load timestamps.log ───────────────────────────────────────
ts = {}   # id_int → unix timestamp (int)
if TS_LOG.exists():
    for line in TS_LOG.read_text().splitlines():
        parts = line.split("|")
        if len(parts) == 2:
            try:
                ts[int(parts[0])] = int(parts[1])
            except ValueError:
                pass

# ── 3. Extract timestamp from screenshot filenames ───────────────
SS_RE = re.compile(r"(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})")
for id_int, _, content in entries:
    if id_int in ts:
        continue
    m = SS_RE.search(content)
    if m:
        try:
            dt = datetime(*(int(x) for x in m.groups()))
            ts[id_int] = int(dt.timestamp())
        except ValueError:
            pass

# ── 4. Linear interpolation (O(n)) ──────────────────────────────
sorted_ids = sorted(id_int for id_int, *_ in entries)
n = len(sorted_ids)

approx = set()  # IDs whose timestamp is interpolated

# Forward pass
fwd = {}  # i → (id, ts) of nearest known at or before
last = None
for i, sid in enumerate(sorted_ids):
    if sid in ts:
        last = (sid, ts[sid])
    fwd[i] = last

# Backward pass
bwd = {}
last = None
for i in range(n - 1, -1, -1):
    sid = sorted_ids[i]
    if sid in ts:
        last = (sid, ts[sid])
    bwd[i] = last

# Interpolate
id_to_idx = {sid: i for i, sid in enumerate(sorted_ids)}
for i, sid in enumerate(sorted_ids):
    if sid in ts:
        continue
    p = fwd.get(i)
    nx = bwd.get(i)
    if p and nx and p[0] != nx[0]:
        id_range = nx[0] - p[0]
        ts_range = nx[1] - p[1]
        offset   = sid - p[0]
        ts[sid]  = p[1] + ts_range * offset // id_range
        approx.add(sid)
    elif p:
        ts[sid] = p[1]; approx.add(sid)
    elif nx:
        ts[sid] = nx[1]; approx.add(sid)

# ── 5. Format & output ───────────────────────────────────────────
def fmt_time(t, is_approx):
    diff = now - t
    if   diff < 60:     label = "just now"
    elif diff < 3600:   label = f"{diff//60}m ago"
    elif diff < 86400:  label = f"{diff//3600}h ago"
    else:               label = datetime.fromtimestamp(t).strftime("%Y-%m-%d %H:%M")
    return ("~" if is_approx else "") + label

for id_int, id_str, content in entries:
    t = ts.get(id_int)
    if t is not None:
        label = fmt_time(t, id_int in approx)
    else:
        label = "unknown"
    print(f"[{label:<20}] {content}\t{id_str}")

EOF
