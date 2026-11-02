#!/bin/bash
# Writes a plain-text snapshot of what's running on this Mac: memory totals,
# top processes by memory and CPU, and memory per app (helper processes added up).
# Lets you (or Claude) check the Mac remotely while the screen is off or locked.
#
# Run every 60 s by the LaunchAgent com.danyelaristizabal.dotfiles.process-snapshot
# (installed by setup_process_snapshot in macosx/install.sh).
# Output: ~/.dotfiles/.snapshots/processes.txt (git-ignored)

set -u
PATH=/usr/bin:/bin:/usr/sbin:/sbin

OUT_DIR="$HOME/.dotfiles/.snapshots"
OUT="$OUT_DIR/processes.txt"
mkdir -p "$OUT_DIR"
tmp=$(mktemp "$OUT_DIR/.processes.XXXXXX")
trap 'rm -f "$tmp"' EXIT

top_sample=$(top -l 1 -o mem -n 15 -stats pid,command,mem,cpu)

{
    echo "Snapshot: $(date '+%Y-%m-%d %H:%M:%S %Z')   Mac: $(scutil --get ComputerName 2>/dev/null)"
    echo "Uptime:  $(uptime | sed 's/^ *//')"
    echo "Power:   $(pmset -g ps | head -n 1 | sed "s/Now drawing from //; s/'//g")$(pmset -g batt | grep -Eo '[0-9]+%; [a-zA-Z ]+' | head -n 1 | sed 's/^/, battery /')"
    echo

    echo "== Memory =="
    echo "Installed: $(( $(sysctl -n hw.memsize) / 1073741824 )) GB"
    grep '^PhysMem' <<<"$top_sample"
    echo "Swap: $(sysctl -n vm.swapusage)"
    memory_pressure 2>/dev/null | grep -i 'free percentage' || true
    echo

    echo "== Top 15 processes by memory (same measure as Activity Monitor) =="
    awk '/^PID/ {show=1} show' <<<"$top_sample"
    echo

    echo "== Memory by app (all of its helper processes added up, resident MB) =="
    ps -axo rss=,comm= | awk '
        {
            rss = $1; $1 = ""; path = substr($0, 2)
            if (match(path, /[^\/]+\.app\//)) name = substr(path, RSTART, RLENGTH - 5)
            else { name = path; sub(/.*\//, "", name) }
            total[name] += rss
        }
        END { for (n in total) printf "%9.1f MB  %s\n", total[n] / 1024, n }
    ' | sort -rn | head -n 15
    echo

    echo "== Top 10 processes by CPU =="
    ps -arxo pid=,pcpu=,rss=,comm= | head -n 10 | awk '
        { pid = $1; cpu = $2; rss = $3; $1 = $2 = $3 = ""; name = substr($0, 4); sub(/.*\//, "", name)
          printf "%7s  %5s%%  %8.1f MB  %s\n", pid, cpu, rss / 1024, name }'
} >"$tmp" 2>&1

mv -f "$tmp" "$OUT"
trap - EXIT
