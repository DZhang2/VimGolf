# Vim Golf - Terminal Edition

A terminal-based vim golf game. Solve editing challenges in as few keystrokes as possible.

## How to Play

```bash
chmod +x vimgolf.sh
./vimgolf.sh
```

## Rules

Each level presents a **START** text and a **GOAL** text side by side. Your job is to transform START into GOAL using vim, in as few keystrokes as possible. Vim opens with `-u NONE -N` (no vimrc, nocompatible mode).

- Your keystrokes are recorded via `vim -W`
- The save command (`:wq`, `ZZ`, `:x`) is **not** counted
- Beat par to earn a star on the scoreboard
- Two hint levels per puzzle: press `h` once for a nudge, again for more detail

## Controls

### Main Menu

| Key | Action |
|-----|--------|
| `p` | Play all levels sequentially |
| `l` | Level select |
| `h` | Hard mode (unlocked per level) |
| `s` | Scoreboard |
| `k` | Solution key |
| `r` | Reset scores |
| `q` | Quit |

### During a Level

| Key | Action |
|-----|--------|
| `Enter` | Launch vim |
| `h` | Show hint (press again for a more specific hint) |
| `s` | Skip level |
| `q` | Quit |

### After Completing a Level

| Key | Action |
|-----|--------|
| `Enter` | Next level |
| `r` | Retry (improve your score) |
| `m` | Back to menu |
| `q` | Quit |

## Levels

| # | Challenge | Par | Hard Par |
|---|-----------|-----|----------|
| 1 | Delete the middle line | 3 | 5 |
| 2 | Change 'foo' to 'bar' on every line | 12 | 12 |
| 3 | Reverse the order of lines | 8 | 8 |
| 4 | Surround each word with quotes | 11 | 11 |
| 5 | Convert camelCase to snake_case | 16 | 16 |
| 6 | Sort lines and remove duplicates | 7 | 7 |
| 7 | Increment all numbers by 1 | 10 | 12 |
| 8 | Convert CSV to a markdown table | 30 | 30 |
| 9 | Align the equals signs | 20 | 22 |
| 10 | Extract function names into a list | 20 | 20 |
| 11 | Swap two columns | 27 | 27 |
| 12 | Remove blank lines | 7 | 7 |
| 13 | Convert flat list to JSON array | 24 | 24 |
| 14 | Number each line | 16 | 17 |
| 15 | The Final Boss: flatten to valid YAML | 25 | 25 |

## Hard Mode

Each level has a **hard variant** that scales the same concept to 50-200 lines. The par stays nearly identical because the *correct* vim solution doesn't depend on file size — if your approach requires per-line manual work, it won't scale.

Hard levels unlock after completing the corresponding normal level.

Examples of what changes:
- Level 1: Delete line 50 out of 100 (can't just `jdd` 50 times)
- Level 6: Sort and deduplicate 200 lines (same `:sort u` command)
- Level 14: Number 100 lines (manual typing is impossible at par)

## Requirements

- vim
- bash
- perl (for hard level 5 goal generation)
- `xxd` (for keystroke counting)
- A terminal with at least 70 columns (for side-by-side display)
