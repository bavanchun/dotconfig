#!/bin/bash
IFACE=$(ip route get 8.8.8.8 2>/dev/null | awk 'NR==1{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
[ -z "$IFACE" ] && { echo "󰌙 offline"; exit 0; }

STATE_FILE="/tmp/waybar_netspeed_${IFACE}"
RX_CURR=$(cat "/sys/class/net/$IFACE/statistics/rx_bytes" 2>/dev/null || echo 0)
TX_CURR=$(cat "/sys/class/net/$IFACE/statistics/tx_bytes" 2>/dev/null || echo 0)

if [ -f "$STATE_FILE" ]; then
    read RX_PREV TX_PREV < "$STATE_FILE"
else
    RX_PREV=$RX_CURR; TX_PREV=$TX_CURR
fi

echo "$RX_CURR $TX_CURR" > "$STATE_FILE"

awk -v rx="$((RX_CURR - RX_PREV))" -v tx="$((TX_CURR - TX_PREV))" '
function fmt(b) {
    if (b >= 1048576) return sprintf("%.1fM", b/1048576)
    if (b >= 1024)    return sprintf("%dK",   b/1024)
    return b "B"
}
BEGIN { printf "↓%s ↑%s\n", fmt(rx), fmt(tx) }
'
