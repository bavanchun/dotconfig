#!/bin/bash
# List clipboard history with timestamps:
#   1. Exact  — from timestamps.log (entries copied after wrapper was deployed)
#   2. Exact  — parsed from screenshot filename (YYYYMMDD_HHMMSS pattern)
#   3. ~approx — linear interpolation between known anchors
#   4. unknown — no data available at all

ts_log="$HOME/.cache/cliphist/timestamps.log"
now=$(date +%s)

declare -A ts          # id → unix timestamp
declare -A is_approx   # id → 1 if interpolated
declare -a all_ids=()
declare -A content_map

# ── 1. Load cliphist entries ─────────────────────────────────────
while IFS=$'\t' read -r id content; do
    all_ids+=("$id")
    content_map[$id]="$content"
done < <(cliphist list)

# ── 2. Load timestamps.log (exact) ──────────────────────────────
if [[ -f "$ts_log" ]]; then
    while IFS='|' read -r id t; do
        [[ -n "${content_map[$id]:-}" ]] && ts[$id]=$t
    done < "$ts_log"
fi

# ── 3. Extract timestamp from screenshot filenames (exact) ───────
for id in "${all_ids[@]}"; do
    [[ -n "${ts[$id]:-}" ]] && continue
    content="${content_map[$id]}"
    match=$(grep -oP '\d{8}_\d{6}' <<< "$content" | head -1)
    if [[ -n "$match" ]]; then
        t=$(date -d "${match:0:4}-${match:4:2}-${match:6:2} ${match:9:2}:${match:11:2}:${match:13:2}" +%s 2>/dev/null)
        [[ -n "$t" ]] && ts[$id]="$t"
    fi
done

# ── 4. Interpolate for remaining entries (O(n)) ──────────────────
mapfile -t sorted_ids < <(printf '%s\n' "${all_ids[@]}" | sort -n)
n=${#sorted_ids[@]}

# Forward pass: nearest known ts at or before each position
declare -a fwd_ts=() fwd_id=()
last_t="" last_id=""
for (( i=0; i<n; i++ )); do
    id="${sorted_ids[$i]}"
    if [[ -n "${ts[$id]:-}" ]]; then last_t="${ts[$id]}"; last_id="$id"; fi
    fwd_ts[$i]="$last_t"
    fwd_id[$i]="$last_id"
done

# Backward pass: nearest known ts at or after each position
declare -a bwd_ts=() bwd_id=()
last_t="" last_id=""
for (( i=n-1; i>=0; i-- )); do
    id="${sorted_ids[$i]}"
    if [[ -n "${ts[$id]:-}" ]]; then last_t="${ts[$id]}"; last_id="$id"; fi
    bwd_ts[$i]="$last_t"
    bwd_id[$i]="$last_id"
done

# Interpolate
for (( i=0; i<n; i++ )); do
    id="${sorted_ids[$i]}"
    [[ -n "${ts[$id]:-}" ]] && continue

    pt="${fwd_ts[$i]}" pid="${fwd_id[$i]}"
    nt="${bwd_ts[$i]}" nid="${bwd_id[$i]}"

    if [[ -n "$pid" && -n "$nid" && "$pid" != "$nid" ]]; then
        id_range=$(( nid - pid ))
        ts_range=$(( nt   - pt  ))
        id_offset=$(( id  - pid ))
        ts[$id]=$(( pt + ts_range * id_offset / id_range ))
    elif [[ -n "$pt" ]]; then
        ts[$id]="$pt"
    elif [[ -n "$nt" ]]; then
        ts[$id]="$nt"
    else
        continue
    fi
    is_approx[$id]=1
done

# ── 5. Format & output ───────────────────────────────────────────
format_time() {
    local t=$1 approx=${2:-}
    local diff=$(( now - t ))
    local label
    if   (( diff < 60 ));    then label="just now"
    elif (( diff < 3600 ));  then label="$((diff/60))m ago"
    elif (( diff < 86400 )); then label="$((diff/3600))h ago"
    else label=$(date -d "@$t" "+%Y-%m-%d %H:%M")
    fi
    [[ -n "$approx" ]] && echo "~${label}" || echo "$label"
}

for id in "${all_ids[@]}"; do
    t="${ts[$id]:-}"
    content="${content_map[$id]}"
    if [[ -n "$t" ]]; then
        label=$(format_time "$t" "${is_approx[$id]:-}")
    else
        label="unknown"
    fi
    printf '%s\t[%-20s] %s\n' "$id" "$label" "$content"
done
