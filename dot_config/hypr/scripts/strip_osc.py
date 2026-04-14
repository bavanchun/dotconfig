#!/usr/bin/env python3
"""Strip OSC escape sequences from stdin (used before piping glow output to fzf)."""
import sys
import re

data = sys.stdin.buffer.read()
# OSC: ESC(0x1B) ] ... terminated by BEL(0x07) or ST (ESC + backslash, 0x1B 0x5C)
clean = re.sub(b'\x1b\][^\x07]*?(?:\x07|\x1b\\\\)', b'', data, flags=re.DOTALL)
sys.stdout.buffer.write(clean)
